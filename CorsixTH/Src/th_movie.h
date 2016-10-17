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

#include <string>
#include <queue>
#include "SDL.h"
#include "config.h"

#if (defined(CORSIX_TH_USE_FFMPEG) || defined(CORSIX_TH_USE_LIBAV)) && defined(CORSIX_TH_USE_SDL_MIXER)
#include "SDL_mixer.h"

extern "C"
{
#ifndef INT64_C
#define INT64_C(c) (c ## LL)
#define UINT64_C(c) (c ## ULL)
#endif
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libswscale/swscale.h>
#ifdef CORSIX_TH_USE_FFMPEG
#include <libswresample/swresample.h>
#elif defined(CORSIX_TH_USE_LIBAV)
#include <libavresample/avresample.h>
#endif
}

#if (defined(CORSIX_TH_USE_FFMEPG) && LIBAVUTIL_VERSION_INT < AV_VERSION_INT(51, 74, 100)) || \
    (defined(CORSIX_TH_USE_LIBAV) && LIBAVUTIL_VERSION_INT < AV_VERSION_INT(51, 42, 0))
#define AVPixelFormat PixelFormat
#define AV_PIX_FMT_RBG24 PIX_FMT_RGB24
#endif

//! \brief A picture in THMoviePictureBuffer
//!
//! Stores the picture from a frame in the movie from the time that it is
//! processed until it should be drawn.
class THMoviePicture
{
public:
    THMoviePicture();
    ~THMoviePicture();

    //! Allocate the buffer to hold a picture of the given size
    void allocate(int iWidth, int iHeight);

    //! Delete the buffer
    void deallocate();

    uint8_t* m_pBuffer; ///< Pixel data in #m_pixelFormat
    const AVPixelFormat m_pixelFormat; ///< The format of pixels to output
    int m_iWidth; ///< Picture width
    int m_iHeight; ///< Picture height
    double m_dPts; ///< Presentation time stamp
    SDL_mutex *m_pMutex; ///< Mutex protecting this picture
    SDL_cond *m_pCond; ///< Condition for signaling this picture
};

//! A buffer for holding movie pictures and drawing them to the renderer
class THMoviePictureBuffer
{
public:
    THMoviePictureBuffer();
    ~THMoviePictureBuffer();

    //NB: The following functions are called by the main program thread

    //! Indicate that processing should stop and the movie aborted
    void abort();

    //! Resume after having aborted
    void reset();

    //! Ready the picture buffer for a new renderer or new picture dimensions
    //! by allocating each THMoviePicture in the queue, resetting the read
    //! index and allocating a new texture.
    //!
    //! \remark Must be run on the program's graphics thread
    void allocate(SDL_Renderer *pRenderer, int iWidth, int iHeight);

    //! Destroy the associated texture and deallocate each of the
    //! THMoviePictures in the queue so that the program can release
    //! the renderer
    //!
    //! \remark Must be run on the program's graphics thread
    void deallocate();

    //! Advance the read index
    bool advance();

    //! Draw the THMoviePicture at the current read index
    //!
    //! \param pRenderer The renderer to draw the picture to
    //! \param dstrect The rectangle on the renderer to draw to
    //!
    //! \remark Must be run on the program's graphics thread
    void draw(SDL_Renderer *pRenderer, const SDL_Rect &dstrect);

    //! Get the next presentation time stamp
    double getNextPts();

    //! Return whether there are any pictures left to draw in the picture queue
    //!
    //! \remark If the THPictureBuffer is not allocated it cannot be read from
    //! or written to. Consequently it is both full and empty.
    bool empty();

    //NB: These functions are called by a second thread

    //! Return whether there is space to add any more frame data to the queue
    //!
    //! \remark If the THPictureBuffer is not allocated it cannot be read from
    //! or written to. Consequently it is both full and empty.
    bool full();

    //! Write the given frame (and presentation time stamp) to the picture
    //! queue
    //!
    //! \retval 0 Success
    //! \retval -1 Abort is in progress
    //! \retval 1 An error writing the frame
    int write(AVFrame* pFrame, double dPts);
private:
    static const size_t ms_pictureBufferSize = 4; ///< The number of elements to allocate in the picture queue
    bool m_fAborting; ///< Whether we are in the process of aborting
    bool m_fAllocated; ///< Whether the picture buffer has been allocated (and hasn't since been deallocated)
    int m_iCount; ///< The number of elements currently written to the picture queue
    int m_iReadIndex; ///< The position in the picture queue to be read next
    int m_iWriteIndex; ///< The position in the picture queue to be written to next
    SwsContext* m_pSwsContext; ///< The context for software scaling and pixel conversion when writing to the picture queue
    SDL_Texture *m_pTexture; ///< The (potentially hardware) texture to draw the picture to. In OpenGL this should only be accessed on the main thread
    SDL_mutex *m_pMutex; ///< A mutex for restricting access to the picture buffer to a single thread
    SDL_cond *m_pCond; ///< A condition for indicating access to the picture buffer
    THMoviePicture m_aPictureQueue[ms_pictureBufferSize]; ///< The picture queue, a looping FIFO queue of THMoviePictures
};

//! The AVPacketQueue is a thread safe queue of movie packets
class THAVPacketQueue
{
public:
    //! Construct a new empty packet queue
    THAVPacketQueue();

    //! Destroy the packet queue.
    //!
    //! \remarks Does not free the included packets. The packet queue should be
    //! flushed before it is destroyed.
    ~THAVPacketQueue();

    //! Push a new packet on the back of the queue
    void push(AVPacket *packet);

    //! Pull the packet from the front of the queue
    //!
    //! \param block Whether to block if the queue is empty or immediately
    //! return a nullptr
    AVPacket* pull(bool block);

    //! Return the number of packets in the queue
    int getCount() const;

    //! Release a blocking pull without writing a new packet to the queue.
    void release();
private:
    AVPacketList *m_pFirstPacket; ///< The packet at the front of the queue
    AVPacketList *m_pLastPacket; ///< The packet at the end of the queue
    int iCount; ///< The number of packets in the queue
    SDL_mutex *m_pMutex; ///< A mutex restricting access to the packet queue to a single thread
    SDL_cond *m_pCond; ///< A condition to wait on for signaling the packet queue
};
#endif //CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV

//! Movie player for CorsixTH
//!
//! The movie player is designed to be preinitialized and used for multiple
//! movies. After initializing the movie player, call THMovie::setRenderer
//! to assign the current SDL renderer to the movie player. Then THMovie::load
//! the desired movie and finally THMovie::play it.
class THMovie
{
public:
    //! Construct a new THMovie
    THMovie();

    //! Destroy the THMovie
    ~THMovie();

    //! Assign the renderer on which to draw the movie
    void setRenderer(SDL_Renderer *pRenderer);

    //! Return whether movies were compiled into CorsixTH
    bool moviesEnabled() const;

    //! Load the movie with the given file name
    bool load(const char* szFilepath);

    //! Unload and free the currently loaded movie.
    //!
    //! \remark This is called by load before loading a new movie so it is
    //! unnecessary to explicitly call this method. There is no harm either.
    void unload();

    //! Play the currently loaded movie
    //!
    //! \param iChannel The audio channel to use
    void play(int iChannel);

    //! Stop the currently playing movie
    void stop();

    //! Return the original height of the movie
    int getNativeHeight() const;

    //! Return the original width of the movie
    int getNativeWidth() const;

    //! Return whether the movie has an audio stream
    bool hasAudioTrack() const;

    //! Return a text description of the last error encountered
    const char* getLastError() const;

    //! Clear the last error so that if there is no more errors before the next
    //! call to THMovie::getLastError() it will return an empty string.
    void clearLastError();

    //! Draw the next frame if it is time to do so
    //!
    //! \param destination_rect The location and dimensions in the renderer on
    //! which to draw the movie
    void refresh(const SDL_Rect &destination_rect);

    //! Deallocate the picture buffer and free any resources associated with it.
    //!
    //! \remark This destroys the textures and other resources that may lock
    //! the renderer from being deleted. If the target changes you would call
    //! this, then free and switch renderers in the outside program, then call
    //! THMovie::setRenderer and finally THMovie::allocatePictureBuffer.
    //! \remark Up to the size of the picture buffer frames may be lost during
    //! this process.
    void deallocatePictureBuffer();

    //! Allocate the picture buffer for the current renderer
    void allocatePictureBuffer();

    //! Read packets from the movie and allocate them to the appropriate stream
    //! packet queues. Signal if we have reached the end of the movie.
    //!
    //! \remark This should not be called externally. It is public as it is the
    //! entry point of a thread.
    void readStreams();

    //! Read video frames from the video packet queue and write them to the
    //! picture queue.
    //!
    //! \remark This should not be called externally. It is public as it is the
    //! entry point of a thread.
    void runVideo();

    //! Read audio from the audio packet queue, and copy it into the audio
    //! buffer for playback
    void copyAudioToStream(uint8_t *pbStream, int iStreamSize);

private:
#if (defined(CORSIX_TH_USE_FFMPEG) || defined(CORSIX_TH_USE_LIBAV)) && defined(CORSIX_TH_USE_SDL_MIXER)
    static const size_t ms_movieErrorBufferSize = 128; ///< Buffer to hold last error description
    static const size_t ms_audioBufferSize = 1024; ///< Buffer for audio playback

    //! Decode audio from the movie into a format suitable for playback
    int decodeAudioFrame(bool fFirst);

    //! Convert video packet data into a frame.
    //!
    //! \param pFrame An empty frame which gets populated by the data in the
    //! video packet queue.
    //! \param piPts A reference to be populated with the presentation
    //! timestamp of the frame.
    int getVideoFrame(AVFrame *pFrame, int64_t *piPts);

    SDL_Renderer *m_pRenderer; ///< The renderer to draw to

    //! A description of the last error
    std::string m_sLastError;

    //! A buffer for passing to ffmpeg to get error details
    char m_szErrorBuffer[ms_movieErrorBufferSize];

    bool m_fAborting; ///< Indicate that we are in process of aborting playback

    SDL_mutex *m_pDecodingAudioMutex; ///< Synchronize access to #m_pAudioBuffer

    AVFormatContext* m_pFormatContext; ///< Information related to the loaded movie and all of its streams
    int m_iVideoStream; ///< The index of the video stream
    int m_iAudioStream; ///< The index of the audio stream
    AVCodecContext* m_pVideoCodecContext; ///< The video codec and information related to video
    AVCodecContext* m_pAudioCodecContext; ///< The audio codec and information related to audio

    //queues for transferring data between threads
    THAVPacketQueue *m_pVideoQueue; ///< Packets from the video stream
    THAVPacketQueue *m_pAudioQueue; ///< Packets from the audio stream
    THMoviePictureBuffer *m_pMoviePictureBuffer; ///< Buffer of processed video

    //clock sync parameters
    int m_iCurSyncPtsSystemTime; ///< System time matching #m_iCurSyncPts
    double m_iCurSyncPts; ///< The current presentation time stamp (from the audio stream)

#ifdef CORSIX_TH_USE_FFMPEG
    SwrContext* m_pAudioResampleContext; ///< Context for resampling audio for playback with ffmpeg
#elif defined(CORSIX_TH_USE_LIBAV)
    AVAudioResampleContext* m_pAudioResampleContext; ///< Context for resampling audio for playback with libav
#endif

    int m_iAudioBufferSize; ///< The current size of audio data in #m_pbAudioBuffer
    int m_iAudioBufferIndex; ///< The current position for writing in #m_pbAudioBuffer
    int m_iAudioBufferMaxSize; ///< The capacity of #m_pbAudioBuffer (allocated size)
    uint8_t* m_pbAudioBuffer; ///< An audio buffer for playback

    AVPacket* m_pAudioPacket; ///< The current audio packet being decoded (audio frames don't necessarily line up with packets)
    int m_iAudioPacketSize; ///< The size of #m_pbAudioPacketData
    uint8_t *m_pbAudioPacketData; ///< Original data for #m_pAudioPacket, kept so that it can be freed after the packet is processed
    AVFrame* m_audio_frame; ///< The frame we are decoding audio into

    Mix_Chunk* m_pChunk; ///< Empty chunk needed for SDL_mixer
    uint8_t* m_pbChunkBuffer; ///< 0'd out buffer for the SDL_Mixer chunk

    int m_iChannel; ///< The channel to play audio on, -1 for none
    int m_iMixerChannels; ///< How many channels to play on (1 - mono, 2 - stereo)
    int m_iMixerFrequency; ///< The frequency of audio expected by SDL_Mixer

    AVPacket* m_flushPacket; ///< A representative packet indicating a flush is required.

    SDL_Thread* m_pStreamThread; ///< The thread responsible for reading the movie streams
    SDL_Thread* m_pVideoThread; ///< The thread responsible for decoding the video stream
#endif //CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV
};

#endif // TH_VIDEO_H
