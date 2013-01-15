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

#ifndef TH_VIDEO_H
#define TH_VIDEO_H
#define PICTURE_BUFFER_SIZE 4

#include <string>
#include <queue>
#include "config.h"
#include "th_gfx.h"
#include "th_sound.h"
#include "SDL_mixer.h"

#ifdef CORSIX_TH_USE_FFMPEG
extern "C"
{
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libswresample/swresample.h>
#include <libswscale/swscale.h>
}

class THMoviePicture
{
public:
    SDL_Overlay *m_pOverlay;
    int m_iX, m_iY, m_iWidth, m_iHeight;
    double m_dPts;
    bool m_fAllocated;
    bool m_fReallocate;
    PixelFormat m_pixelFormat;

    THMoviePicture();
    ~THMoviePicture();
    void allocate();
    void deallocate();
    void draw();
};

class THAVPacketQueue
{
public:
    THAVPacketQueue();
    ~THAVPacketQueue();
    void push(AVPacket *packet);
    AVPacket* pull(bool block);
    int getCount();
    void release();
private:
    AVPacketList *m_pFirstPacket, *m_pLastPacket;
    int iCount;
    SDL_mutex *m_pMutex;
    SDL_cond *m_pCond;
};
#endif //CORSIX_TH_USE_FFMPEG

class THMovie
{
public:
    THMovie();
    ~THMovie();

    bool moviesEnabled();
    void load(const char* szFilepath);
    void unload();
    void play(int iX, int iY, int iWidth, int iHeight, int iChannel);
    void stop();
    int getNativeHeight();
    int getNativeWidth();
    bool hasAudioTrack();
    bool requiresVideoReset();
    void refresh();
    void copyAudioToStream(Uint8 *pbStream, int iStreamSize);
    void runVideo();
    void allocatePicture();
    void readStreams();
protected:
#ifdef CORSIX_TH_USE_FFMPEG
    int decodeAudioFrame();
    int getVideoFrame(AVFrame *pFrame, int64_t *piPts);
    int queuePicture(AVFrame *pFrame, double dPts);
    void advancePictureQueue();

    int m_iX;
    int m_iY;
    int m_iWidth;
    int m_iHeight;

    AVFormatContext* m_pFormatContext;
    int m_iVideoStream;
    int m_iAudioStream;
    AVCodec* m_pVideoCodec;
    AVCodec* m_pAudioCodec;
    AVCodecContext* m_pVideoCodecContext;
    AVCodecContext* m_pAudioCodecContext;

    THAVPacketQueue *m_pVideoQueue;

    SDL_mutex *m_pPictureQueueMutex;
    SDL_cond *m_pPictureQueueCond;
    THMoviePicture m_aPictureQueue[PICTURE_BUFFER_SIZE];
    int m_iPictureQueueWriteIndex;
    int m_iPictureQueueReadIndex;
    int m_iPictureQueueSize;

    //tick when video was started in ms
    int m_iStartTime;

    THAVPacketQueue *m_pAudioQueue;

    //audio buffer
    int m_iAudioBufferSize;
    int m_iAudioBufferIndex;
    int m_iAudioBufferMaxSize;
    uint8_t* m_pbAudioBuffer;

    int m_iChannel;
    Uint8* m_pbChunkBuffer;
    Mix_Chunk* m_pChunk;

    int m_iMixerChannels;
    int m_iMixerFrequency;
    SwrContext* m_pSwrContext;

    bool m_fAborting;

    AVPacket* m_pAudioPacket;
    int m_iAudioPacketSize;
    uint8_t *m_pbAudioPacketData;

    AVPacket* m_flushPacket;

    AVFrame* m_frame;
    SwsContext* m_pSwsContext;

    SDL_Thread* m_pStreamThread;
    SDL_Thread* m_pRefreshThread;
    SDL_Thread* m_pVideoThread;
#endif //CORSIX_TH_USE_FFMPEG
};

#endif // TH_VIDEO_H
