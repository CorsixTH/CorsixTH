/*
Copyright (c) 2012 Stephen Baker

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "th_movie.h"

#include "config.h"

#include "lua_sdl.h"
#ifdef CORSIX_TH_USE_FFMPEG

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libavutil/channel_layout.h>
#include <libavutil/error.h>
#include <libavutil/imgutils.h>
#include <libavutil/rational.h>
#include <libavutil/samplefmt.h>
#include <libswresample/version.h>
#include <libswscale/swscale.h>
}
#include <SDL_error.h>
#include <SDL_events.h>
#include <SDL_mixer.h>
#include <SDL_pixels.h>
#include <SDL_rect.h>
#include <SDL_render.h>
#include <SDL_timer.h>

#include <cerrno>
#include <chrono>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include <utility>

namespace {

void th_movie_audio_callback(int iChannel, void* pStream, int iStreamSize,
                             void* pUserData) {
  movie_player* pMovie = static_cast<movie_player*>(pUserData);
  pMovie->copy_audio_to_stream(static_cast<uint8_t*>(pStream), iStreamSize);
}

}  // namespace

movie_picture::movie_picture()
    : buffer(nullptr),
      pixel_format(AV_PIX_FMT_RGB24),
      width(0),
      height(0),
      pts(0) {}

movie_picture::~movie_picture() { av_freep(&buffer); }

void movie_picture::allocate(int iWidth, int iHeight) {
  int numBytes = av_image_get_buffer_size(pixel_format, iWidth, iHeight, 1);
  if (numBytes < 0) {
    throw std::runtime_error(
        "problem calculating size of buffer for movie_picture");
  }
  width = iWidth;
  height = iHeight;
  av_freep(&buffer);
  buffer =
      static_cast<uint8_t*>(av_mallocz(static_cast<std::size_t>(numBytes)));
}

void movie_picture::deallocate() { av_freep(&buffer); }

movie_picture_buffer::movie_picture_buffer()
    : aborting(false),
      allocated(false),
      picture_count(0),
      read_index(0),
      write_index(0),
      sws_context(nullptr),
      texture(nullptr) {}

movie_picture_buffer::~movie_picture_buffer() {
  sws_freeContext(sws_context);
  if (texture) {
    SDL_DestroyTexture(texture);
    texture = nullptr;
  }
}

void movie_picture_buffer::abort() {
  aborting = true;
  std::lock_guard<std::mutex> lock(mutex);
  cond.notify_all();
}

void movie_picture_buffer::reset() { aborting = false; }

void movie_picture_buffer::allocate(SDL_Renderer* pRenderer, int iWidth,
                                    int iHeight) {
  if (texture) {
    SDL_DestroyTexture(texture);
    std::cerr << "movie_player overlay should be deallocated before being "
                 "allocated!\n";
  }
  texture = SDL_CreateTexture(pRenderer, SDL_PIXELFORMAT_RGB24,
                              SDL_TEXTUREACCESS_STREAMING, iWidth, iHeight);
  if (texture == nullptr) {
    std::cerr << "Problem creating overlay: " << SDL_GetError() << "\n";
    return;
  }
  for (movie_picture& picture : picture_queue) {
    picture.allocate(iWidth, iHeight);
  }
  // Do not change write_index, it's used by the other thread.
  // read_index is only used in this thread.
  read_index = write_index;

  std::lock_guard<std::mutex> lock(mutex);
  picture_count = 0;
  allocated = true;
  cond.notify_one();
}

void movie_picture_buffer::deallocate() {
  {
    std::lock_guard<std::mutex> lock(mutex);
    allocated = false;
  }

  for (movie_picture& picture : picture_queue) {
    std::lock_guard<std::mutex> pictureLock(picture.mutex);
    picture.deallocate();
  }

  if (texture) {
    SDL_DestroyTexture(texture);
    texture = nullptr;
  }
}

bool movie_picture_buffer::advance() {
  if (empty()) {
    return false;
  }

  read_index++;
  if (read_index == picture_buffer_size) {
    read_index = 0;
  }

  std::lock_guard<std::mutex> lock(mutex);
  picture_count--;
  cond.notify_one();

  return true;
}

void movie_picture_buffer::draw(SDL_Renderer* pRenderer,
                                const SDL_Rect& dstrect) {
  if (!empty()) {
    auto& cur_pic = picture_queue[read_index];

    std::lock_guard<std::mutex> pictureLock(cur_pic.mutex);
    if (cur_pic.buffer) {
      SDL_UpdateTexture(texture, nullptr, cur_pic.buffer, cur_pic.width * 3);
      int iError = SDL_RenderCopy(pRenderer, texture, nullptr, &dstrect);
      if (iError < 0) {
        std::cerr << "Error displaying movie frame: " << SDL_GetError() << "\n";
      }
    }
  }
}

double movie_picture_buffer::get_next_pts() {
  double nextPts;
  std::lock_guard<std::mutex> lock(mutex);
  if (!allocated || picture_count < 2) {
    nextPts = 0;
  } else {
    nextPts = picture_queue[(read_index + 1UL) % picture_buffer_size].pts;
  }
  return nextPts;
}

bool movie_picture_buffer::empty() {
  std::lock_guard<std::mutex> lock(mutex);
  return (!allocated || picture_count == 0);
}

bool movie_picture_buffer::full() {
  std::lock_guard<std::mutex> lock(mutex);
  return unsafe_full();
}

bool movie_picture_buffer::unsafe_full() const {
  return (!allocated || picture_count == picture_buffer_size);
}

int movie_picture_buffer::write(AVFrame* pFrame, double dPts) {
  std::unique_lock<std::mutex> picBufLock(mutex);
  while (unsafe_full() && !aborting) {
    cond.wait(picBufLock);
  }
  picBufLock.unlock();

  if (aborting) {
    return -1;
  }

  auto& picture = picture_queue[write_index];
  std::unique_lock<std::mutex> pictureLock(picture.mutex);

  if (picture.buffer) {
    sws_context = sws_getCachedContext(
        sws_context, pFrame->width, pFrame->height,
        static_cast<AVPixelFormat>(pFrame->format), picture.width,
        picture.height, picture.pixel_format, SWS_BICUBIC, nullptr, nullptr,
        nullptr);
    if (sws_context == nullptr) {
      std::cerr << "Failed to initialize SwsContext\n";
      return 1;
    }

    /* Allocate a new frame and buffer for the destination RGB24 data. */
    av_frame_unique_ptr pFrameRGB(av_frame_alloc());
    av_image_fill_arrays(pFrameRGB->data, pFrameRGB->linesize, picture.buffer,
                         picture.pixel_format, picture.width, picture.height,
                         1);

    /* Rescale the frame data and convert it to RGB24. */
    sws_scale(sws_context, pFrame->data, pFrame->linesize, 0, pFrame->height,
              pFrameRGB->data, pFrameRGB->linesize);

    picture.pts = dPts;

    pictureLock.unlock();
    write_index++;
    if (write_index == picture_buffer_size) {
      write_index = 0;
    }
    picBufLock.lock();
    picture_count++;
    picBufLock.unlock();
  }

  return 0;
}

av_packet_queue::av_packet_queue() = default;

std::size_t av_packet_queue::get_count() const { return data.size(); }

void av_packet_queue::push(av_packet_unique_ptr pPacket) {
  std::lock_guard<std::mutex> lock(mutex);
  data.push(std::move(pPacket));

  cond.notify_one();
}

av_packet_unique_ptr av_packet_queue::pull(bool block) {
  std::unique_lock<std::mutex> lock(mutex);

  if (data.empty() && block) {
    cond.wait(lock);
  }

  av_packet_unique_ptr pPacket(nullptr);
  if (!data.empty()) {
    pPacket.swap(data.front());
    data.pop();
  }

  return pPacket;
}

void av_packet_queue::release() {
  std::lock_guard<std::mutex> lock(mutex);
  cond.notify_all();
}

void av_packet_queue::clear() {
  while (get_count() > 0) {
    av_packet_unique_ptr p = pull(false);
  }
}

movie_player::movie_player()
    : renderer(nullptr),
      format_context(nullptr),
      video_codec_context(nullptr),
      audio_codec_context(nullptr),
      audio_resample_context(nullptr),
      empty_audio_chunk(nullptr),
      audio_chunk_buffer{},
      audio_channel(-1),
      error_buffer{},
      aborting(false),
      video_stream_index(-1),
      audio_stream_index(-1),
      current_sync_pts(0.0),
      current_sync_pts_system_time(0),
      mixer_channels(0),
      mixer_frequency(0) {
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(58, 9, 100)
  av_register_all();
#endif
}

movie_player::~movie_player() { unload(); }

void movie_player::set_renderer(SDL_Renderer* pRenderer) {
  renderer = pRenderer;
}

bool movie_player::movies_enabled() const { return true; }

bool movie_player::load(const char* szFilepath) {
  int iError = 0;

  unload();  // Unload any currently loaded video to free memory
  aborting = false;

  iError = avformat_open_input(&format_context, szFilepath, nullptr, nullptr);
  if (iError < 0) {
    av_strerror(iError, error_buffer, movie_error_buffer_capacity);
    last_error = std::string(error_buffer);
    return false;
  }

  iError = avformat_find_stream_info(format_context, nullptr);
  if (iError < 0) {
    av_strerror(iError, error_buffer, movie_error_buffer_capacity);
    last_error = std::string(error_buffer);
    return false;
  }

  av_codec_ptr video_decoder;  // unowned, do not free
  video_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_VIDEO,
                                           -1, -1, &video_decoder, 0);
  if (video_stream_index < 0) {
    av_strerror(video_stream_index, error_buffer, movie_error_buffer_capacity);
    last_error = std::string(error_buffer);
    return false;
  }
  video_codec_context = get_codec_context_for_stream(
      video_decoder, format_context->streams[video_stream_index]);
  avcodec_open2(video_codec_context.get(), video_decoder, nullptr);

  av_codec_ptr audio_decoder;  // unowned, do not free
  audio_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_AUDIO,
                                           -1, -1, &audio_decoder, 0);
  if (audio_stream_index >= 0) {
    audio_codec_context = get_codec_context_for_stream(
        audio_decoder, format_context->streams[audio_stream_index]);
    avcodec_open2(audio_codec_context.get(), audio_decoder, nullptr);
  }

  return true;
}

av_codec_context_unique_ptr movie_player::get_codec_context_for_stream(
    av_codec_ptr codec, AVStream* stream) const {
  av_codec_context_unique_ptr ctx(avcodec_alloc_context3(codec));
  avcodec_parameters_to_context(ctx.get(), stream->codecpar);
  return ctx;
}

void movie_player::unload() {
  aborting = true;

  audio_queue.release();
  video_queue.release();
  movie_picture_buffer.abort();

  if (stream_thread.joinable()) {
    stream_thread.join();
  }
  if (video_thread.joinable()) {
    video_thread.join();
  }

  // wait until after other threads are closed to clear the packet queues
  // so we don't free something being used.
  audio_queue.clear();
  video_queue.clear();
  movie_picture_buffer.deallocate();

  video_codec_context.reset();

  if (audio_channel >= 0) {
    Mix_UnregisterAllEffects(audio_channel);
    Mix_HaltChannel(audio_channel);
    empty_audio_chunk.reset();
    audio_channel = -1;
  }

  std::lock_guard<std::mutex> audioLock(decoding_audio_mutex);

  audio_codec_context.reset();

  swr_free(&audio_resample_context);

  if (format_context) {
    avformat_close_input(&format_context);
  }
}

void movie_player::play(int requested_audio_channel) {
  if (!renderer) {
    last_error = std::string("Cannot play before setting the renderer");
    return;
  }

  audio_queue.clear();
  video_queue.clear();
  movie_picture_buffer.reset();
  movie_picture_buffer.allocate(renderer, video_codec_context->width,
                                video_codec_context->height);

  current_sync_pts = 0;
  current_sync_pts_system_time = SDL_GetTicks();

  play_audio(requested_audio_channel);

  stream_thread = std::thread(&movie_player::read_streams, this);
  video_thread = std::thread(&movie_player::run_video, this);
}

void movie_player::play_audio(int requested_audio_channel) {
  if (audio_stream_index < 0) {
    return;
  }

  int opened = Mix_QuerySpec(&mixer_frequency, nullptr, &mixer_channels);

  if (opened == 0 || mixer_channels == 0) {
    return;
  }

  std::int64_t target_channel_layout;
  switch (mixer_channels) {
    case 1:
      target_channel_layout = AV_CH_LAYOUT_MONO;
      break;
    case 2:
      target_channel_layout = AV_CH_LAYOUT_STEREO;
      break;
    case 4:
      target_channel_layout = AV_CH_LAYOUT_QUAD;
      break;
    case 6:
      target_channel_layout = AV_CH_LAYOUT_5POINT1;
      break;
    case 8:
      target_channel_layout = AV_CH_LAYOUT_7POINT1;
      break;
    default:
      std::cerr << "WARN: unsupported channel layout " << mixer_channels
                << ". Please report issue.";
      target_channel_layout = 0;
  }

#if LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(57, 24, 100) && \
    LIBSWRESAMPLE_VERSION_INT >= AV_VERSION_INT(4, 5, 100)
  av_channel_layout_unique_ptr ch_layout(new AVChannelLayout{});

  if (target_channel_layout == 0) {
    av_channel_layout_default(ch_layout.get(), mixer_channels);
  } else {
    av_channel_layout_from_mask(ch_layout.get(), target_channel_layout);
  }

  swr_alloc_set_opts2(&audio_resample_context, ch_layout.get(),
                      AV_SAMPLE_FMT_S16, mixer_frequency,
                      &(audio_codec_context->ch_layout),
                      audio_codec_context->sample_fmt,
                      audio_codec_context->sample_rate, 0, nullptr);
#else
  if (target_channel_layout == 0) {
    target_channel_layout = av_get_default_channel_layout(mixer_channels);
  }

  audio_resample_context = swr_alloc_set_opts(
      audio_resample_context, static_cast<std::int64_t>(target_channel_layout),
      AV_SAMPLE_FMT_S16, mixer_frequency,
      static_cast<std::int64_t>(audio_codec_context->channel_layout),
      audio_codec_context->sample_fmt, audio_codec_context->sample_rate, 0,
      nullptr);
#endif
  swr_init(audio_resample_context);
  empty_audio_chunk.reset(
      Mix_QuickLoad_RAW(audio_chunk_buffer.data(),
                        static_cast<uint32_t>(audio_chunk_buffer.size())));

  audio_channel =
      Mix_PlayChannel(requested_audio_channel, empty_audio_chunk.get(), -1);
  if (audio_channel < 0) {
    audio_channel = -1;
    last_error = std::string(Mix_GetError());
    empty_audio_chunk.reset();
  } else {
    Mix_RegisterEffect(audio_channel, th_movie_audio_callback, nullptr, this);
  }
}

void movie_player::stop() { aborting = true; }

int movie_player::get_native_height() const {
  int iHeight = 0;

  if (video_codec_context) {
    iHeight = video_codec_context->height;
  }
  return iHeight;
}

int movie_player::get_native_width() const {
  int iWidth = 0;

  if (video_codec_context) {
    iWidth = video_codec_context->width;
  }
  return iWidth;
}

bool movie_player::has_audio_track() const { return (audio_stream_index >= 0); }

const char* movie_player::get_last_error() const { return last_error.c_str(); }

void movie_player::clear_last_error() { last_error.clear(); }

void movie_player::refresh(const SDL_Rect& destination_rect) {
  SDL_Rect dest_rect;

  dest_rect = SDL_Rect{destination_rect.x, destination_rect.y,
                       destination_rect.w, destination_rect.h};

  if (!movie_picture_buffer.empty()) {
    double dCurTime = SDL_GetTicks() - current_sync_pts_system_time +
                      current_sync_pts * 1000.0;
    double dNextPts = movie_picture_buffer.get_next_pts();

    if (dNextPts > 0 && dNextPts * 1000.0 <= dCurTime) {
      movie_picture_buffer.advance();
    }

    movie_picture_buffer.draw(renderer, dest_rect);
  }
}

void movie_player::allocate_picture_buffer() {
  if (!video_codec_context) {
    return;
  }
  movie_picture_buffer.allocate(renderer, get_native_width(),
                                get_native_height());
}

void movie_player::deallocate_picture_buffer() {
  movie_picture_buffer.deallocate();
}

void movie_player::read_streams() {
  while (!aborting) {
    av_packet_unique_ptr packet(
        static_cast<AVPacket*>(av_malloc(sizeof(AVPacket))));
    int iError = av_read_frame(format_context, packet.get());
    if (iError < 0) {
      if (iError == AVERROR_EOF || format_context->pb->error ||
          format_context->pb->eof_reached) {
        break;
      }
    } else {
      if (packet->stream_index == video_stream_index) {
        video_queue.push(std::move(packet));
      } else if (packet->stream_index == audio_stream_index &&
                 audio_channel >= 0) {
        audio_queue.push(std::move(packet));
      }
    }
  }

  while (!aborting) {
    if (video_queue.get_count() == 0 && audio_queue.get_count() == 0 &&
        movie_picture_buffer.get_next_pts() == 0) {
      break;
    }
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
  }

  SDL_Event endEvent;
  endEvent.type = SDL_USEREVENT_MOVIE_OVER;
  SDL_PushEvent(&endEvent);
  aborting = true;
}

void movie_player::run_video() {
  av_frame_unique_ptr pFrame(av_frame_alloc());
  double dClockPts;
  int iError;

  while (!aborting) {
    av_frame_unref(pFrame.get());

    iError = populate_frame(video_stream_index, *pFrame);

    if (iError == AVERROR_EOF) {
      break;
    } else if (iError < 0) {
      std::cerr << "Unexpected error " << iError
                << " while decoding video packet\n";
      break;
    }

    dClockPts = get_presentation_time_for_frame(*pFrame, video_stream_index);
    iError = movie_picture_buffer.write(pFrame.get(), dClockPts);

    if (iError < 0) {
      break;
    }
  }

  avcodec_flush_buffers(video_codec_context.get());
}

double movie_player::get_presentation_time_for_frame(const AVFrame& frame,
                                                     int streamIndex) const {
  int64_t pts;
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(58, 18, 100)
  pts = av_frame_get_best_effort_timestamp(&frame);
#else
  pts = frame.best_effort_timestamp;
#endif  // LIBAVCODEC_VERSION_INT

  if (pts == AV_NOPTS_VALUE) {
    pts = 0;
  }

  return static_cast<double>(pts) *
         av_q2d(format_context->streams[streamIndex]->time_base);
}

int movie_player::populate_frame(int stream, AVFrame& frame) {
  if (stream == video_stream_index) {
    return populate_frame(*video_codec_context, video_queue, frame);
  } else if (stream == audio_stream_index) {
    return populate_frame(*audio_codec_context, audio_queue, frame);
  } else {
    throw std::invalid_argument("Invalid value provided for stream");
  }
}

int movie_player::populate_frame(AVCodecContext& ctx, av_packet_queue& pq,
                                 AVFrame& frame) {
  int iError = AVERROR(EAGAIN);
  while (iError == AVERROR(EAGAIN)) {
    iError = avcodec_receive_frame(&ctx, &frame);

    if (iError == AVERROR(EAGAIN)) {
      av_packet_unique_ptr pkt = pq.pull(true);
      int res = avcodec_send_packet(&ctx, pkt.get());

      if (res == AVERROR(EAGAIN)) {
        throw std::runtime_error(
            "avcodec_receive_frame and avcodec_send_packet should "
            "not return EAGAIN at the same time");
      }
    }
  }

  return iError;
}

void movie_player::copy_audio_to_stream(uint8_t* pbStream, int iStreamSize) {
  std::lock_guard<std::mutex> audioLock(decoding_audio_mutex);

  while (iStreamSize > 0 && !aborting) {
    int iAudioSize = decode_audio_frame(pbStream, iStreamSize);

    if (iAudioSize <= 0) {
      std::memset(pbStream, 0, static_cast<std::size_t>(iStreamSize));
      return;
    } else {
      iStreamSize -= iAudioSize;
      pbStream += iAudioSize;
    }
  }
}

int movie_player::decode_audio_frame(uint8_t* stream, int stream_size) {
  int iOutSamples = stream_size / (av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) *
                                   mixer_channels);

  int actual_samples =
      swr_convert(audio_resample_context, &stream, iOutSamples, nullptr, 0);
  if (actual_samples < 0) {
    std::cerr << "WARN: Unexpected error " << actual_samples
              << " while converting audio\n";
    return 0;
  } else if (actual_samples > 0) {
    return actual_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) *
           mixer_channels;
  }

  av_frame_unique_ptr audio_frame(av_frame_alloc());
  int iError = populate_frame(audio_stream_index, *audio_frame);

  if (iError == AVERROR_EOF) {
    return 0;
  } else if (iError < 0) {
    std::cerr << "WARN: Unexpected error " << iError
              << " while decoding audio packet\n";
    return 0;
  }

  double dClockPts =
      get_presentation_time_for_frame(*audio_frame, audio_stream_index);
  current_sync_pts = dClockPts;
  current_sync_pts_system_time = SDL_GetTicks();

  actual_samples =
      swr_convert(audio_resample_context, &stream, iOutSamples,
                  const_cast<const uint8_t**>(&audio_frame->data[0]),
                  audio_frame->nb_samples);
  if (actual_samples < 0) {
    std::cerr << "WARN: Unexpected error " << actual_samples
              << " while converting audio\n";
    return 0;
  }
  return actual_samples * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) *
         mixer_channels;
}
#else   // CORSIX_TH_USE_FFMPEG
movie_player::movie_player() {}
movie_player::~movie_player() {}
void movie_player::set_renderer(SDL_Renderer* renderer) {}
bool movie_player::movies_enabled() const { return false; }
bool movie_player::load(const char* file_path) { return true; }
void movie_player::unload() {}
void movie_player::play(int requested_audio_channel) {
  SDL_Event endEvent;
  endEvent.type = SDL_USEREVENT_MOVIE_OVER;
  SDL_PushEvent(&endEvent);
}
void movie_player::stop() {}
int movie_player::get_native_height() const { return 0; }
int movie_player::get_native_width() const { return 0; }
bool movie_player::has_audio_track() const { return false; }
const char* movie_player::get_last_error() const { return nullptr; }
void movie_player::clear_last_error() {}
void movie_player::refresh(const SDL_Rect& destination_rect) {}
void movie_player::allocate_picture_buffer() {}
void movie_player::deallocate_picture_buffer() {}
void movie_player::read_streams() {}
void movie_player::run_video() {}
void movie_player::copy_audio_to_stream(uint8_t* stream, int length) {}
#endif  // CORSIX_TH_USE_FFMPEG
