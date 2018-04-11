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
#if (defined(CORSIX_TH_USE_FFMPEG) || defined(CORSIX_TH_USE_LIBAV)) && defined(CORSIX_TH_USE_SDL_MIXER)

#include "th_gfx.h"
extern "C"
{
    #include <libavcodec/avcodec.h>
    #include <libswscale/swscale.h>
    #include <libavutil/avutil.h>
    #include <libavutil/mathematics.h>
    #include <libavutil/opt.h>
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(54, 6, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(51, 63, 100))
    #include <libavutil/imgutils.h>
#endif
}
#include <SDL_mixer.h>
#include <iostream>
#include <cstring>

#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(57, 7, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(57, 12, 100))
#define av_packet_unref av_free_packet
#endif

#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55, 45, 101)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(55, 28, 1))
#define av_frame_alloc avcodec_alloc_frame
#define av_frame_unref avcodec_get_frame_defaults
#define av_frame_free avcodec_free_frame
#endif

static void th_movie_audio_callback(int iChannel, void *pStream, int iStreamSize, void *pUserData)
{
    movie_player *pMovie = (movie_player *)pUserData;
    pMovie->copy_audio_to_stream((uint8_t*)pStream, iStreamSize);
}

movie_picture::movie_picture():
    buffer(nullptr),
    pixel_format(AV_PIX_FMT_RGB24),
    mutex{}
{}

movie_picture::~movie_picture()
{
    av_freep(&buffer);
}

void movie_picture::allocate(int iWidth, int iHeight)
{
    width = iWidth;
    height = iHeight;
    av_freep(&buffer);
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(54, 6, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(51, 63, 100))
    int numBytes = av_image_get_buffer_size(pixel_format, width, height, 1);
#else
    int numBytes = avpicture_get_size(pixel_format, width, height);
#endif
    buffer = static_cast<uint8_t*>(av_mallocz(numBytes));
}

void movie_picture::deallocate()
{
    av_freep(&buffer);
}

movie_picture_buffer::movie_picture_buffer():
    aborting(false),
    allocated(false),
    picture_count(0),
    read_index(0),
    write_index(0),
    sws_context(nullptr),
    texture(nullptr),
    mutex{},
    cond{}
{
}

movie_picture_buffer::~movie_picture_buffer()
{
    sws_freeContext(sws_context);
    if (texture)
    {
        SDL_DestroyTexture(texture);
        texture = nullptr;
    }
}

void movie_picture_buffer::abort()
{
    aborting = true;
    std::lock_guard<std::mutex> lock(mutex);
    cond.notify_all();
}

void movie_picture_buffer::reset()
{
    aborting = false;
}

void movie_picture_buffer::allocate(SDL_Renderer *pRenderer, int iWidth, int iHeight)
{
    if (texture)
    {
        SDL_DestroyTexture(texture);
        std::cerr << "movie_player overlay should be deallocated before being allocated!\n";
    }
    texture = SDL_CreateTexture(pRenderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, iWidth, iHeight);
    if (texture == nullptr)
    {
        std::cerr << "Problem creating overlay: " << SDL_GetError() << "\n";
        return;
    }
    for(int i = 0; i < picture_buffer_size; i++)
    {
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

void movie_picture_buffer::deallocate()
{
    {
        std::lock_guard<std::mutex> lock(mutex);
        allocated = false;
    }

    for(int i = 0; i < picture_buffer_size; i++)
    {
        std::lock_guard<std::mutex> pictureLock(picture_queue[i].mutex);
        picture_queue[i].deallocate();
    }

    if (texture)
    {
        SDL_DestroyTexture(texture);
        texture = nullptr;
    }
}

bool movie_picture_buffer::advance()
{
    if(empty()) { return false; }

    read_index++;
    if(read_index == picture_buffer_size)
    {
        read_index = 0;
    }

    std::lock_guard<std::mutex> lock(mutex);
    picture_count--;
    cond.notify_one();

    return true;
}

void movie_picture_buffer::draw(SDL_Renderer *pRenderer, const SDL_Rect &dstrect)
{
    if(!empty())
    {
        auto cur_pic = &(picture_queue[read_index]);

        std::lock_guard<std::mutex> pictureLock(cur_pic->mutex);
        if (cur_pic->buffer)
        {
            SDL_UpdateTexture(texture, nullptr, cur_pic->buffer, cur_pic->width * 3);
            int iError = SDL_RenderCopy(pRenderer, texture, nullptr, &dstrect);
            if (iError < 0)
            {
                std::cerr << "Error displaying movie frame: " << SDL_GetError() << "\n";
            }
        }
    }
}

double movie_picture_buffer::get_next_pts()
{
    double nextPts;
    std::lock_guard<std::mutex> lock(mutex);
    if(!allocated || picture_count < 2)
    {
        nextPts = 0;
    }
    else
    {
        nextPts = picture_queue[(read_index + 1) % picture_buffer_size].pts;
    }
    return nextPts;
}

bool movie_picture_buffer::empty()
{
    std::lock_guard<std::mutex> lock(mutex);
    return (!allocated || picture_count == 0);
}

bool movie_picture_buffer::full()
{
    std::lock_guard<std::mutex> lock(mutex);
    return unsafe_full();
}

bool movie_picture_buffer::unsafe_full()
{
    return (!allocated || picture_count == picture_buffer_size);
}

int movie_picture_buffer::write(AVFrame* pFrame, double dPts)
{
    movie_picture* pMoviePicture = nullptr;
    std::unique_lock<std::mutex> picBufLock(mutex);
    while(unsafe_full() && !aborting)
    {
        cond.wait(picBufLock);
    }
    picBufLock.unlock();

    if(aborting) { return -1; }

    pMoviePicture = &picture_queue[write_index];
    std::unique_lock<std::mutex> pictureLock(pMoviePicture->mutex);

    if(pMoviePicture->buffer)
    {
        sws_context = sws_getCachedContext(sws_context, pFrame->width, pFrame->height, (AVPixelFormat)pFrame->format, pMoviePicture->width, pMoviePicture->height, pMoviePicture->pixel_format, SWS_BICUBIC, nullptr, nullptr, nullptr);
        if(sws_context == nullptr)
        {
            std::cerr << "Failed to initialize SwsContext\n";
            return 1;
        }

        /* Allocate a new frame and buffer for the destination RGB24 data. */
        AVFrame *pFrameRGB = av_frame_alloc();
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(54, 6, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(51, 63, 100))
        av_image_fill_arrays(pFrameRGB->data, pFrameRGB->linesize, pMoviePicture->buffer, pMoviePicture->pixel_format, pMoviePicture->width, pMoviePicture->height, 1);
#else
        avpicture_fill((AVPicture *)pFrameRGB, pMoviePicture->buffer, pMoviePicture->pixel_format, pMoviePicture->width, pMoviePicture->height);
#endif

        /* Rescale the frame data and convert it to RGB24. */
        sws_scale(sws_context, pFrame->data, pFrame->linesize, 0, pFrame->height, pFrameRGB->data, pFrameRGB->linesize);

        av_frame_free(&pFrameRGB);

        pMoviePicture->pts = dPts;

        pictureLock.unlock();
        write_index++;
        if(write_index == picture_buffer_size)
        {
            write_index = 0;
        }
        picBufLock.lock();
        picture_count++;
        picBufLock.unlock();
    }

    return 0;
}

av_packet_queue::av_packet_queue():
    first_packet(nullptr),
    last_packet(nullptr),
    count(0),
    mutex{},
    cond{}
{
}

av_packet_queue::~av_packet_queue()
{
}

int av_packet_queue::get_count() const
{
    return count;
}

void av_packet_queue::push(AVPacket *pPacket)
{
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(57, 12, 100)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(57, 8, 0))
    if(av_dup_packet(pPacket) < 0) { throw -1; }
#endif

    AVPacketList* pNode = (AVPacketList*)av_malloc(sizeof(AVPacketList));
    pNode->pkt = *pPacket;
    pNode->next = nullptr;

    std::lock_guard<std::mutex> lock(mutex);

    if(last_packet == nullptr)
    {
        first_packet = pNode;
    }
    else
    {
        last_packet->next = pNode;
    }
    last_packet = pNode;
    count++;

    cond.notify_one();
}

AVPacket* av_packet_queue::pull(bool fBlock)
{
    std::unique_lock<std::mutex> lock(mutex);

    AVPacketList* pNode = first_packet;
    if(pNode == nullptr && fBlock)
    {
        cond.wait(lock);
        pNode = first_packet;
    }

    AVPacket *pPacket;
    if(pNode == nullptr)
    {
        pPacket = nullptr;
    }
    else
    {
        first_packet = pNode->next;
        if(first_packet == nullptr) { last_packet = nullptr; }
        count--;

        pPacket = (AVPacket*)av_malloc(sizeof(AVPacket));
        *pPacket = pNode->pkt;
        av_free(pNode);
    }

    return pPacket;
}

void av_packet_queue::release()
{
    std::lock_guard<std::mutex> lock(mutex);
    cond.notify_all();
}

movie_player::movie_player():
    renderer(nullptr),
    last_error(),
    format_context(nullptr),
    video_codec_context(nullptr),
    audio_codec_context(nullptr),
    video_queue(nullptr),
    audio_queue(nullptr),
    movie_picture_buffer(new ::movie_picture_buffer()),
    audio_resample_context(nullptr),
    audio_buffer_size(0),
    audio_buffer_max_size(0),
    audio_packet(nullptr),
    audio_frame(nullptr),
    empty_audio_chunk(nullptr),
    audio_channel(-1),
    stream_thread{},
    video_thread{},
    decoding_audio_mutex{}
{
    av_register_all();

    flush_packet = (AVPacket*)av_malloc(sizeof(AVPacket));
    av_init_packet(flush_packet);
    flush_packet->data = (uint8_t *)"FLUSH";
    flush_packet->size = 5;

    audio_chunk_buffer = (uint8_t*)std::calloc(audio_chunk_buffer_capacity, sizeof(uint8_t));
}

movie_player::~movie_player()
{
    unload();

    av_packet_unref(flush_packet);
    av_free(flush_packet);
    free(audio_chunk_buffer);
}

void movie_player::set_renderer(SDL_Renderer *pRenderer)
{
    renderer = pRenderer;
}

bool movie_player::movies_enabled() const
{
    return true;
}

bool movie_player::load(const char* szFilepath)
{
    int iError = 0;
    AVCodec* m_pVideoCodec;
    AVCodec* m_pAudioCodec;

    unload(); //Unload any currently loaded video to free memory
    aborting = false;

    iError = avformat_open_input(&format_context, szFilepath, nullptr, nullptr);
    if(iError < 0)
    {
        av_strerror(iError, error_buffer, movie_error_buffer_capacity);
        last_error = std::string(error_buffer);
        return false;
    }

    iError = avformat_find_stream_info(format_context, nullptr);
    if(iError < 0)
    {
        av_strerror(iError, error_buffer, movie_error_buffer_capacity);
        last_error = std::string(error_buffer);
        return false;
    }

    video_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_VIDEO, -1, -1, &m_pVideoCodec, 0);
    video_codec_context = get_codec_context_for_stream(m_pVideoCodec, format_context->streams[video_stream_index]);
    avcodec_open2(video_codec_context, m_pVideoCodec, nullptr);

    audio_stream_index = av_find_best_stream(format_context, AVMEDIA_TYPE_AUDIO, -1, -1, &m_pAudioCodec, 0);
    if(audio_stream_index >= 0)
    {
        audio_codec_context = get_codec_context_for_stream(m_pAudioCodec, format_context->streams[audio_stream_index]);
        avcodec_open2(audio_codec_context, m_pAudioCodec, nullptr);
    }

    return true;
}

AVCodecContext* movie_player::get_codec_context_for_stream(AVCodec* codec, AVStream* stream) const
{
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVCODEC_VERSION_INT >= AV_VERSION_INT(57, 14, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVCODEC_VERSION_INT >= AV_VERSION_INT(57, 33, 100))
    AVCodecContext* ctx = avcodec_alloc_context3(codec);
    avcodec_parameters_to_context(ctx, stream->codecpar);
    return ctx;
#else
    return stream->codec;
#endif
}

void movie_player::unload()
{
    aborting = true;

    if(audio_queue)
    {
        audio_queue->release();
    }
    if(video_queue)
    {
        video_queue->release();
    }
    movie_picture_buffer->abort();

    if(stream_thread.joinable())
    {
        stream_thread.join();
    }
    if(video_thread.joinable())
    {
        video_thread.join();
    }

    //wait until after other threads are closed to clear the packet queues
    //so we don't free something being used.
    if(audio_queue)
    {
        while(audio_queue->get_count() > 0)
        {
            AVPacket* p = audio_queue->pull(false);
            av_packet_unref(p);
        }
        delete audio_queue;
        audio_queue = nullptr;
    }
    if(video_queue)
    {
        while(video_queue->get_count() > 0)
        {
            AVPacket* p = video_queue->pull(false);
            av_packet_unref(p);
        }
        delete video_queue;
        video_queue = nullptr;
    }
    movie_picture_buffer->deallocate();

    if(video_codec_context)
    {
        avcodec_close(video_codec_context);
        video_codec_context = nullptr;
    }

    if(audio_channel >= 0)
    {
        Mix_UnregisterAllEffects(audio_channel);
        Mix_HaltChannel(audio_channel);
        Mix_FreeChunk(empty_audio_chunk);
        audio_channel = -1;
    }

    std::lock_guard<std::mutex> audioLock(decoding_audio_mutex);

    if(audio_buffer_max_size > 0)
    {
        av_free(audio_buffer);
        audio_buffer_max_size = 0;
    }
    if(audio_codec_context)
    {
        avcodec_close(audio_codec_context);
        audio_codec_context = nullptr;
    }
    av_frame_free(&audio_frame);

#ifdef CORSIX_TH_USE_FFMPEG
    swr_free(&audio_resample_context);
#elif defined(CORSIX_TH_USE_LIBAV)
    // avresample_free doesn't skip nullptr on it's own.
    if (audio_resample_context != nullptr)
    {
        avresample_free(&audio_resample_context);
        audio_resample_context = nullptr;
    }
#endif

    if(audio_packet)
    {
        audio_packet->data = audio_packet_data;
        audio_packet->size = audio_packet_size;
        av_packet_unref(audio_packet);
        av_free(audio_packet);
        audio_packet = nullptr;
        audio_packet_data = nullptr;
        audio_packet_size = 0;
    }

    if(format_context)
    {
        avformat_close_input(&format_context);
    }
}

void movie_player::play(int iChannel)
{
    if(!renderer)
    {
        last_error = std::string("Cannot play before setting the renderer");
        return;
    }

    video_queue = new av_packet_queue();
    movie_picture_buffer->reset();
    movie_picture_buffer->allocate(renderer, video_codec_context->width, video_codec_context->height);

    audio_packet = nullptr;
    audio_packet_size = 0;
    audio_packet_data = nullptr;

    audio_buffer_size = 0;
    audio_buffer_index = 0;
    audio_buffer_max_size = 0;

    audio_queue = new av_packet_queue();
    current_sync_pts = 0;
    current_sync_pts_system_time = SDL_GetTicks();

    if(audio_stream_index >= 0)
    {
        Mix_QuerySpec(&mixer_frequency, nullptr, &mixer_channels);
#ifdef CORSIX_TH_USE_FFMPEG
        audio_resample_context = swr_alloc_set_opts(
            audio_resample_context,
            mixer_channels==1?AV_CH_LAYOUT_MONO:AV_CH_LAYOUT_STEREO,
            AV_SAMPLE_FMT_S16,
            mixer_frequency,
            audio_codec_context->channel_layout,
            audio_codec_context->sample_fmt,
            audio_codec_context->sample_rate,
            0,
            nullptr);
        swr_init(audio_resample_context);
#elif defined(CORSIX_TH_USE_LIBAV)
        audio_resample_context = avresample_alloc_context();
        av_opt_set_int(audio_resample_context, "in_channel_layout", audio_codec_context->channel_layout, 0);
        av_opt_set_int(audio_resample_context, "out_channel_layout", mixer_channels == 1 ? AV_CH_LAYOUT_MONO : AV_CH_LAYOUT_STEREO, 0);
        av_opt_set_int(audio_resample_context, "in_sample_rate", audio_codec_context->sample_rate, 0);
        av_opt_set_int(audio_resample_context, "out_sample_rate", mixer_frequency, 0);
        av_opt_set_int(audio_resample_context, "in_sample_fmt", audio_codec_context->sample_fmt, 0);
        av_opt_set_int(audio_resample_context, "out_sample_fmt", AV_SAMPLE_FMT_S16, 0);
        avresample_open(audio_resample_context);
#endif
        empty_audio_chunk = Mix_QuickLoad_RAW(audio_chunk_buffer, audio_buffer_size);

        audio_channel = Mix_PlayChannel(iChannel, empty_audio_chunk, -1);
        if(audio_channel < 0)
        {
            audio_channel = -1;
            last_error = std::string(Mix_GetError());
        }
        else
        {
            Mix_RegisterEffect(audio_channel, th_movie_audio_callback, nullptr, this);
        }
    }

    stream_thread = std::thread(&movie_player::read_streams, this);
    video_thread = std::thread(&movie_player::run_video, this);
}

void movie_player::stop()
{
    aborting = true;
}

int movie_player::get_native_height() const
{
    int iHeight = 0;

    if(video_codec_context)
    {
        iHeight = video_codec_context->height;
    }
    return iHeight;
}

int movie_player::get_native_width() const
{
    int iWidth = 0;

    if(video_codec_context)
    {
        iWidth = video_codec_context->width;
    }
    return iWidth;
}

bool movie_player::has_audio_track() const
{
    return (audio_stream_index >= 0);
}

const char* movie_player::get_last_error() const
{
    return last_error.c_str();
}

void movie_player::clear_last_error()
{
    last_error.clear();
}

void movie_player::refresh(const SDL_Rect &destination_rect)
{
    SDL_Rect dest_rect;

    dest_rect = SDL_Rect{ destination_rect.x, destination_rect.y, destination_rect.w, destination_rect.h };

    if(!movie_picture_buffer->empty())
    {
        double dCurTime = SDL_GetTicks() - current_sync_pts_system_time + current_sync_pts * 1000.0;
        double dNextPts = movie_picture_buffer->get_next_pts();

        if(dNextPts > 0 && dNextPts * 1000.0 <= dCurTime)
        {
            movie_picture_buffer->advance();
        }

        movie_picture_buffer->draw(renderer, dest_rect);
    }
}

void movie_player::allocate_picture_buffer()
{
    if(!video_codec_context)
    {
        return;
    }
    movie_picture_buffer->allocate(renderer, get_native_width(), get_native_height());
}

void movie_player::deallocate_picture_buffer()
{
    movie_picture_buffer->deallocate();
}

void movie_player::read_streams()
{
    AVPacket packet;
    int iError;

    while(!aborting)
    {
        iError = av_read_frame(format_context, &packet);
        if(iError < 0)
        {
            if(iError == AVERROR_EOF || format_context->pb->error || format_context->pb->eof_reached)
            {
                break;
            }
        }
        else
        {
            if(packet.stream_index == video_stream_index)
            {
                video_queue->push(&packet);
            }
            else if (packet.stream_index == audio_stream_index)
            {
                audio_queue->push(&packet);
            }
            else
            {
                av_packet_unref(&packet);
            }
        }
    }

    while(!aborting)
    {
        if(video_queue->get_count() == 0 && audio_queue->get_count() == 0 && movie_picture_buffer->get_next_pts() == 0)
        {
            break;
        }
        SDL_Delay(10);
    }

    SDL_Event endEvent;
    endEvent.type = SDL_USEREVENT_MOVIE_OVER;
    SDL_PushEvent(&endEvent);
    aborting = true;
}

void movie_player::run_video()
{
    AVFrame *pFrame = av_frame_alloc();
    double dClockPts;
    int iError;

    while(!aborting)
    {
        av_frame_unref(pFrame);

#ifdef CORSIX_TH_MOVIE_USE_SEND_PACKET_API
        iError = get_frame(video_stream_index, pFrame);

        if (iError == AVERROR_EOF)
        {
            break;
        }
        else if (iError < 0)
        {
            std::cerr << "Unexpected error " << iError << " while decoding video packet" << std::endl;
            break;
        }
#else
        iError = get_video_frame(pFrame);
        if(iError < 0)
        {
            break;
        }
        else if(iError == 0)
        {
            continue;
        }
#endif

        dClockPts = get_presentation_time_for_frame(pFrame, video_stream_index);
        iError = movie_picture_buffer->write(pFrame, dClockPts);

        if(iError < 0)
        {
            break;
        }
    }

    avcodec_flush_buffers(video_codec_context);
    av_frame_free(&pFrame);
}

double movie_player::get_presentation_time_for_frame(AVFrame* frame, int streamIndex) const
{
    int64_t pts;
#ifdef CORSIX_TH_USE_LIBAV
    pts = frame->pts;
    if (pts == AV_NOPTS_VALUE)
    {
        pts = frame->pkt_dts;
    }
#else
#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(54, 18, 100)
    pts = *(int64_t*)av_opt_ptr(avcodec_get_frame_class(), frame, "best_effort_timestamp");
#else
    pts = av_frame_get_best_effort_timestamp(frame);
#endif //LIBAVCODEC_VERSION_INT
#endif //CORSIX_T_USE_LIBAV

    if (pts == AV_NOPTS_VALUE)
    {
        pts = 0;
    }

    return pts * av_q2d(format_context->streams[streamIndex]->time_base);
}

#ifdef CORSIX_TH_MOVIE_USE_SEND_PACKET_API
int movie_player::get_frame(int stream, AVFrame* pFrame)
{
    int iError = AVERROR(EAGAIN);
    AVCodecContext* ctx;
    av_packet_queue* pq;

    if (stream == video_stream_index)
    {
        ctx = video_codec_context;
        pq = video_queue;
    }
    else if (stream == audio_stream_index)
    {
        ctx = audio_codec_context;
        pq = audio_queue;
    }
    else
    {
        throw std::invalid_argument("Invalid value provided for stream");
    }

    while (iError == AVERROR(EAGAIN))
    {
        iError = avcodec_receive_frame(ctx, pFrame);

        if (iError == AVERROR(EAGAIN))
        {
            AVPacket* pkt = pq->pull(true);
            int res = avcodec_send_packet(ctx, pkt);

            if (res == AVERROR(EAGAIN))
            {
                throw std::runtime_error("avcodec_receive_frame and avcodec_send_packet should not return EAGAIN at the same time");
            }
        }
    }

    return iError;
}

#else
int movie_player::get_video_frame(AVFrame *pFrame)
{
    int iGotPicture = 0;
    int iError;

    AVPacket *pPacket = video_queue->pull(true);
    if(pPacket == nullptr)
    {
        return -1;
    }

    if(pPacket->data == flush_packet->data)
    {
        //TODO: Flush

        return 0;
    }

    iError = avcodec_decode_video2(video_codec_context, pFrame, &iGotPicture, pPacket);
    av_packet_unref(pPacket);
    av_free(pPacket);

    if(iError < 0)
    {
        return 0;
    }

    if(iGotPicture)
    {
        iError = 1;
        return iError;
    }

    return 0;
}
#endif

void movie_player::copy_audio_to_stream(uint8_t *pbStream, int iStreamSize)
{
    std::lock_guard<std::mutex> audioLock(decoding_audio_mutex);

    bool fFirst = true;
    while(iStreamSize > 0  && !aborting)
    {
        if(audio_buffer_index >= audio_buffer_size)
        {
            int iAudioSize = decode_audio_frame(fFirst);
            fFirst = false;

            if(iAudioSize <= 0)
            {
                std::memset(audio_buffer, 0, audio_buffer_size);
            }
            else
            {
                audio_buffer_size = iAudioSize;
            }
            audio_buffer_index = 0;
        }

        int iCopyLength = audio_buffer_size - audio_buffer_index;
        if(iCopyLength > iStreamSize) { iCopyLength = iStreamSize; }
        std::memcpy(pbStream, (uint8_t *)audio_buffer + audio_buffer_index, iCopyLength);
        iStreamSize -= iCopyLength;
        pbStream += iCopyLength;
        audio_buffer_index += iCopyLength;
    }
}

int movie_player::decode_audio_frame(bool fFirst)
{
#ifdef CORSIX_TH_MOVIE_USE_SEND_PACKET_API
    if (!audio_frame)
    {
        audio_frame = av_frame_alloc();
    }
    else
    {
        av_frame_unref(audio_frame);
    }

    int iError = get_frame(audio_stream_index, audio_frame);

    if (iError == AVERROR_EOF)
    {
        return 0;
    }
    else if (iError < 0)
    {
        std::cerr << "Unexpected error " << iError << " while decoding audio packet" << std::endl;
        return 0;
    }

    double dClockPts = get_presentation_time_for_frame(audio_frame, audio_stream_index);
    current_sync_pts = dClockPts;
    current_sync_pts_system_time = SDL_GetTicks();
#else
    int iGotFrame = 0;
    bool fNewPacket = false;
    bool fFlushComplete = false;

    while(!iGotFrame && !aborting)
    {
        if(!audio_packet || audio_packet->size == 0)
        {
            if(audio_packet)
            {
                audio_packet->data = audio_packet_data;
                audio_packet->size = audio_packet_size;
                av_packet_unref(audio_packet);
                av_free(audio_packet);
                audio_packet = nullptr;
            }
            audio_packet = audio_queue->pull(true);
            if(aborting)
            {
                break;
            }

            audio_packet_data = audio_packet->data;
            audio_packet_size = audio_packet->size;

            if(audio_packet == nullptr)
            {
                fNewPacket = false;
                return -1;
            }
            fNewPacket = true;

            if(audio_packet->data == flush_packet->data)
            {
                avcodec_flush_buffers(audio_codec_context);
                fFlushComplete = false;
            }
        }

        if(fFirst)
        {
            int64_t iStreamPts = audio_packet->pts;
            if(iStreamPts != AV_NOPTS_VALUE)
            {
                //There is a time_base in audio_codec_context too, but that one is wrong.
                double dClockPts = iStreamPts * av_q2d(format_context->streams[audio_stream_index]->time_base);
                current_sync_pts = dClockPts;
                current_sync_pts_system_time = SDL_GetTicks();
            }
            fFirst = false;
        }

        while(audio_packet->size > 0 || (!audio_packet->data && fNewPacket))
        {
            if(!audio_frame)
            {
                audio_frame = av_frame_alloc();
            }
            else
            {
                av_frame_unref(audio_frame);
            }

            if(fFlushComplete)
            {
                break;
            }

            fNewPacket = false;

            int iBytesConsumed = avcodec_decode_audio4(audio_codec_context, audio_frame, &iGotFrame, audio_packet);

            if(iBytesConsumed < 0)
            {
                audio_packet->size = 0;
                break;
            }
            audio_packet->data += iBytesConsumed;
            audio_packet->size -= iBytesConsumed;

            if(!iGotFrame)
            {
                if(audio_packet->data && (audio_codec_context->codec->capabilities & CODEC_CAP_DELAY))
                {
                    fFlushComplete = true;
                }
            }
        }
    }
#endif
    //over-estimate output samples
    int iOutSamples = (int)av_rescale_rnd(audio_frame->nb_samples, mixer_frequency, audio_codec_context->sample_rate, AV_ROUND_UP);
    int iSampleSize = av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) * iOutSamples * mixer_channels;

    if(iSampleSize > audio_buffer_max_size)
    {
        if(audio_buffer_max_size > 0)
        {
            av_free(audio_buffer);
        }
        audio_buffer = (uint8_t*)av_malloc(iSampleSize);
        audio_buffer_max_size = iSampleSize;
    }

#ifdef CORSIX_TH_USE_FFMPEG
    swr_convert(audio_resample_context, &audio_buffer, iOutSamples, (const uint8_t**)&audio_frame->data[0], audio_frame->nb_samples);
#elif defined(CORSIX_TH_USE_LIBAV)
    avresample_convert(audio_resample_context, &audio_buffer, 0, iOutSamples, (uint8_t**)&audio_frame->data[0], 0, audio_frame->nb_samples);
#endif
    return iSampleSize;
}
#else //CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV
movie_player::movie_player() {}
movie_player::~movie_player() {}
void movie_player::set_renderer(SDL_Renderer *renderer) {}
bool movie_player::movies_enabled() const { return false; }
bool movie_player::load(const char* file_path) { return true; }
void movie_player::unload() {}
void movie_player::play(int iChannel)
{
    SDL_Event endEvent;
    endEvent.type = SDL_USEREVENT_MOVIE_OVER;
    SDL_PushEvent(&endEvent);
}
void movie_player::stop() {}
int movie_player::get_native_height() const { return 0; }
int movie_player::get_native_width() const  { return 0; }
bool movie_player::has_audio_track() const  { return false; }
const char* movie_player::get_last_error() const { return nullptr; }
void movie_player::clear_last_error() {}
void movie_player::refresh(const SDL_Rect &destination_rect) {}
void movie_player::allocate_picture_buffer() {}
void movie_player::deallocate_picture_buffer() {}
void movie_player::read_streams() {}
void movie_player::run_video() {}
void movie_player::copy_audio_to_stream(uint8_t *stream, int length) {}
#endif //CORSIX_TH_USE_FFMPEG


