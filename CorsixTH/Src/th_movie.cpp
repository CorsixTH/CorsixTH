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
#if (defined(CORSIX_TH_USE_FFMPEG) || defined(CORSIX_TH_USE_LIBAV)) && \
    defined(CORSIX_TH_USE_SDL_MIXER)

#include "th_gfx.h"
extern "C" {
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libavutil/imgutils.h>
#include <libavutil/mathematics.h>
#include <libavutil/opt.h>
#include <libswscale/swscale.h>
}
#include <SDL_mixer.h>

#include <chrono>
#include <cstring>
#include <iostream>

namespace {

void th_movie_audio_callback(int iChannel, void* pStream, int iStreamSize,
                             void* pUserData) {
  movie_player* pMovie = (movie_player*)pUserData;
  pMovie->copy_audio_to_stream((uint8_t*)pStream, iStreamSize);
}

}  // namespace

movie_picture::movie_picture()
    : buffer(nullptr), pixel_format(AV_PIX_FMT_RGB24), mutex{} {}

movie_picture::~movie_picture() { av_freep(&buffer); }

void movie_picture::allocate(int iWidth, int iHeight) {
  width = iWidth;
  height = iHeight;
  av_freep(&buffer);
  int numBytes = av_image_get_buffer_size(pixel_format, width, height, 1);
  buffer = static_cast<uint8_t*>(av_mallocz(numBytes));
}

void movie_picture::deallocate() { av_freep(&buffer); }

movie_picture_buffer::movie_picture_buffer()
    : aborting(false),
      allocated(false),
      picture_count(0),
      read_index(0),
      write_index(0),
      sws_context(nullptr),
      texture(nullptr),
      mutex{},
      cond{} {}

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
  for (int i = 0; i < picture_buffer_size; i++) {
    picture_queue[i].allocate(iWidth, iHeight);
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

  for (int i = 0; i < picture_buffer_size; i++) {
    std::lock_guard<std::mutex> pictureLock(picture_queue[i].mutex);
    picture_queue[i].deallocate();
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
    auto cur_pic = &(picture_queue[read_index]);

    std::lock_guard<std::mutex> pictureLock(cur_pic->mutex);
    if (cur_pic->buffer) {
      SDL_UpdateTexture(texture, nullptr, cur_pic->buffer, cur_pic->width * 3);
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

bool movie_picture_buffer::unsafe_full() {
  return (!allocated || picture_count == picture_buffer_size);
}

int movie_picture_buffer::write(AVFrame* pFrame, double dPts) {
  movie_picture* pMoviePicture = nullptr;
  std::unique_lock<std::mutex> picBufLock(mutex);
  while (unsafe_full() && !aborting) {
    cond.wait(picBufLock);
  }
  picBufLock.unlock();

  if (aborting) {
    return -1;
  }

  pMoviePicture = &picture_queue[write_index];
  std::unique_lock<std::mutex> pictureLock(pMoviePicture->mutex);

  if (pMoviePicture->buffer) {
    sws_context = sws_getCachedContext(
        sws_context, pFrame->width, pFrame->height,
        (AVPixelFormat)pFrame->format, pMoviePicture->width,
        pMoviePicture->height, pMoviePicture->pixel_format, SWS_BICUBIC,
        nullptr, nullptr, nullptr);
    if (sws_context == nullptr) {
      std::cerr << "Failed to initialize SwsContext\n";
      return 1;
    }

    /* Allocate a new frame and buffer for the destination RGB24 data. */
    AVFrame* pFrameRGB = av_frame_alloc();
    av_image_fill_arrays(pFrameRGB->data, pFrameRGB->linesize,
                         pMoviePicture->buffer, pMoviePicture->pixel_format,
                         pMoviePicture->width, pMoviePicture->height, 1);

    /* Rescale the frame data and convert it to RGB24. */
    sws_scale(sws_context, pFrame->data, pFrame->linesize, 0, pFrame->height,
              pFrameRGB->data, pFrameRGB->linesize);

    av_frame_free(&pFrameRGB);

    pMoviePicture->pts = dPts;

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

av_packet_queue::av_packet_queue() : data{}, mutex{}, cond{} {}

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
      last_error(),
      decoding_audio_mutex{},
      format_context(nullptr),
      video_codec_context(nullptr),
      audio_codec_context(nullptr),
      video_queue(),
      audio_queue(),
      movie_picture_buffer(new ::movie_picture_buffer()),
      audio_resample_context(nullptr),
      audio_buffer_size(0),
      audio_buffer_max_size(0),
      audio_frame(nullptr),
      empty_audio_chunk(nullptr),
      audio_channel(-1),
      stream_thread{},
      video_thread{} {
#if defined(CORSIX_TH_USE_LIBAV) ||   \
    (defined(CORSIX_TH_USE_FFMPEG) && \
     LIBAVCODEC_VERSION_INT < AV_VERSION_INT(58, 9, 100))
  av_register_all();
#endif

  audio_chunk_buffer =
      (uint8_t*)std::calloc(audio_chunk_buffer_capacity, sizeof(uint8_t));
}

movie_player::~movie_player() {
  unload();

  free(audio_chunk_buffer);
  delete movie_picture_buffer;
}

void movie_player::set_renderer(SDL_Renderer* pRenderer) {
  renderer = pRenderer;
}

bool movie_player::movies_enabled() const { return true; }

bool movie_player::load(const char* szFilepath) {
  int iError = 0;
  AVCodec* m_pVideoCodec;
  AVCodec* m_pAudioCodec;

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

  video_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_VIDEO,
                                           -1, -1, &m_pVideoCodec, 0);
  if (video_stream_index < 0) {
    av_strerror(video_stream_index, error_buffer, movie_error_buffer_capacity);
    last_error = std::string(error_buffer);
    return false;
  }
  video_codec_context = get_codec_context_for_stream(
      m_pVideoCodec, format_context->streams[video_stream_index]);
  avcodec_open2(video_codec_context, m_pVideoCodec, nullptr);

  audio_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_AUDIO,
                                           -1, -1, &m_pAudioCodec, 0);
  if (audio_stream_index >= 0) {
    audio_codec_context = get_codec_context_for_stream(
        m_pAudioCodec, format_context->streams[audio_stream_index]);
    avcodec_open2(audio_codec_context, m_pAudioCodec, nullptr);
  }

  return true;
}

AVCodecContext* movie_player::get_codec_context_for_stream(
    AVCodec* codec, AVStream* stream) const {
  AVCodecContext* ctx = avcodec_alloc_context3(codec);
  avcodec_parameters_to_context(ctx, stream->codecpar);
  return ctx;
}

void movie_player::unload() {
  aborting = true;

  audio_queue.release();
  video_queue.release();
  movie_picture_buffer->abort();

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
  movie_picture_buffer->deallocate();

  if (video_codec_context) {
    avcodec_free_context(&video_codec_context);
    video_codec_context = nullptr;
  }

  if (audio_channel >= 0) {
    Mix_UnregisterAllEffects(audio_channel);
    Mix_HaltChannel(audio_channel);
    Mix_FreeChunk(empty_audio_chunk);
    audio_channel = -1;
  }

  std::lock_guard<std::mutex> audioLock(decoding_audio_mutex);

  if (audio_buffer_max_size > 0) {
    av_free(audio_buffer);
    audio_buffer_max_size = 0;
  }

  if (audio_codec_context) {
    avcodec_free_context(&audio_codec_context);
    audio_codec_context = nullptr;
  }

  av_frame_free(&audio_frame);

#ifdef CORSIX_TH_USE_FFMPEG
  swr_free(&audio_resample_context);
#elif defined(CORSIX_TH_USE_LIBAV)
  // avresample_free doesn't skip nullptr on it's own.
  if (audio_resample_context != nullptr) {
    avresample_free(&audio_resample_context);
    audio_resample_context = nullptr;
  }
#endif

  if (format_context) {
    avformat_close_input(&format_context);
  }
}

void movie_player::play(int iChannel) {
  if (!renderer) {
    last_error = std::string("Cannot play before setting the renderer");
    return;
  }

  audio_queue.clear();
  video_queue.clear();
  movie_picture_buffer->reset();
  movie_picture_buffer->allocate(renderer, video_codec_context->width,
                                 video_codec_context->height);

  audio_buffer_size = 0;
  audio_buffer_index = 0;
  audio_buffer_max_size = 0;

  current_sync_pts = 0;
  current_sync_pts_system_time = SDL_GetTicks();

  if (audio_stream_index >= 0) {
    Mix_QuerySpec(&mixer_frequency, nullptr, &mixer_channels);
#ifdef CORSIX_TH_USE_FFMPEG
    audio_resample_context = swr_alloc_set_opts(
        audio_resample_context,
        mixer_channels == 1 ? AV_CH_LAYOUT_MONO : AV_CH_LAYOUT_STEREO,
        AV_SAMPLE_FMT_S16, mixer_frequency, audio_codec_context->channel_layout,
        audio_codec_context->sample_fmt, audio_codec_context->sample_rate, 0,
        nullptr);
    swr_init(audio_resample_context);
#elif defined(CORSIX_TH_USE_LIBAV)
    audio_resample_context = avresample_alloc_context();
    av_opt_set_int(audio_resample_context, "in_channel_layout",
                   audio_codec_context->channel_layout, 0);
    av_opt_set_int(
        audio_resample_context, "out_channel_layout",
        mixer_channels == 1 ? AV_CH_LAYOUT_MONO : AV_CH_LAYOUT_STEREO, 0);
    av_opt_set_int(audio_resample_context, "in_sample_rate",
                   audio_codec_context->sample_rate, 0);
    av_opt_set_int(audio_resample_context, "out_sample_rate", mixer_frequency,
                   0);
    av_opt_set_int(audio_resample_context, "in_sample_fmt",
                   audio_codec_context->sample_fmt, 0);
    av_opt_set_int(audio_resample_context, "out_sample_fmt", AV_SAMPLE_FMT_S16,
                   0);
    avresample_open(audio_resample_context);
#endif
    empty_audio_chunk =
        Mix_QuickLoad_RAW(audio_chunk_buffer, audio_chunk_buffer_capacity);

    audio_channel = Mix_PlayChannel(iChannel, empty_audio_chunk, -1);
    if (audio_channel < 0) {
      audio_channel = -1;
      last_error = std::string(Mix_GetError());
      Mix_FreeChunk(empty_audio_chunk);
    } else {
      Mix_RegisterEffect(audio_channel, th_movie_audio_callback, nullptr, this);
    }
  }

  stream_thread = std::thread(&movie_player::read_streams, this);
  video_thread = std::thread(&movie_player::run_video, this);
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

  if (!movie_picture_buffer->empty()) {
    double dCurTime = SDL_GetTicks() - current_sync_pts_system_time +
                      current_sync_pts * 1000.0;
    double dNextPts = movie_picture_buffer->get_next_pts();

    if (dNextPts > 0 && dNextPts * 1000.0 <= dCurTime) {
      movie_picture_buffer->advance();
    }

    movie_picture_buffer->draw(renderer, dest_rect);
  }
}

void movie_player::allocate_picture_buffer() {
  if (!video_codec_context) {
    return;
  }
  movie_picture_buffer->allocate(renderer, get_native_width(),
                                 get_native_height());
}

void movie_player::deallocate_picture_buffer() {
  movie_picture_buffer->deallocate();
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
      } else if (packet->stream_index == audio_stream_index) {
        audio_queue.push(std::move(packet));
      }
    }
  }

  while (!aborting) {
    if (video_queue.get_count() == 0 && audio_queue.get_count() == 0 &&
        movie_picture_buffer->get_next_pts() == 0) {
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
  AVFrame* pFrame = av_frame_alloc();
  double dClockPts;
  int iError;

  while (!aborting) {
    av_frame_unref(pFrame);

    iError = get_frame(video_stream_index, pFrame);

    if (iError == AVERROR_EOF) {
      break;
    } else if (iError < 0) {
      std::cerr << "Unexpected error " << iError
                << " while decoding video packet" << std::endl;
      break;
    }

    dClockPts = get_presentation_time_for_frame(pFrame, video_stream_index);
    iError = movie_picture_buffer->write(pFrame, dClockPts);

    if (iError < 0) {
      break;
    }
  }

  avcodec_flush_buffers(video_codec_context);
  av_frame_free(&pFrame);
}

double movie_player::get_presentation_time_for_frame(AVFrame* frame,
                                                     int streamIndex) const {
  int64_t pts;
#ifdef CORSIX_TH_USE_LIBAV
  pts = frame->pts;
  if (pts == AV_NOPTS_VALUE) {
    pts = frame->pkt_dts;
  }
#else
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(58, 18, 100)
  pts = av_frame_get_best_effort_timestamp(frame);
#else
  pts = frame->best_effort_timestamp;
#endif  // LIBAVCODEC_VERSION_INT
#endif  // CORSIX_T_USE_LIBAV

  if (pts == AV_NOPTS_VALUE) {
    pts = 0;
  }

  return pts * av_q2d(format_context->streams[streamIndex]->time_base);
}

int movie_player::get_frame(int stream, AVFrame* pFrame) {
  int iError = AVERROR(EAGAIN);
  AVCodecContext* ctx;
  av_packet_queue* pq;

  if (stream == video_stream_index) {
    ctx = video_codec_context;
    pq = &video_queue;
  } else if (stream == audio_stream_index) {
    ctx = audio_codec_context;
    pq = &audio_queue;
  } else {
    throw std::invalid_argument("Invalid value provided for stream");
  }

  while (iError == AVERROR(EAGAIN)) {
    iError = avcodec_receive_frame(ctx, pFrame);

    if (iError == AVERROR(EAGAIN)) {
      av_packet_unique_ptr pkt = pq->pull(true);
      int res = avcodec_send_packet(ctx, pkt.get());

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

  bool fFirst = true;
  while (iStreamSize > 0 && !aborting) {
    if (audio_buffer_index >= audio_buffer_size) {
      int iAudioSize = decode_audio_frame(fFirst);
      fFirst = false;

      if (iAudioSize <= 0) {
        std::memset(audio_buffer, 0, audio_buffer_size);
      } else {
        audio_buffer_size = iAudioSize;
      }
      audio_buffer_index = 0;
    }

    int iCopyLength = audio_buffer_size - audio_buffer_index;
    if (iCopyLength > iStreamSize) {
      iCopyLength = iStreamSize;
    }
    std::memcpy(pbStream, (uint8_t*)audio_buffer + audio_buffer_index,
                iCopyLength);
    iStreamSize -= iCopyLength;
    pbStream += iCopyLength;
    audio_buffer_index += iCopyLength;
  }
}

int movie_player::decode_audio_frame(bool fFirst) {
  if (!audio_frame) {
    audio_frame = av_frame_alloc();
  } else {
    av_frame_unref(audio_frame);
  }

  int iError = get_frame(audio_stream_index, audio_frame);

  if (iError == AVERROR_EOF) {
    return 0;
  } else if (iError < 0) {
    std::cerr << "Unexpected error " << iError << " while decoding audio packet"
              << std::endl;
    return 0;
  }

  double dClockPts =
      get_presentation_time_for_frame(audio_frame, audio_stream_index);
  current_sync_pts = dClockPts;
  current_sync_pts_system_time = SDL_GetTicks();
  // over-estimate output samples
  int iOutSamples =
      (int)av_rescale_rnd(audio_frame->nb_samples, mixer_frequency,
                          audio_codec_context->sample_rate, AV_ROUND_UP);
  int iSampleSize =
      av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) * iOutSamples * mixer_channels;

  if (iSampleSize > audio_buffer_max_size) {
    if (audio_buffer_max_size > 0) {
      av_free(audio_buffer);
    }
    audio_buffer = (uint8_t*)av_malloc(iSampleSize);
    audio_buffer_max_size = iSampleSize;
  }

#ifdef CORSIX_TH_USE_FFMPEG
  swr_convert(audio_resample_context, &audio_buffer, iOutSamples,
              (const uint8_t**)&audio_frame->data[0], audio_frame->nb_samples);
#elif defined(CORSIX_TH_USE_LIBAV)
  avresample_convert(audio_resample_context, &audio_buffer, 0, iOutSamples,
                     (uint8_t**)&audio_frame->data[0], 0,
                     audio_frame->nb_samples);
#endif
  return iSampleSize;
}
#else   // CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV
movie_player::movie_player() {}
movie_player::~movie_player() {}
void movie_player::set_renderer(SDL_Renderer* renderer) {}
bool movie_player::movies_enabled() const { return false; }
bool movie_player::load(const char* file_path) { return true; }
void movie_player::unload() {}
void movie_player::play(int iChannel) {
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
