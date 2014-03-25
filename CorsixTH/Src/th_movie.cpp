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

#include "th_gfx.h"
extern "C"
{
    #include <libavcodec/avcodec.h>
    #include <libswscale/swscale.h>
    #include <libavutil/avutil.h>
    #include <libavutil/opt.h>
}
#include <SDL_mixer.h>
#include <iostream>

#define INBUF_SIZE 4096
#define AUDIO_BUFFER_SIZE 1024

int th_movie_stream_reader_thread(void* pState)
{
    THMovie *pMovie = (THMovie *)pState;
    pMovie->readStreams();
    return 0;
}

int th_movie_video_thread(void* pState)
{
    THMovie *pMovie = (THMovie *)pState;
    pMovie->runVideo();
    return 0;
}

void th_movie_audio_callback(int iChannel, void *pStream, int iStreamSize, void *pUserData)
{
    THMovie *pMovie = (THMovie *)pUserData;
    pMovie->copyAudioToStream((uint8_t*)pStream, iStreamSize);
}

THMoviePicture::THMoviePicture():
    m_pOverlay(NULL),
    m_pixelFormat(PIX_FMT_YUV420P),
    m_pSurface(NULL)
{
    m_pMutex = SDL_CreateMutex();
    m_pCond = SDL_CreateCond();
}

THMoviePicture::~THMoviePicture()
{
    if(m_pOverlay && m_pSurface == SDL_GetVideoSurface())
    {
        SDL_FreeYUVOverlay(m_pOverlay);
        m_pOverlay = NULL;
    }
    SDL_DestroyMutex(m_pMutex);
    SDL_DestroyCond(m_pCond);
}

void THMoviePicture::allocate(int iX, int iY, int iWidth, int iHeight)
{
    m_iX = iX;
    m_iY = iY;
    m_iWidth = iWidth;
    m_iHeight = iHeight;
    SDL_Surface* pSurface = SDL_GetVideoSurface();
    if(m_pOverlay)
    {
        if(m_pSurface == pSurface)
        {
            SDL_FreeYUVOverlay(m_pOverlay);
        }
        std::cerr << "THMovie overlay should be deallocated before being allocated!";
    }
    m_pSurface = pSurface;
    m_pOverlay = SDL_CreateYUVOverlay(m_iWidth, m_iHeight, SDL_YV12_OVERLAY, pSurface);
    if(m_pOverlay == NULL || m_pOverlay->pitches[0] < m_iWidth)
    {
        std::cerr << "Problem creating overlay: " << SDL_GetError() << "\n";
        return;
    }
}

void THMoviePicture::deallocate()
{
    if(m_pOverlay)
    {
        if(m_pSurface == SDL_GetVideoSurface())
        {
            SDL_FreeYUVOverlay(m_pOverlay);
        }
        else
        {
            std::cerr << "THMovie overlay must be deallocated before a surface change";
        }
        m_pOverlay = NULL;
    }
}

void THMoviePicture::draw()
{
    SDL_Rect rcDest;
    int iError;

    rcDest.x = m_iX;
    rcDest.y = m_iY;
    rcDest.w = m_iWidth;
    rcDest.h = m_iHeight;
    if(m_pOverlay && m_pSurface == SDL_GetVideoSurface())
    {
        iError = SDL_DisplayYUVOverlay(m_pOverlay, &rcDest);
        if(iError < 0)
        {
            std::cerr << "Error displaying overlay: " << SDL_GetError();
        }
    }
}

THMoviePictureBuffer::THMoviePictureBuffer():
    m_fAborting(false),
    m_fAllocated(false),
    m_iCount(0),
    m_iReadIndex(0),
    m_iWriteIndex(0),
    m_pSwsContext(NULL)
{
    m_pMutex = SDL_CreateMutex();
    m_pCond = SDL_CreateCond();
}

THMoviePictureBuffer::~THMoviePictureBuffer()
{
    SDL_DestroyCond(m_pCond);
    SDL_DestroyMutex(m_pMutex);
    sws_freeContext(m_pSwsContext);
}

void THMoviePictureBuffer::abort()
{
    m_fAborting = true;
    SDL_LockMutex(m_pMutex);
    SDL_CondSignal(m_pCond);
    SDL_UnlockMutex(m_pMutex);
}

void THMoviePictureBuffer::reset()
{
    m_fAborting = false;
}

void THMoviePictureBuffer::allocate(int iX, int iY, int iWidth, int iHeight)
{
    for(int i=0; i<PICTURE_BUFFER_SIZE; i++)
    {
        m_aPictureQueue[i].allocate(iX, iY, iWidth, iHeight);
    }
    //Do not change m_iWriteIndex, it's used by the other thread.
    //m_iReadIndex is only used in this thread.
    m_iReadIndex = m_iWriteIndex;
    SDL_LockMutex(m_pMutex);
    m_iCount = 0;
    m_fAllocated = true;
    SDL_CondSignal(m_pCond);
    SDL_UnlockMutex(m_pMutex);
}

void THMoviePictureBuffer::deallocate()
{
    SDL_LockMutex(m_pMutex);
    m_fAllocated = false;
    SDL_UnlockMutex(m_pMutex);
    for(int i=0; i<PICTURE_BUFFER_SIZE; i++)
    {
        SDL_LockMutex(m_aPictureQueue[i].m_pMutex);
        m_aPictureQueue[i].deallocate();
        SDL_UnlockMutex(m_aPictureQueue[i].m_pMutex);
    }
}

bool THMoviePictureBuffer::advance()
{
    if(empty()) { return false; }

    m_iReadIndex++;
    if(m_iReadIndex == PICTURE_BUFFER_SIZE)
    {
        m_iReadIndex = 0;
    }
    SDL_LockMutex(m_pMutex);
    m_iCount--;
    SDL_CondSignal(m_pCond);
    SDL_UnlockMutex(m_pMutex);

    return true;
}

void THMoviePictureBuffer::draw()
{
    if(!empty())
    {
        SDL_LockMutex(m_aPictureQueue[m_iReadIndex].m_pMutex);
        m_aPictureQueue[m_iReadIndex].draw();
        SDL_UnlockMutex(m_aPictureQueue[m_iReadIndex].m_pMutex);
    }
}

double THMoviePictureBuffer::getCurrentPts()
{
    if(empty()) { return 0; }
    return m_aPictureQueue[m_iReadIndex].m_dPts;
}

double THMoviePictureBuffer::getNextPts()
{
    double nextPts;
    SDL_LockMutex(m_pMutex);
    if(!m_fAllocated || m_iCount < 2)
    {
        nextPts = 0;
    }
    else
    {
        nextPts = m_aPictureQueue[(m_iReadIndex+1)%PICTURE_BUFFER_SIZE].m_dPts;
    }
    SDL_UnlockMutex(m_pMutex);
    return nextPts;
}

bool THMoviePictureBuffer::empty()
{
    bool empty;
    SDL_LockMutex(m_pMutex);
    empty = (!m_fAllocated || m_iCount == 0);
    SDL_UnlockMutex(m_pMutex);
    return empty;
}

bool THMoviePictureBuffer::full()
{
    bool full;
    SDL_LockMutex(m_pMutex);
    full = (!m_fAllocated || m_iCount == PICTURE_BUFFER_SIZE);
    SDL_UnlockMutex(m_pMutex);
    return full;
}

int THMoviePictureBuffer::write(AVFrame* pFrame, double dPts)
{
    THMoviePicture* pMoviePicture = NULL;
    SDL_LockMutex(m_pMutex);
    while(full() && !m_fAborting)
    {
        SDL_CondWait(m_pCond, m_pMutex);
    }
    SDL_UnlockMutex(m_pMutex);
    if(m_fAborting) { return -1; }

    pMoviePicture = &m_aPictureQueue[m_iWriteIndex];
    SDL_LockMutex(pMoviePicture->m_pMutex);

    if(pMoviePicture->m_pOverlay)
    {
        AVPicture picture = {};

        SDL_LockYUVOverlay(pMoviePicture->m_pOverlay);
        picture.data[0] = pMoviePicture->m_pOverlay->pixels[0];
        picture.data[1] = pMoviePicture->m_pOverlay->pixels[2];
        picture.data[2] = pMoviePicture->m_pOverlay->pixels[1];

        picture.linesize[0] = pMoviePicture->m_pOverlay->pitches[0];
        picture.linesize[1] = pMoviePicture->m_pOverlay->pitches[2];
        picture.linesize[2] = pMoviePicture->m_pOverlay->pitches[1];

        m_pSwsContext = sws_getCachedContext(m_pSwsContext, pFrame->width, pFrame->height, (PixelFormat)pFrame->format, pMoviePicture->m_iWidth, pMoviePicture->m_iHeight, pMoviePicture->m_pixelFormat, SWS_BICUBIC, NULL, NULL, NULL);
        if(m_pSwsContext == NULL)
        {
            SDL_UnlockMutex(m_aPictureQueue[m_iWriteIndex].m_pMutex);
            std::cerr << "Failed to initialize SwsContext";
            return 1;
        }

        sws_scale(m_pSwsContext, pFrame->data, pFrame->linesize, 0, pMoviePicture->m_iHeight, picture.data, picture.linesize);
        SDL_UnlockYUVOverlay(pMoviePicture->m_pOverlay);

        pMoviePicture->m_dPts = dPts;

        SDL_UnlockMutex(m_aPictureQueue[m_iWriteIndex].m_pMutex);
        m_iWriteIndex++;
        if(m_iWriteIndex == PICTURE_BUFFER_SIZE)
        {
            m_iWriteIndex = 0;
        }
        SDL_LockMutex(m_pMutex);
        m_iCount++;
        SDL_UnlockMutex(m_pMutex);
    }
    return 0;
}

THAVPacketQueue::THAVPacketQueue():
    iCount(0),
    m_pFirstPacket(NULL),
    m_pLastPacket(NULL)
{
    m_pMutex = SDL_CreateMutex();
    m_pCond = SDL_CreateCond();
}

THAVPacketQueue::~THAVPacketQueue()
{
    SDL_DestroyCond(m_pCond);
    SDL_DestroyMutex(m_pMutex);
}

int THAVPacketQueue::getCount()
{
    return iCount;
}

void THAVPacketQueue::push(AVPacket *pPacket)
{
    AVPacketList* pNode;
    if(av_dup_packet(pPacket) < 0) { throw -1; }

    pNode = (AVPacketList*)av_malloc(sizeof(AVPacketList));
    pNode->pkt = *pPacket;
    pNode->next = NULL;

    SDL_LockMutex(m_pMutex);

    if(m_pLastPacket == NULL)
    {
        m_pFirstPacket = pNode;
    }
    else
    {
        m_pLastPacket->next = pNode;
    }
    m_pLastPacket = pNode;
    iCount++;

    SDL_CondSignal(m_pCond);
    SDL_UnlockMutex(m_pMutex);
}

AVPacket* THAVPacketQueue::pull(bool fBlock)
{
    AVPacketList *pNode;
    AVPacket *pPacket;

    SDL_LockMutex(m_pMutex);

    pNode = m_pFirstPacket;
    if(pNode == NULL && fBlock)
    {
        SDL_CondWait(m_pCond, m_pMutex);
        pNode = m_pFirstPacket;
    }

    if(pNode == NULL)
    {
        pPacket = NULL;
    }
    else
    {
        m_pFirstPacket = pNode->next;
        if(m_pFirstPacket == NULL) { m_pLastPacket = NULL; }
        iCount--;

        pPacket = (AVPacket*)av_malloc(sizeof(AVPacket));
        *pPacket = pNode->pkt;
        av_free(pNode);
    }

    SDL_UnlockMutex(m_pMutex);

    return pPacket;
}

void THAVPacketQueue::release()
{
    SDL_LockMutex(m_pMutex);
    SDL_CondSignal(m_pCond);
    SDL_UnlockMutex(m_pMutex);
}

THMovie::THMovie():
    m_sLastError(),
    m_pFormatContext(NULL),
    m_pVideoCodecContext(NULL),
    m_pAudioCodecContext(NULL),
    m_pVideoQueue(NULL),
    m_pAudioQueue(NULL),
    m_pMoviePictureBuffer(new THMoviePictureBuffer()),
    m_pSwrContext(NULL),
    m_iAudioBufferSize(0),
    m_iAudioBufferMaxSize(0),
    m_frame(NULL),
    m_pChunk(NULL),
    m_iChannel(-1),
    m_pStreamThread(NULL),
    m_pVideoThread(NULL),
    m_pAudioPacket(NULL)
{
    av_register_all();

    m_flushPacket = (AVPacket*)av_malloc(sizeof(AVPacket));
    av_init_packet(m_flushPacket);
    m_flushPacket->data = (uint8_t *)"FLUSH";
    m_flushPacket->size = 5;

    m_pbChunkBuffer = (uint8_t*)malloc(AUDIO_BUFFER_SIZE);
    memset(m_pbChunkBuffer, 0, AUDIO_BUFFER_SIZE);
}

THMovie::~THMovie()
{
    unload();

    av_free_packet(m_flushPacket);
    av_free(m_flushPacket);
    free(m_pbChunkBuffer);
}

bool THMovie::moviesEnabled()
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

    iError = avformat_open_input(&m_pFormatContext, szFilepath, NULL, NULL);
    if(iError < 0)
    {
        av_strerror(iError, m_szErrorBuffer, MOVIE_ERROR_BUFFER_SIZE);
        m_sLastError = std::string(m_szErrorBuffer);
        return false;
    }

    iError = avformat_find_stream_info(m_pFormatContext, NULL);
    if(iError < 0)
    {
        av_strerror(iError, m_szErrorBuffer, MOVIE_ERROR_BUFFER_SIZE);
        m_sLastError = std::string(m_szErrorBuffer);
        return false;
    }

    m_iVideoStream = av_find_best_stream(m_pFormatContext, AVMEDIA_TYPE_VIDEO, -1, -1, &m_pVideoCodec, 0);
    m_pVideoCodecContext = m_pFormatContext->streams[m_iVideoStream]->codec;
    avcodec_open2(m_pVideoCodecContext, m_pVideoCodec, NULL);

    m_iAudioStream = av_find_best_stream(m_pFormatContext, AVMEDIA_TYPE_AUDIO, -1, -1, &m_pAudioCodec, 0);
    if(m_iAudioStream >= 0)
    {
        m_pAudioCodecContext = m_pFormatContext->streams[m_iAudioStream]->codec;
        avcodec_open2(m_pAudioCodecContext, m_pAudioCodec, NULL);
    }

    return true;
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

    if(m_pStreamThread)
    {
        SDL_WaitThread(m_pStreamThread, NULL);
        m_pStreamThread = NULL;
    }
    if(m_pVideoThread)
    {
        SDL_WaitThread(m_pVideoThread, NULL);
        m_pVideoThread = NULL;
    }

    //wait until after other threads are closed to clear the packet queues
    //so we don't free something being used.
    if(m_pAudioQueue)
    {
        while(m_pAudioQueue->getCount() > 0)
        {
            AVPacket* p = m_pAudioQueue->pull(false);
            av_free_packet(p);
        }
        delete m_pAudioQueue;
        m_pAudioQueue = NULL;
    }
    if(m_pVideoQueue)
    {
        while(m_pVideoQueue->getCount() > 0)
        {
            AVPacket* p = m_pVideoQueue->pull(false);
            av_free_packet(p);
        }
        delete m_pVideoQueue;
        m_pVideoQueue = NULL;
    }
    m_pMoviePictureBuffer->deallocate();

    if(m_iChannel >= 0)
    {
        Mix_UnregisterAllEffects(m_iChannel);
        Mix_HaltChannel(m_iChannel);
        Mix_FreeChunk(m_pChunk);
        m_iChannel = -1;
    }

    if(m_iAudioBufferMaxSize > 0)
    {
        av_free(m_pbAudioBuffer);
        m_iAudioBufferMaxSize = 0;
    }

    if(m_pVideoCodecContext)
    {
        avcodec_close(m_pVideoCodecContext);
        m_pVideoCodecContext = NULL;
    }
    if(m_pAudioCodecContext)
    {
        avcodec_close(m_pAudioCodecContext);
        m_pAudioCodecContext = NULL;
    }
    if(m_pFormatContext)
    {
        avformat_close_input(&m_pFormatContext);
    }

    if(m_frame)
    {
        av_free(m_frame);
        m_frame = NULL;
    }

    swr_free(&m_pSwrContext);

    if(m_pAudioPacket)
    {
        m_pAudioPacket->data = m_pbAudioPacketData;
        m_pAudioPacket->size = m_iAudioPacketSize;
        av_free_packet(m_pAudioPacket);
        av_free(m_pAudioPacket);
        m_pAudioPacket = NULL;
        m_pbAudioPacketData = NULL;
        m_iAudioPacketSize = 0;
    }
}

void THMovie::play(int iX, int iY, int iWidth, int iHeight, int iChannel)
{
    m_iX = iX;
    m_iY = iY;
    m_iWidth = iWidth;
    m_iHeight = iHeight;

    #ifdef CORSIX_TH_USE_OGL_RENDERER
    SDL_Surface* pSurface = SDL_GetVideoSurface();
    SDL_SetVideoMode(pSurface->w, pSurface->h, 0, pSurface->flags & ~SDL_OPENGL);
    #endif
    m_frame = NULL;

    m_pVideoQueue = new THAVPacketQueue();
    m_pMoviePictureBuffer->reset();
    m_pMoviePictureBuffer->allocate(m_iX, m_iY, m_iWidth, m_iHeight);

    m_pAudioPacket = NULL;
    m_iAudioPacketSize = 0;
    m_pbAudioPacketData = NULL;

    m_iAudioBufferSize = 0;
    m_iAudioBufferIndex = 0;
    m_iAudioBufferMaxSize = 0;

    m_pAudioQueue = new THAVPacketQueue();
    m_iCurSyncPts = 0;
    m_iCurSyncPtsSystemTime = SDL_GetTicks();

    if(m_iAudioStream >= 0)
    {
        Mix_QuerySpec(&m_iMixerFrequency, NULL, &m_iMixerChannels);
        m_pSwrContext = swr_alloc_set_opts(
            m_pSwrContext,
            m_iMixerChannels==1?AV_CH_LAYOUT_MONO:AV_CH_LAYOUT_STEREO,
            AV_SAMPLE_FMT_S16,
            m_iMixerFrequency,
            m_pAudioCodecContext->channel_layout,
            m_pAudioCodecContext->sample_fmt,
            m_pAudioCodecContext->sample_rate,
            0,
            NULL);
        swr_init(m_pSwrContext);

        m_pChunk = Mix_QuickLoad_RAW(m_pbChunkBuffer, AUDIO_BUFFER_SIZE);

        m_iChannel = Mix_PlayChannel(iChannel, m_pChunk, -1);
        if(m_iChannel < 0)
        {
            m_iChannel = -1;
            m_sLastError = std::string(Mix_GetError());
        }
        else
        {
            Mix_RegisterEffect(m_iChannel, th_movie_audio_callback, NULL, this);
        }
    }

    m_pStreamThread = SDL_CreateThread(th_movie_stream_reader_thread, this);
    m_pVideoThread = SDL_CreateThread(th_movie_video_thread, this);
}

void THMovie::stop()
{
    m_fAborting = true;
}

int THMovie::getNativeHeight()
{
    int iHeight = 0;

    if(m_pVideoCodecContext)
    {
        iHeight = m_pVideoCodecContext->height;
    }
    return iHeight;
}

int THMovie::getNativeWidth()
{
    int iWidth = 0;

    if(m_pVideoCodecContext)
    {
        iWidth = m_pVideoCodecContext->width;
    }
    return iWidth;
}

bool THMovie::hasAudioTrack()
{
    return (m_iAudioStream >= 0);
}

bool THMovie::requiresVideoReset()
{
#ifdef CORSIX_TH_USE_OGL_RENDERER
    return true;
#else
    return false;
#endif
}

const char* THMovie::getLastError()
{
    return m_sLastError.c_str();
}

void THMovie::clearLastError()
{
    m_sLastError.clear();
}

void THMovie::refresh()
{
    if(!m_pMoviePictureBuffer->empty())
    {
        double dCurTime = SDL_GetTicks() - m_iCurSyncPtsSystemTime + m_iCurSyncPts * 1000.0;
        double dCurPts = m_pMoviePictureBuffer->getCurrentPts();
        double dNextPts = m_pMoviePictureBuffer->getNextPts();

        //don't play a frame too early
        if(dCurPts > 0)
        {
            if(dCurPts * 1000.0 > dCurTime)
            {
                return;
            }
        }

        //if we have another frame and it's time has already passed, drop the current frame
        if(dNextPts > 0 && dNextPts * 1000.0 < dCurTime)
        {
            m_pMoviePictureBuffer->advance();
        }

        m_pMoviePictureBuffer->draw();
        m_pMoviePictureBuffer->advance();
    }
}

void THMovie::allocatePictureBuffer()
{
    m_pMoviePictureBuffer->allocate(m_iX, m_iY, m_iWidth, m_iHeight);
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
                av_free_packet(&packet);
            }
        }
    }

    while(!m_fAborting)
    {
        if(m_pVideoQueue->getCount() == 0 && m_pAudioQueue->getCount() == 0 && m_pMoviePictureBuffer->empty())
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
    AVFrame *pFrame = avcodec_alloc_frame();
    int64_t iStreamPts = AV_NOPTS_VALUE;
    double dClockPts;
    int iError;

    while(!m_fAborting)
    {
        avcodec_get_frame_defaults(pFrame);

        iError = getVideoFrame(pFrame, &iStreamPts);
        if(iError < 0)
        {
            break;
        }
        else if(iError == 0)
        {
            continue;
        }

        dClockPts = iStreamPts * av_q2d(m_pVideoCodecContext->time_base);
        iError = m_pMoviePictureBuffer->write(pFrame, dClockPts);

        if(iError < 0)
        {
            break;
        }
    }

    avcodec_flush_buffers(m_pVideoCodecContext);
    av_free(pFrame);
}

int THMovie::getVideoFrame(AVFrame *pFrame, int64_t *piPts)
{
    int iGotPicture = 0;
    int iError;

    AVPacket *pPacket = m_pVideoQueue->pull(true);
    if(pPacket == NULL)
    {
        return -1;
    }

    if(pPacket->data == m_flushPacket->data)
    {
        //TODO: Flush

        return 0;
    }

    iError = avcodec_decode_video2(m_pVideoCodecContext, pFrame, &iGotPicture, pPacket);
    av_free_packet(pPacket);
    av_free(pPacket);

    if(iError < 0)
    {
        return 0;
    }

    if(iGotPicture)
    {
        iError = 1;

#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(54, 18, 100)
        *piPts = *(int64_t*)av_opt_ptr(avcodec_get_frame_class(), pFrame, "best_effort_timestamp");
#else
        *piPts = av_frame_get_best_effort_timestamp(pFrame);
#endif

        if(*piPts == AV_NOPTS_VALUE)
        {
            *piPts = 0;
        }
        return iError;
    }
    return 0;
}

void THMovie::copyAudioToStream(uint8_t *pbStream, int iStreamSize)
{
    int iAudioSize;
    int iCopyLength;
    bool fFirst = true;

    while(iStreamSize > 0)
    {
        if(m_iAudioBufferIndex >= m_iAudioBufferSize)
        {
            iAudioSize = decodeAudioFrame(fFirst);
            fFirst = false;

            if(iAudioSize <= 0)
            {
                memset(m_pbAudioBuffer, 0, m_iAudioBufferSize);
            }
            else
            {
                m_iAudioBufferSize = iAudioSize;
            }
            m_iAudioBufferIndex = 0;
        }

        iCopyLength = m_iAudioBufferSize - m_iAudioBufferIndex;
        if(iCopyLength > iStreamSize) { iCopyLength = iStreamSize; }
        memcpy(pbStream, (uint8_t *)m_pbAudioBuffer + m_iAudioBufferIndex, iCopyLength);
        iStreamSize -= iCopyLength;
        pbStream += iCopyLength;
        m_iAudioBufferIndex += iCopyLength;
    }
}

int THMovie::decodeAudioFrame(bool fFirst)
{
    int iBytesConsumed = 0;
    int iSampleSize = 0;
    int iOutSamples;
    int iGotFrame = 0;
    bool fNewPacket = false;
    bool fFlushComplete = false;
    double dClockPts;
    int64_t iStreamPts;

    while(!iGotFrame && !m_fAborting)
    {
        if(!m_pAudioPacket || m_pAudioPacket->size == 0)
        {
            if(m_pAudioPacket)
            {
                m_pAudioPacket->data = m_pbAudioPacketData;
                m_pAudioPacket->size = m_iAudioPacketSize;
                av_free_packet(m_pAudioPacket);
                av_free(m_pAudioPacket);
                m_pAudioPacket = NULL;
            }
            m_pAudioPacket = m_pAudioQueue->pull(true);
            if(m_fAborting)
            {
                break;
            }

            m_pbAudioPacketData = m_pAudioPacket->data;
            m_iAudioPacketSize = m_pAudioPacket->size;

            if(m_pAudioPacket == NULL)
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
            iStreamPts = m_pAudioPacket->pts;
            if(iStreamPts != AV_NOPTS_VALUE)
            {
                //There is a time_base in m_pAudioCodecContext too, but that one is wrong.
                dClockPts = iStreamPts * av_q2d(m_pFormatContext->streams[m_iAudioStream]->time_base);
                m_iCurSyncPts = dClockPts;
                m_iCurSyncPtsSystemTime = SDL_GetTicks();
            }
            fFirst = false;
        }

        while(m_pAudioPacket->size > 0 || (!m_pAudioPacket->data && fNewPacket))
        {
            if(!m_frame)
            {
                m_frame = avcodec_alloc_frame();
            }
            else
            {
                avcodec_get_frame_defaults(m_frame);
            }

            if(fFlushComplete)
            {
                break;
            }

            fNewPacket = false;

            iBytesConsumed = avcodec_decode_audio4(m_pAudioCodecContext, m_frame, &iGotFrame, m_pAudioPacket);

            if(iBytesConsumed < 0)
            {
                m_pAudioPacket->size = 0;
                break;
            }
            m_pAudioPacket->data += iBytesConsumed;
            m_pAudioPacket->size -= iBytesConsumed;

            if(!iGotFrame)
            {
                if(m_pAudioPacket->data && m_pAudioCodecContext->codec->capabilities & CODEC_CAP_DELAY)
                {
                    fFlushComplete = true;
                }
            }
        }
    }

#if LIBSWRESAMPLE_VERSION_INT < AV_VERSION_INT(0, 12, 100)
    //over-estimate output samples
    iOutSamples = (int)av_rescale_rnd(m_frame->nb_samples, m_iMixerFrequency, m_pAudioCodecContext->sample_rate, AV_ROUND_UP);
    iSampleSize = av_get_bytes_per_sample(AV_SAMPLE_FMT_S16) * iOutSamples * m_iMixerChannels;

    if(iSampleSize > m_iAudioBufferMaxSize)
    {
        if(m_iAudioBufferMaxSize > 0)
        {
            av_free(m_pbAudioBuffer);
        }
        m_pbAudioBuffer = (uint8_t*)av_malloc(iSampleSize);
        m_iAudioBufferMaxSize = iSampleSize;
    }
#else
    //output samples = (input samples + delay) * output rate / input rate
    iOutSamples = (int)av_rescale_rnd(
        swr_get_delay(
            m_pSwrContext,
            m_pAudioCodecContext->sample_rate) + m_frame->nb_samples,
            m_iMixerFrequency,
            m_pAudioCodecContext->sample_rate,
            AV_ROUND_UP);
    iSampleSize = av_samples_get_buffer_size(NULL, m_iMixerChannels, iOutSamples, AV_SAMPLE_FMT_S16, 0);

    if(iSampleSize > m_iAudioBufferMaxSize)
    {
        if(m_iAudioBufferMaxSize > 0)
        {
            av_free(m_pbAudioBuffer);
        }
        av_samples_alloc(&m_pbAudioBuffer, NULL, m_iMixerChannels, iOutSamples, AV_SAMPLE_FMT_S16, 0);
        m_iAudioBufferMaxSize = iSampleSize;
    }
#endif

    swr_convert(m_pSwrContext, &m_pbAudioBuffer, iOutSamples, (const uint8_t**)&m_frame->data[0], m_frame->nb_samples);

    return iSampleSize;
}
#else //CORSIX_TH_USE_FFMPEG
THMovie::THMovie() {}
THMovie::~THMovie() {}
bool THMovie::moviesEnabled() { return false; }
bool THMovie::load(const char* filepath) { return true; }
void THMovie::unload() {}
void THMovie::play(int iX, int iY, int iWidth, int iHeight, int iChannel)
{
    SDL_Event endEvent;
    endEvent.type = SDL_USEREVENT_MOVIE_OVER;
    SDL_PushEvent(&endEvent);
}
void THMovie::stop() {}
int THMovie::getNativeHeight() { return 0; }
int THMovie::getNativeWidth() { return 0; }
bool THMovie::hasAudioTrack() { return false; }
bool THMovie::requiresVideoReset() { return false; }
const char* THMovie::getLastError() { return NULL; }
void THMovie::clearLastError() {}
void THMovie::refresh() {}
void THMovie::allocatePictureBuffer() {}
void THMovie::deallocatePictureBuffer() {}
void THMovie::readStreams() {}
void THMovie::runVideo() {}
void THMovie::copyAudioToStream(uint8_t *stream, int length) {}
#endif //CORSIX_TH_USE_FFMPEG


