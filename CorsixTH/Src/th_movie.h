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

#include "config.h"

#include <atomic>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <string>
#include <thread>

#include "SDL.h"

#if (defined(CORSIX_TH_USE_FFMPEG) || defined(CORSIX_TH_USE_LIBAV)) && \
    defined(CORSIX_TH_USE_SDL_MIXER)
#include "SDL_mixer.h"

extern "C" {
#ifndef INT64_C
#define INT64_C(c) (c##LL)
#define UINT64_C(c) (c##ULL)
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

//! \brief Functor for deleting AVPackets
//!
//! Deletes AVPacket pointers that are allocated with av_malloc
class av_packet_deleter {
 public:
  void operator()(AVPacket* p) {
    av_packet_unref(p);
    av_free(p);
  }
};

//! \brief unique_ptr for AVPackets
using av_packet_unique_ptr = std::unique_ptr<AVPacket, av_packet_deleter>;

class av_frame_deleter {
 public:
  void operator()(AVFrame* f) { av_frame_free(&f); }
};

using av_frame_unique_ptr = std::unique_ptr<AVFrame, av_frame_deleter>;

//! \brief A picture in movie_picture_buffer
//!
//! Stores the picture from a frame in the movie from the time that it is
//! processed until it should be drawn.
class movie_picture {
 public:
  movie_picture();
  ~movie_picture();

  //! Allocate the buffer to hold a picture of the given size
  void allocate(int iWidth, int iHeight);

  //! Delete the buffer
  void deallocate();

  uint8_t* buffer;                   ///< Pixel data in #m_pixelFormat
  const AVPixelFormat pixel_format;  ///< The format of pixels to output
  int width;                         ///< Picture width
  int height;                        ///< Picture height
  double pts;                        ///< Presentation time stamp
  std::mutex mutex;                  ///< Mutex protecting this picture
};

//! A buffer for holding movie pictures and drawing them to the renderer
class movie_picture_buffer {
 public:
  movie_picture_buffer();
  ~movie_picture_buffer();

  // NB: The following functions are called by the main program thread

  //! Indicate that processing should stop and the movie aborted
  void abort();

  //! Resume after having aborted
  void reset();

  //! Ready the picture buffer for a new renderer or new picture dimensions
  //! by allocating each movie_picture in the queue, resetting the read
  //! index and allocating a new texture.
  //!
  //! \remark Must be run on the program's graphics thread
  void allocate(SDL_Renderer* pRenderer, int iWidth, int iHeight);

  //! Destroy the associated texture and deallocate each of the
  //! movie_pictures in the queue so that the program can release
  //! the renderer
  //!
  //! \remark Must be run on the program's graphics thread
  void deallocate();

  //! Advance the read index
  bool advance();

  //! Draw the movie_picture at the current read index
  //!
  //! \param pRenderer The renderer to draw the picture to
  //! \param dstrect The rectangle on the renderer to draw to
  //!
  //! \remark Must be run on the program's graphics thread
  void draw(SDL_Renderer* pRenderer, const SDL_Rect& dstrect);

  //! Get the next presentation time stamp
  double get_next_pts();

  //! Return whether there are any pictures left to draw in the picture queue
  //!
  //! \remark If the movie_picture_buffer is not allocated it cannot be read
  //! from or written to. Consequently it is both full and empty.
  bool empty();

  // NB: These functions are called by a second thread

  //! Return whether there is space to add any more frame data to the queue
  //!
  //! \remark If the movie_picture_buffer is not allocated it cannot be read
  //! from or written to. Consequently it is both full and empty.
  bool full();

  //! Write the given frame (and presentation time stamp) to the picture
  //! queue
  //!
  //! \retval 0 Success
  //! \retval -1 Abort is in progress
  //! \retval 1 An error writing the frame
  int write(AVFrame* pFrame, double dPts);

 private:
  //! Return whether there is space to add any more frame data to the queue
  //!
  //! \remark Requires external locking
  bool unsafe_full();

  static constexpr size_t picture_buffer_size =
      4;  ///< The number of elements to allocate in the picture queue
  std::atomic<bool> aborting;  ///< Whether we are in the process of aborting
  bool allocated;     ///< Whether the picture buffer has been allocated (and
                      ///< hasn't since been deallocated)
  int picture_count;  ///< The number of elements currently written to the
                      ///< picture queue
  int read_index;     ///< The position in the picture queue to be read next
  int write_index;    ///< The position in the picture queue to be written to
                      ///< next
  SwsContext* sws_context;  ///< The context for software scaling and pixel
                            ///< conversion when writing to the picture queue
  SDL_Texture* texture;     ///< The (potentially hardware) texture to draw the
                            ///< picture to. In OpenGL this should only be
                            ///< accessed on the main thread
  std::mutex mutex;  ///< A mutex for restricting access to the picture buffer
                     ///< to a single thread
  std::condition_variable
      cond;  ///< A condition for indicating access to the picture buffer
  movie_picture picture_queue[picture_buffer_size];  ///< The picture queue, a
                                                     ///< looping FIFO queue
                                                     ///< of movie_pictures
};

//! The AVPacketQueue is a thread safe queue of movie packets
class av_packet_queue {
 public:
  //! Construct a new empty packet queue
  av_packet_queue();

  //! Destroy the packet queue.
  //!
  //! \remarks Does not free the included packets. The packet queue should be
  //! flushed before it is destroyed.
  ~av_packet_queue() = default;

  //! Push a new packet on the back of the queue
  void push(av_packet_unique_ptr packet);

  //! Pull the packet from the front of the queue
  //!
  //! \param block Whether to block if the queue is empty or immediately
  //! return a nullptr
  av_packet_unique_ptr pull(bool block);

  //! Return the number of packets in the queue
  std::size_t get_count() const;

  //! Release a blocking pull without writing a new packet to the queue.
  void release();

  //! Release and free the entire contents of the queue
  void clear();

 private:
  std::queue<av_packet_unique_ptr> data;  ///< The packets in the queue
  std::mutex mutex;  ///< A mutex restricting access to the packet queue to a
                     ///< single thread
  std::condition_variable
      cond;  ///< A condition to wait on for signaling the packet queue
};
#endif  // CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV

//! Movie player for CorsixTH
//!
//! The movie player is designed to be preinitialized and used for multiple
//! movies. After initializing the movie player, call movie_player::set_renderer
//! to assign the current SDL renderer to the movie player. Then
//! movie_player::load the desired movie and finally movie_player::play it.
class movie_player {
 public:
  //! Construct a new movie_player
  movie_player();

  //! Destroy the movie_player
  ~movie_player();

  //! Assign the renderer on which to draw the movie.
  //!
  //! movie_player does not take ownership of the render, it is up to the
  //! caller to delete it, after deleting movie_player or setting a different
  //! renderer.
  void set_renderer(SDL_Renderer* pRenderer);

  //! Return whether movies were compiled into CorsixTH
  bool movies_enabled() const;

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
  int get_native_height() const;

  //! Return the original width of the movie
  int get_native_width() const;

  //! Return whether the movie has an audio stream
  bool has_audio_track() const;

  //! Return a text description of the last error encountered
  const char* get_last_error() const;

  //! Clear the last error so that if there is no more errors before the next
  //! call to movie_player::get_last_error() it will return an empty string.
  void clear_last_error();

  //! Draw the next frame if it is time to do so
  //!
  //! \param destination_rect The location and dimensions in the renderer on
  //! which to draw the movie
  void refresh(const SDL_Rect& destination_rect);

  //! Deallocate the picture buffer and free any resources associated with it.
  //!
  //! \remark This destroys the textures and other resources that may lock
  //! the renderer from being deleted. If the target changes you would call
  //! this, then free and switch renderers in the outside program, then call
  //! movie_player::set_renderer and finally
  //! movie_player::allocate_picture_buffer. \remark Up to the size of the
  //! picture buffer frames may be lost during this process.
  void deallocate_picture_buffer();

  //! Allocate the picture buffer for the current renderer
  void allocate_picture_buffer();

  //! Read packets from the movie and allocate them to the appropriate stream
  //! packet queues. Signal if we have reached the end of the movie.
  //!
  //! \remark This should not be called externally. It is public as it is the
  //! entry point of a thread.
  void read_streams();

  //! Read video frames from the video packet queue and write them to the
  //! picture queue.
  //!
  //! \remark This should not be called externally. It is public as it is the
  //! entry point of a thread.
  void run_video();

  //! Read audio from the audio packet queue, and copy it into the audio
  //! buffer for playback
  void copy_audio_to_stream(uint8_t* pbStream, int iStreamSize);

 private:
#if (defined(CORSIX_TH_USE_FFMPEG) || defined(CORSIX_TH_USE_LIBAV)) && \
    defined(CORSIX_TH_USE_SDL_MIXER)
  static constexpr size_t movie_error_buffer_capacity =
      128;  ///< Buffer to hold last error description
  static constexpr size_t audio_chunk_buffer_capacity =
      1024;  ///< Buffer for audio playback

  //! Get the AVCodecContext associated with a given stream
  AVCodecContext* get_codec_context_for_stream(AVCodec* codec,
                                               AVStream* stream) const;

  //! Get the time the given frame should be played (from the start of the
  //! stream)
  //!
  //! \param frame The video or audio frame
  //! \param streamIndex The position of the stream in m_pFormatContexts
  //! streams array
  double get_presentation_time_for_frame(AVFrame* frame, int streamIndex) const;

  //! Decode audio from the movie into a format suitable for playback
  int decode_audio_frame(bool fFirst);

  //! Convert packet data into frames
  //!
  //! \param stream The index of the stream to get the frame for
  //! \param pFrame An empty frame which gets populated by the data in the
  //! packet queue.
  //! \returns FFMPEG result of avcodec_recieve_frame
  int get_frame(int stream, AVFrame* pFrame);

  SDL_Renderer* renderer;  ///< The renderer to draw to

  //! A description of the last error
  std::string last_error;

  //! A buffer for passing to ffmpeg to get error details
  char error_buffer[movie_error_buffer_capacity];

  // TODO: Should be atomic
  bool aborting;  ///< Indicate that we are in process of aborting playback

  std::mutex decoding_audio_mutex;  ///< Synchronize access to #m_pAudioBuffer

  AVFormatContext* format_context;      ///< Information related to the loaded
                                        ///< movie and all of its streams
  int video_stream_index;               ///< The index of the video stream
  int audio_stream_index;               ///< The index of the audio stream
  AVCodecContext* video_codec_context;  ///< The video codec and information
                                        ///< related to video
  AVCodecContext* audio_codec_context;  ///< The audio codec and information
                                        ///< related to audio

  // queues for transferring data between threads
  av_packet_queue video_queue;  ///< Packets from the video stream
  av_packet_queue audio_queue;  ///< Packets from the audio stream
  ::movie_picture_buffer* movie_picture_buffer;  ///< Buffer of processed video

  // clock sync parameters
  int current_sync_pts_system_time;  ///< System time matching #m_iCurSyncPts
  double current_sync_pts;  ///< The current presentation time stamp (from the
                            ///< audio stream)

#ifdef CORSIX_TH_USE_FFMPEG
  SwrContext* audio_resample_context;  ///< Context for resampling audio for
                                       ///< playback with ffmpeg
#elif defined(CORSIX_TH_USE_LIBAV)
  AVAudioResampleContext*
      audio_resample_context;  ///< Context for resampling audio for
                               ///< playback with libav
#endif

  int audio_buffer_size;      ///< The current size of audio data in
                              ///< #m_pbAudioBuffer
  int audio_buffer_index;     ///< The current position for writing in
                              ///< #m_pbAudioBuffer
  int audio_buffer_max_size;  ///< The capacity of #m_pbAudioBuffer (allocated
                              ///< size)
  uint8_t* audio_buffer;      ///< An audio buffer for playback

  av_frame_unique_ptr audio_frame;  ///< The frame we are decoding audio into

  Mix_Chunk* empty_audio_chunk;  ///< Empty chunk needed for SDL_mixer
  uint8_t* audio_chunk_buffer;   ///< 0'd out buffer for the SDL_Mixer chunk

  int audio_channel;    ///< The channel to play audio on, -1 for none
  int mixer_channels;   ///< How many channels to play on (1 - mono, 2 -
                        ///< stereo)
  int mixer_frequency;  ///< The frequency of audio expected by SDL_Mixer

  std::thread stream_thread;  ///< The thread responsible for reading the
                              ///< movie streams
  std::thread video_thread;   ///< The thread responsible for decoding the
                              ///< video stream
#endif                        // CORSIX_TH_USE_FFMPEG || CORSIX_TH_USE_LIBAV
};

#endif  // TH_VIDEO_H
