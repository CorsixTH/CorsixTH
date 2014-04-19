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
#define MOVIE_ERROR_BUFFER_SIZE 128

#include <string>
#include <queue>
#include "config.h"

#ifdef CORSIX_TH_USE_FFMPEG
#include "SDL_mixer.h"

extern "C"
{
#ifndef INT64_C
#define INT64_C(c) (c ## LL)
#define UINT64_C(c) (c ## ULL)
#endif
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libswresample/swresample.h>
#include <libswscale/swscale.h>
}

struct SDL_Renderer;
struct SDL_Texture;
struct SDL_Window;
struct SDL_mutex;
struct SDL_cond;
typedef void* SDL_GLContext;

class THMoviePicture
{
public:
    THMoviePicture();
    ~THMoviePicture();

    void allocate(SDL_Renderer *pRenderer, int iX, int iY, int iWidth, int iHeight);
    void deallocate();
    void draw(SDL_Renderer *pRenderer);

    SDL_Texture *m_pTexture;
    PixelFormat m_pixelFormat;
    int m_iX, m_iY, m_iWidth, m_iHeight;
    double m_dPts;
    SDL_mutex *m_pMutex;
    SDL_cond *m_pCond;
};

class THMoviePictureBuffer
{
public:
    THMoviePictureBuffer();
    ~THMoviePictureBuffer();

    //NB: The following functions are called by the main program thread
    void abort();
    void reset();
    void allocate(SDL_Renderer *pRenderer, int iX, int iY, int iWidth, int iHeight);
    void deallocate();
    bool advance();
    void draw(SDL_Renderer *pRenderer);
    double getNextPts();
    bool empty();

    //NB: These functions are called by a second thread
    bool full();
    int write(AVFrame* pFrame, double dPts);
protected:
    bool m_fAborting;
    bool m_fAllocated;
    int m_iCount;
    int m_iReadIndex;
    int m_iWriteIndex;
    SwsContext* m_pSwsContext;
    SDL_mutex *m_pMutex;
    SDL_cond *m_pCond;
    THMoviePicture m_aPictureQueue[PICTURE_BUFFER_SIZE];
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

    void setRenderer(SDL_Renderer *pRenderer);

    bool moviesEnabled();

    bool load(const char* szFilepath);
    void unload();

    void play(int iX, int iY, int iWidth, int iHeight, int iChannel);
    void stop();

    int getNativeHeight();
    int getNativeWidth();
    bool hasAudioTrack();
    bool requiresVideoReset();

    const char* getLastError();
    void clearLastError();

    void refresh();
    void deallocatePictureBuffer();
    void allocatePictureBuffer();

    void readStreams();
    void runVideo();
    void copyAudioToStream(uint8_t *pbStream, int iStreamSize);
protected:
#ifdef CORSIX_TH_USE_FFMPEG
    int decodeAudioFrame(bool fFirst);
    int getVideoFrame(AVFrame *pFrame, int64_t *piPts);

    SDL_Renderer *m_pRenderer;
    SDL_GLContext m_shareContext;
    // Sadly we have to keep this around, since SDL_GL_MakeCurrent requires a window.
    SDL_Window *m_pShareWindow;

    //last error
    std::string m_sLastError;
    char m_szErrorBuffer[MOVIE_ERROR_BUFFER_SIZE];

    //abort playing movie
    bool m_fAborting;

    //current movie dimensions and placement
    int m_iX, m_iY, m_iWidth, m_iHeight;

    //ffmpeg movie information
    AVFormatContext* m_pFormatContext;
    int m_iVideoStream;
    int m_iAudioStream;
    AVCodecContext* m_pVideoCodecContext;
    AVCodecContext* m_pAudioCodecContext;

    //queues for transfering data between threads
    THAVPacketQueue *m_pVideoQueue;
    THAVPacketQueue *m_pAudioQueue;
    THMoviePictureBuffer *m_pMoviePictureBuffer;

    //clock sync parameters
    int m_iCurSyncPtsSystemTime;
    double m_iCurSyncPts;

    //audio resample context
    SwrContext* m_pSwrContext;

    //decoded audio buffer
    int m_iAudioBufferSize;
    int m_iAudioBufferIndex;
    int m_iAudioBufferMaxSize;
    uint8_t* m_pbAudioBuffer;

    //decoding audio packet
    AVPacket* m_pAudioPacket;
    int m_iAudioPacketSize;
    uint8_t *m_pbAudioPacketData;

    //decoding audio frame
    AVFrame* m_frame;

    //empty raw chunk for SDL_mixer
    Mix_Chunk* m_pChunk;
    uint8_t* m_pbChunkBuffer;

    //SDL_mixer parameters
    int m_iChannel;
    int m_iMixerChannels;
    int m_iMixerFrequency;

    //signal packet indicating flush
    AVPacket* m_flushPacket;

    //threads
    SDL_Thread* m_pStreamThread;
    SDL_Thread* m_pVideoThread;
#endif //CORSIX_TH_USE_FFMPEG
};

#endif // TH_VIDEO_H
