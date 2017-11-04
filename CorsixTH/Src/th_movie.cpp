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
    THMovie *pMovie = (THMovie *)pUserData;
    pMovie->copyAudioToStream((uint8_t*)pStream, iStreamSize);
}

THMoviePicture::THMoviePicture():
    m_pBuffer(nullptr),
    m_pixelFormat(AV_PIX_FMT_RGB24),
    m_mutex{}
{}

THMoviePicture::~THMoviePicture()
{
    av_freep(&m_pBuffer);
}

void THMoviePicture::allocate(int iWidth, int iHeight)
{
    m_iWidth = iWidth;
    m_iHeight = iHeight;
    av_freep(&m_pBuffer);
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(54, 6, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(51, 63, 100))
    int numBytes = av_image_get_buffer_size(m_pixelFormat, m_iWidth, m_iHeight, 1);
#else
    int numBytes = avpicture_get_size(m_pixelFormat, m_iWidth, m_iHeight);
#endif
    m_pBuffer = static_cast<uint8_t*>(av_mallocz(numBytes));
}

void THMoviePicture::deallocate()
{
    av_freep(&m_pBuffer);
}

THMoviePictureBuffer::THMoviePictureBuffer():
    m_aborting(false),
    m_fAllocated(false),
    m_iCount(0),
    m_iReadIndex(0),
    m_iWriteIndex(0),
    m_pSwsContext(nullptr),
    m_pTexture(nullptr),
    m_mutex{},
    m_cond{}
{
}

THMoviePictureBuffer::~THMoviePictureBuffer()
{
    sws_freeContext(m_pSwsContext);
    if (m_pTexture)
    {
        SDL_DestroyTexture(m_pTexture);
        m_pTexture = nullptr;
    }
}

void THMoviePictureBuffer::abort()
{
    m_aborting = true;
    std::lock_guard<std::mutex> lock(m_mutex);
    m_cond.notify_all();
}

void THMoviePictureBuffer::reset()
{
    m_aborting = false;
}

void THMoviePictureBuffer::allocate(SDL_Renderer *pRenderer, int iWidth, int iHeight)
{
    if (m_pTexture)
    {
        SDL_DestroyTexture(m_pTexture);
        std::cerr << "THMovie overlay should be deallocated before being allocated!\n";
    }
    m_pTexture = SDL_CreateTexture(pRenderer, SDL_PIXELFORMAT_RGB24, SDL_TEXTUREACCESS_STREAMING, iWidth, iHeight);
    if (m_pTexture == nullptr)
    {
        std::cerr << "Problem creating overlay: " << SDL_GetError() << "\n";
        return;
    }
    for(int i = 0; i < ms_pictureBufferSize; i++)
    {
        m_aPictureQueue[i].allocate(iWidth, iHeight);
    }
    //Do not change m_iWriteIndex, it's used by the other thread.
    //m_iReadIndex is only used in this thread.
    m_iReadIndex = m_iWriteIndex;

    std::lock_guard<std::mutex> lock(m_mutex);
    m_iCount = 0;
    m_fAllocated = true;
    m_cond.notify_one();
}

void THMoviePictureBuffer::deallocate()
{
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_fAllocated = false;
    }

    for(int i = 0; i < ms_pictureBufferSize; i++)
    {
        std::lock_guard<std::mutex> pictureLock(m_aPictureQueue[i].m_mutex);
        m_aPictureQueue[i].deallocate();
    }

    if (m_pTexture)
    {
        SDL_DestroyTexture(m_pTexture);
        m_pTexture = nullptr;
    }
}

bool THMoviePictureBuffer::advance()
{
    if(empty()) { return false; }

    m_iReadIndex++;
    if(m_iReadIndex == ms_pictureBufferSize)
    {
        m_iReadIndex = 0;
    }

    std::lock_guard<std::mutex> lock(m_mutex);
    m_iCount--;
    m_cond.notify_one();

    return true;
}

void THMoviePictureBuffer::draw(SDL_Renderer *pRenderer, const SDL_Rect &dstrect)
{
    if(!empty())
    {
        auto cur_pic = &(m_aPictureQueue[m_iReadIndex]);

        std::lock_guard<std::mutex> pictureLock(cur_pic->m_mutex);
        if (cur_pic->m_pBuffer)
        {
            SDL_UpdateTexture(m_pTexture, nullptr, cur_pic->m_pBuffer, cur_pic->m_iWidth * 3);
            int iError = SDL_RenderCopy(pRenderer, m_pTexture, nullptr, &dstrect);
            if (iError < 0)
            {
                std::cerr << "Error displaying movie frame: " << SDL_GetError() << "\n";
            }
        }
    }
}

double THMoviePictureBuffer::getNextPts()
{
    double nextPts;
    std::lock_guard<std::mutex> lock(m_mutex);
    if(!m_fAllocated || m_iCount < 2)
    {
        nextPts = 0;
    }
    else
    {
        nextPts = m_aPictureQueue[(m_iReadIndex + 1) % ms_pictureBufferSize].m_dPts;
    }
    return nextPts;
}

bool THMoviePictureBuffer::empty()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return (!m_fAllocated || m_iCount == 0);
}

bool THMoviePictureBuffer::full()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return unsafeFull();
}

bool THMoviePictureBuffer::unsafeFull()
{
    return (!m_fAllocated || m_iCount == ms_pictureBufferSize);
}

int THMoviePictureBuffer::write(AVFrame* pFrame, double dPts)
{
    THMoviePicture* pMoviePicture = nullptr;
    std::unique_lock<std::mutex> picBufLock(m_mutex);
    while(unsafeFull() && !m_aborting)
    {
        m_cond.wait(picBufLock);
    }
    picBufLock.unlock();

    if(m_aborting) { return -1; }

    pMoviePicture = &m_aPictureQueue[m_iWriteIndex];
    std::unique_lock<std::mutex> pictureLock(pMoviePicture->m_mutex);

    if(pMoviePicture->m_pBuffer)
    {
        m_pSwsContext = sws_getCachedContext(m_pSwsContext, pFrame->width, pFrame->height, (AVPixelFormat)pFrame->format, pMoviePicture->m_iWidth, pMoviePicture->m_iHeight, pMoviePicture->m_pixelFormat, SWS_BICUBIC, nullptr, nullptr, nullptr);
        if(m_pSwsContext == nullptr)
        {
            std::cerr << "Failed to initialize SwsContext\n";
            return 1;
        }

        /* Allocate a new frame and buffer for the destination RGB24 data. */
        AVFrame *pFrameRGB = av_frame_alloc();
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(54, 6, 0)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVUTIL_VERSION_INT >= AV_VERSION_INT(51, 63, 100))
        av_image_fill_arrays(pFrameRGB->data, pFrameRGB->linesize, pMoviePicture->m_pBuffer, pMoviePicture->m_pixelFormat, pMoviePicture->m_iWidth, pMoviePicture->m_iHeight, 1);
#else
        avpicture_fill((AVPicture *)pFrameRGB, pMoviePicture->m_pBuffer, pMoviePicture->m_pixelFormat, pMoviePicture->m_iWidth, pMoviePicture->m_iHeight);
#endif

        /* Rescale the frame data and convert it to RGB24. */
        sws_scale(m_pSwsContext, pFrame->data, pFrame->linesize, 0, pFrame->height, pFrameRGB->data, pFrameRGB->linesize);

        av_frame_free(&pFrameRGB);

        pMoviePicture->m_dPts = dPts;

        pictureLock.unlock();
        m_iWriteIndex++;
        if(m_iWriteIndex == ms_pictureBufferSize)
        {
            m_iWriteIndex = 0;
        }
        picBufLock.lock();
        m_iCount++;
        picBufLock.unlock();
    }

    return 0;
}

THAVPacketQueue::THAVPacketQueue():
    m_pFirstPacket(nullptr),
    m_pLastPacket(nullptr),
    iCount(0),
    m_mutex{},
    m_cond{}
{
}

THAVPacketQueue::~THAVPacketQueue()
{
}

int THAVPacketQueue::getCount() const
{
    return iCount;
}

void THAVPacketQueue::push(AVPacket *pPacket)
{
#if (defined(CORSIX_TH_USE_LIBAV) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(57, 12, 100)) || \
    (defined(CORSIX_TH_USE_FFMPEG) && LIBAVCODEC_VERSION_INT < AV_VERSION_INT(57, 8, 0))
    if(av_dup_packet(pPacket) < 0) { throw -1; }
#endif

    AVPacketList* pNode = (AVPacketList*)av_malloc(sizeof(AVPacketList));
    pNode->pkt = *pPacket;
    pNode->next = nullptr;

    std::lock_guard<std::mutex> lock(m_mutex);

    if(m_pLastPacket == nullptr)
    {
        m_pFirstPacket = pNode;
    }
    else
    {
        m_pLastPacket->next = pNode;
    }
    m_pLastPacket = pNode;
    iCount++;

    m_cond.notify_one();
}

AVPacket* THAVPacketQueue::pull(bool fBlock)
{
    std::unique_lock<std::mutex> lock(m_mutex);

    AVPacketList* pNode = m_pFirstPacket;
    if(pNode == nullptr && fBlock)
    {
        m_cond.wait(lock);
        pNode = m_pFirstPacket;
    }

    AVPacket *pPacket;
    if(pNode == nullptr)
    {
        pPacket = nullptr;
    }
    else
    {
        m_pFirstPacket = pNode->next;
        if(m_pFirstPacket == nullptr) { m_pLastPacket = nullptr; }
        iCount--;

        pPacket = (AVPacket*)av_malloc(sizeof(AVPacket));
        *pPacket = pNode->pkt;
        av_free(pNode);
    }

    return pPacket;
}

void THAVPacketQueue::release()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    m_cond.notify_all();
}

THMovie::THMovie():
    m_pRenderer(nullptr),
    m_sLastError(),
    m_pFormatContext(nullptr),
    m_pVideoCodecContext(nullptr),
    m_pAudioCodecContext(nullptr),
    m_pVideoQueue(nullptr),
    m_pAudioQueue(nullptr),
    m_pMoviePictureBuffer(new THMoviePictureBuffer()),
    m_pAudioResampleContext(nullptr),
    m_iAudioBufferSize(0),
    m_iAudioBufferMaxSize(0),
    m_pAudioPacket(nullptr),
    m_audio_frame(nullptr),
    m_pChunk(nullptr),
    m_iChannel(-1),
    m_streamThread{},
    m_videoThread{},
    m_decodingAudioMutex{}
{
    av_register_all();

    m_flushPacket = (AVPacket*)av_malloc(sizeof(AVPacket));
    av_init_packet(m_flushPacket);
    m_flushPacket->data = (uint8_t *)"FLUSH";
    m_flushPacket->size = 5;

    m_pbChunkBuffer = (uint8_t*)std::calloc(ms_audioBufferSize, sizeof(uint8_t));
}

THMovie::~THMovie()
{
    unload();

    av_packet_unref(m_flushPacket);
    av_free(m_flushPacket);
    free(m_pbChunkBuffer);
}

void THMovie::setRenderer(SDL_Renderer *pRenderer)
{
    m_pRenderer = pRenderer;
}

bool THMovie::moviesEnabled() const
{
    return true;
}

bool THMovie::load(const char* szFilepath)
{
    int iError = 0;
    AVCodec* m_pVideoCodec;
    AVCodec* m_pAudioCodec;

    unload(); //Unload any currently loaded video to free memory
    m_fAborting = false;

    iError = avformat_open_input(&m_pFormatContext, szFilepath, nullptr, nullptr);
    if(iError < 0)
    {
        av_strerror(iError, m_szErrorBuffer, ms_movieErrorBufferSize);
        m_sLastError = std::string(m_szErrorBuffer);
        return false;
    }

    iError = avformat_find_stream_info(m_pFormatContext, nullptr);
    if(iError < 0)
    {
        av_strerror(iError, m_szErrorBuffer, ms_movieErrorBufferSize);
        m_sLastError = std::string(m_szErrorBuffer);
        return false;
    }

    m_iVideoStream = av_find_best_stream(m_pFormatContext, AVMEDIA_TYPE_VIDEO, -1, -1, &m_pVideoCodec, 0);
    m_pVideoCodecContext = getCodecContextForStream(m_pVideoCodec, m_pFormatContext->streams[m_iVideoStream]);
    avcodec_open2(m_pVideoCodecContext, m_pVideoCodec, nullptr);

    m_iAudioStream = av_find_best_stream(m_pFormatContext, AVMEDIA_TYPE_AUDIO, -1, -1, &m_pAudioCodec, 0);
    if(m_iAudioStream >= 0)
    {
        m_pAudioCodecContext = getCodecContextForStream(m_pAudioCodec, m_pFormatContext->streams[m_iAudioStream]);
        avcodec_open2(m_pAudioCodecContext, m_pAudioCodec, nullptr);
    }

    return true;
}

AVCodecContext* THMovie::getCodecContextForStream(AVCodec* codec, AVStream* stream) const
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

void THMovie::unload()
{
    m_fAborting = true;

    if(m_pAudioQueue)
    {
        m_pAudioQueue->release();
    }
    if(m_pVideoQueue)
    {
        m_pVideoQueue->release();
    }
    m_pMoviePictureBuffer->abort();

    if(m_streamThread.joinable())
    {
        m_streamThread.join();
    }
    if(m_videoThread.joinable())
    {
        m_videoThread.join();
    }

    //wait until after other threads are closed to clear the packet queues
    //so we don't free something being used.
    if(m_pAudioQueue)
    {
        while(m_pAudioQueue->getCount() > 0)
        {
            AVPacket* p = m_pAudioQueue->pull(false);
            av_packet_unref(p);
        }
        delete m_pAudioQueue;
        m_pAudioQueue = nullptr;
    }
    if(m_pVideoQueue)
    {
        while(m_pVideoQueue->getCount() > 0)
        {
            AVPacket* p = m_pVideoQueue->pull(false);
            av_packet_unref(p);
        }
        delete m_pVideoQueue;
        m_pVideoQueue = nullptr;
    }
    m_pMoviePictureBuffer->deallocate();

    if(m_pVideoCodecContext)
    {
        avcodec_close(m_pVideoCodecContext);
        m_pVideoCodecContext = nullptr;
    }

    if(m_iChannel >= 0)
    {
        Mix_UnregisterAllEffects(m_iChannel);
        Mix_HaltChannel(m_iChannel);
        Mix_FreeChunk(m_pChunk);
        m_iChannel = -1;
    }

    std::lock_guard<std::mutex> audioLock(m_decodingAudioMutex);

    if(m_iAudioBufferMaxSize > 0)
    {
        av_free(m_pbAudioBuffer);
        m_iAudioBufferMaxSize = 0;
    }
    if(m_pAudioCodecContext)
    {
        avcodec_close(m_pAudioCodecContext);
        m_pAudioCodecContext = nullptr;
    }
    av_frame_free(&m_audio_frame);

#ifdef CORSIX_TH_USE_FFMPEG
    swr_free(&m_pAudioResampleContext);
#elif defined(CORSIX_TH_USE_LIBAV)
    // avresample_free doesn't skip nullptr on it's own.
    if (m_pAudioResampleContext != nullptr)
    {
        avresample_free(&m_pAudioResampleContext);
        m_pAudioResampleContext = nullptr;
    }
#endif

    if(m_pAudioPacket)
    {
        m_pAudioPacket->data = m_pbAudioPacketData;
        m_pAudioPacket->size = m_iAudioPacketSize;
        av_packet_unref(m_pAudioPacket);
        av_free(m_pAudioPacket);
        m_pAudioPacket = nullptr;
        m_pbAudioPacketData = nullptr;
        m_iAudioPacketSize = 0;
    }

    if(m_pFormatContext)
    {
        avformat_close_input(&m_pFormatContext);
    }
}

void THMovie::play(int iChannel)
{
    if(!m_pRenderer)
    {
        m_sLastError = std::string("Cannot play before setting the renderer");
        return;
    }

    m_pVideoQueue = new THAVPacketQueue();
    m_pMoviePictureBuffer->reset();
    m_pMoviePictureBuffer->allocate(m_pRenderer, m_pVideoCodecContext->width, m_pVideoCodecContext->height);

    m_pAudioPacket = nullptr;
    m_iAudioPacketSize = 0;
    m_pbAudioPacketData = nullptr;

    m_iAudioBufferSize = 0;
    m_iAudioBufferIndex = 0;
    m_iAudioBufferMaxSize = 0;

    m_pAudioQueue = new THAVPacketQueue();
    m_iCurSyncPts = 0;
    m_iCurSyncPtsSystemTime = SDL_GetTicks();

    if(m_iAudioStream >= 0)
    {
        Mix_QuerySpec(&m_iMixerFrequency, nullptr, &m_iMixerChannels);
#ifdef CORSIX_TH_USE_FFMPEG
        m_pAudioResampleContext = swr_alloc_set_opts(
            m_pAudioResampleContext,
            m_iMixerChannels==1?AV_CH_LAYOUT_MONO:AV_CH_LAYOUT_STEREO,
            AV_SAMPLE_FMT_S16,
            m_iMixerFrequency,
            m_pAudioCodecContext->channel_layout,
            m_pAudioCodecContext->sample_fmt,
            m_pAudioCodecContext->sample_rate,
            0,
            nullptr);
        swr_init(m_pAudioResampleContext);
#elif defined(CORSIX_TH_USE_LIBAV)
        m_pAudioResampleContext = avresample_alloc_context();
        av_opt_set_int(m_pAudioResampleContext, "in_channel_layout", m_pAudioCodecContext->channel_layout, 0);
        av_opt_set_int(m_pAudioResampleContext, "out_channel_layout", m_iMixerChannels == 1 ? AV_CH_LAYOUT_MONO : AV_CH_LAYOUT_STEREO, 0);
        av_opt_set_int(m_pAudioResampleContext, "in_sample_rate", m_pAudioCodecContext->sample_rate, 0);
        av_opt_set_int(m_pAudioResampleContext, "out_sample_rate", m_iMixerFrequency, 0);
        av_opt_set_int(m_pAudioResampleContext, "in_sample_fmt", m_pAudioCodecContext->sample_fmt, 0);
        av_opt_set_int(m_pAudioResampleContext, "out_sample_fmt", AV_SAMPLE_FMT_S16, 0);
        avresample_open(m_pAudioResampleContext);
#endif
        m_pChunk = Mix_QuickLoad_RAW(m_pbChunkBuffer, ms_audioBufferSize);

        m_iChannel = Mix_PlayChannel(iChannel, m_pChunk, -1);
        if(m_iChannel < 0)
        {
            m_iChannel = -1;
            m_sLastError = std::string(Mix_GetError());
        }
        else
        {
            Mix_RegisterEffect(m_iChannel, th_movie_audio_callback, nullptr, this);
        }
    }

    m_streamThread = std::thread(&THMovie::readStreams, this);
    m_videoThread = std::thread(&THMovie::runVideo, this);
}

void THMovie::stop()
{
    m_fAborting = true;
}

int THMovie::getNativeHeight() const
{
    int iHeight = 0;

    if(m_pVideoCodecContext)
    {
        iHeight = m_pVideoCodecContext->height;
    }
    return iHeight;
}

int THMovie::getNativeWidth() const
{
    int iWidth = 0;

    if(m_pVideoCodecContext)
    {
        iWidth = m_pVideoCodecContext->width;
    }
    return iWidth;
}

bool THMovie::hasAudioTrack() const
{
    return (m_iAudioStream >= 0);
}

const char* THMovie::getLastError() const
{
    return m_sLastError.c_str();
}

void THMovie::clearLastError()
{
    m_sLastError.clear();
}

void THMovie::refresh(const SDL_Rect &destination_rect)
{
    SDL_Rect dest_rect;

    dest_rect = SDL_Rect{ destination_rect.x, destination_rect.y, destination_rect.w, destination_rect.h };

    if(!m_pMoviePictureBuffer->empty())
    {
        double dCurTime = SDL_GetTicks() - m_iCurSyncPtsSystemTime + m_iCurSyncPts * 1000.0;
        double dNextPts = m_pMoviePictureBuffer->getNextPts();

        if(dNextPts > 0 && dNextPts * 1000.0 <= dCurTime)
        {
            m_pMoviePictureBuffer->advance();
        }

        m_pMoviePictureBuffer->draw(m_pRenderer, dest_rect);
    }
}

void THMovie::allocatePictureBuffer()
{
    if(!m_pVideoCodecContext)
    {
        return;
    }
    m_pMoviePictureBuffer->allocate(m_pRenderer, getNativeWidth(), getNativeHeight());
}

void THMovie::deallocatePictureBuffer()
{
    m_pMoviePictureBuffer->deallocate();
}

void THMovie::readStreams()
{
    AVPacket packet;
    int iError;

    while(!m_fAborting)
    {
        iError = av_read_frame(m_pFormatContext, &packet);
        if(iError < 0)
        {
            if(iError == AVERROR_EOF || m_pFormatContext->pb->error || m_pFormatContext->pb->eof_reached)
            {
                break;
            }
        }
        else
        {
            if(packet.stream_index == m_iVideoStream)
            {
                m_pVideoQueue->push(&packet);
            }
            else if (packet.stream_index == m_iAudioStream)
            {
                m_pAudioQueue->push(&packet);
            }
            else
            {
                av_packet_unref(&packet);
            }
        }
    }

    while(!m_fAborting)
    {
        if(m_pVideoQueue->getCount() == 0 && m_pAudioQueue->getCount() == 0 && m_pMoviePictureBuffer->getNextPts() == 0)
        {
            break;
        }
        SDL_Delay(10);
    }

    SDL_Event endEvent;
    endEvent.type = SDL_USEREVENT_MOVIE_OVER;
    SDL_PushEvent(&endEvent);
    m_fAborting = true;
}

void THMovie::runVideo()
{
    AVFrame *pFrame = av_frame_alloc();
    double dClockPts;
    int iError;

    while(!m_fAborting)
    {
        av_frame_unref(pFrame);

#ifdef CORSIX_TH_MOVIE_USE_SEND_PACKET_API
        iError = getFrame(m_iVideoStream, pFrame);

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
        iError = getVideoFrame(pFrame);
        if(iError < 0)
        {
            break;
        }
        else if(iError == 0)
        {
            continue;
        }
#endif

        dClockPts = getPresentationTimeForFrame(pFrame, m_iVideoStream);
        iError = m_pMoviePictureBuffer->write(pFrame, dClockPts);

        if(iError < 0)
        {
            break;
        }
    }

    avcodec_flush_buffers(m_pVideoCodecContext);
    av_frame_free(&pFrame);
}

double THMovie::getPresentationTimeForFrame(AVFrame* frame, int streamIndex) const
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

    return pts * av_q2d(m_pFormatContext->streams[streamIndex]->time_base);
}

#ifdef CORSIX_TH_MOVIE_USE_SEND_PACKET_API
int THMovie::getFrame(int stream, AVFrame* pFrame)
{
    int iError = AVERROR(EAGAIN);
    AVCodecContext* ctx;
    THAVPacketQueue* pq;

    if (stream == m_iVideoStream)
    {
        ctx = m_pVideoCodecContext;
        pq = m_pVideoQueue;
    }
    else if (stream == m_iAudioStream)
    {
        ctx = m_pAudioCodecContext;
        pq = m_pAudioQueue;
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
int THMovie::getVideoFrame(AVFrame *pFrame)
{
    int iGotPicture = 0;
    int iError;

    AVPacket *pPacket = m_pVideoQueue->pull(true);
    if(pPacket == nullptr)
    {
        return -1;
    }

    if(pPacket->data == m_flushPacket->data)
    {
        //TODO: Flush

        return 0;
    }

    iError = avcodec_decode_video2(m_pVideoCodecContext, pFrame, &iGotPicture, pPacket);
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

void THMovie::copyAudioToStream(uint8_t *pbStream, int iStreamSize)
{
    std::lock_guard<std::mutex> audioLock(m_decodingAudioMutex);

    bool fFirst = true;
    while(iStreamSize > 0  && !m_fAborting)
    {
        if(m_iAudioBufferIndex >= m_iAudioBufferSize)
        {
            int iAudioSize = decodeAudioFrame(fFirst);
            fFirst = false;

            if(iAudioSize <= 0)
            {
                std::memset(m_pbAudioBuffer, 0, m_iAudioBufferSize);
            }
            else
            {
                m_iAudioBufferSize = iAudioSize;
            }
            m_iAudioBufferIndex = 0;
        }

        int iCopyLength = m_iAudioBufferSize - m_iAudioBufferIndex;
        if(iCopyLength > iStreamSize) { iCopyLength = iStreamSize; }
        std::memcpy(pbStream, (uint8_t *)m_pbAudioBuffer + m_iAudioBufferIndex, iCopyLength);
        iStreamSize -= iCopyLength;
        pbStream += iCopyLength;
        m_iAudioBufferIndex += iCopyLength;
    }
}

int THMovie::decodeAudioFrame(bool fFirst)
{
#ifdef CORSIX_TH_MOVIE_USE_SEND_PACKET_API
    if (!m_audio_frame)
    {
        m_audio_frame = av_frame_alloc();
    }
    else
    {
        av_frame_unref(m_audio_frame);
    }

    int iError = getFrame(m_iAudioStream, m_audio_frame);

    if (iError == AVERROR_EOF)
    {
        return 0;
    }
    else if (iError < 0)
    {
        std::cerr << "Unexpected error " << iError << " while decoding audio packet" << std::endl;
        return 0;
    }

    double dClockPts = getPresentationTimeForFrame(m_audio_frame, m_iAudioStream);
    m_iCurSyncPts = dClockPts;
    m_iCurSyncPtsSystemTime = SDL_GetTicks();
#else
    int iGotFrame = 0;
    bool fNewPacket = false;
    bool fFlushComplete = false;

    while(!iGotFrame && !m_fAborting)
    {
        if(!m_pAudioPacket || m_pAudioPacket->size == 0)
        {
            if(m_pAudioPacket)
            {
                m_pAudioPacket->data = m_pbAudioPacketData;
                m_pAudioPacket->size = m_iAudioPacketSize;
                av_packet_unref(m_pAudioPacket);
                av_free(m_pAudioPacket);
                m_pAudioPacket = nullptr;
            }
            m_pAudioPacket = m_pAudioQueue->pull(true);
            if(m_fAborting)
            {
                break;
            }

            m_pbAudioPacketData = m_pAudioPacket->data;
            m_iAudioPacketSize = m_pAudioPacket->size;

            if(m_pAudioPacket == nullptr)
            {
                fNewPacket = false;
                return -1;
            }
            fNewPacket = true;

            if(m_pAudioPacket->data == m_flushPacket->data)
            {
                avcodec_flush_buffers(m_pAudioCodecContext);
                fFlushComplete = false;
            }
        }

        if(fFirst)
        {
            int64_t iStreamPts = m_pAudioPacket->pts;
            if(iStreamPts != AV_NOPTS_VALUE)
            {
                //There is a time_base in m_pAudioCodecContext too, but that one is wrong.
                double dClockPts = iStreamPts * av_q2d(m_pFormatContext->streams[m_iAudioStream]->time_base);
                m_iCurSyncPts = dClockPts;
                m_iCurSyncPtsSystemTime = SDL_GetTicks();
            }
            fFirst = false;
        }

        while(m_pAudioPacket->size > 0 || (!m_pAudioPacket->data && fNewPacket))
        {
            if(!m_audio_frame)
            {
                m_audio_frame = av_frame_alloc();
            }
            else
            {
                av_frame_unref(m_audio_frame);
            }

            if(fFlushComplete)
            {
                break;
            }

            fNewPacket = false;

            int iBytesConsumed = avcodec_decode_audio4(m_pAudioCodecContext, m_audio_frame, &iGotFrame, m_pAudioPacket);

            if(iBytesConsumed < 0)
            {
                m_pAudioPacket->size = 0;
                break;
            }
            m_pAudioPacket->data += iBytesConsumed;
            m_pAudioPacket->size -= iBytesConsumed;

            if(!iGotFrame)
            {
                if(m_pAudioPacket->data && (m_pAudioCodecContext->codec->capabilities & CODEC_CAP_DELAY))
                {
                    fFlushComplete = true;
                }
            }
        }
    }
#endif
    //over-estimate output samples
    int iOutSamples = (int)av_rescale_rnd(m_audio_frame->nb_samples, m_iMixerFrequency, m_pAudioCodecContext->sample_rate, AV_ROUND_UP);
    int iSampleSize = av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) * iOutSamples * m_iMixerChannels;

    if(iSampleSize > m_iAudioBufferMaxSize)
    {
        if(m_iAudioBufferMaxSize > 0)
        {
            av_free(m_pbAudioBuffer);
        }
        m_pbAudioBuffer = (uint8_t*)av_malloc(iSampleSize);
        m_iAudioBufferMaxSize = iSampleSize;
    }

#ifdef CORSIX_TH_USE_FFMPEG
    swr_convert(m_pAudioResampleContext, &m_pbAudioBuffer, iOutSamples, (const uint8_t**)&m_audio_frame->data[0], m_audio_frame->nb_samples);
#elif defined(CORSIX_TH_USE_LIBAV)
    avresample_convert(m_pAudioResampleContext, &m_pbAudioBuffer, 0, iOutSamples, (uint8_t**)&m_audio_frame->data[0], 0, m_audio_frame->nb_samples);
#endif
    return iSampleSize;
}
#else //CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV
THMovie::THMovie() {}
THMovie::~THMovie() {}
void THMovie::setRenderer(SDL_Renderer *pRenderer) {}
bool THMovie::moviesEnabled() const { return false; }
bool THMovie::load(const char* filepath) { return true; }
void THMovie::unload() {}
void THMovie::play(int iChannel)
{
    SDL_Event endEvent;
    endEvent.type = SDL_USEREVENT_MOVIE_OVER;
    SDL_PushEvent(&endEvent);
}
void THMovie::stop() {}
int THMovie::getNativeHeight() const { return 0; }
int THMovie::getNativeWidth() const  { return 0; }
bool THMovie::hasAudioTrack() const  { return false; }
const char* THMovie::getLastError() const { return nullptr; }
void THMovie::clearLastError() {}
void THMovie::refresh(const SDL_Rect &destination_rect) {}
void THMovie::allocatePictureBuffer() {}
void THMovie::deallocatePictureBuffer() {}
void THMovie::readStreams() {}
void THMovie::runVideo() {}
void THMovie::copyAudioToStream(uint8_t *stream, int length) {}
#endif //CORSIX_TH_USE_FFMPEG


