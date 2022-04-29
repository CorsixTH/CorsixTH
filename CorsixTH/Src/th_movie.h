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

#include <SDL.h>

#include <array>
#include <atomic>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <string>
#include <thread>

#if defined(CORSIX_TH_USE_FFMPEG) && defined(CORSIX_TH_USE_SDL_MIXER)
#include <SDL_mixer.h>

extern "C" {
#ifndef INT64_C
#define INT64_C(c) (c##LL)
#define UINT64_C(c) (c##ULL)
#endif
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/avutil.h>
#include <libswresample/swresample.h>
#include <libswscale/swscale.h>
}

#if LIBAVCODEC_VERSION_INT < AV_VERSION_INT(59, 0, 100)
using av_codec_ptr = AVCodec*;
#else
using av_codec_ptr = const AVCodec*;
#endif

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

class av_codec_context_deleter {
 public:
  void operator()(AVCodecContext* c) { avcodec_free_context(&c); }
};

using av_codec_context_unique_ptr =
    std::unique_ptr<AVCodecContext, av_codec_context_deleter>;

//! \brief Functor for deleting Mix_Chunks
//!
//! Should be moved to a common mixer header when uses of Mix_Chunk outside of
//! movies are converted to unique_ptr.
class mix_chunk_deleter {
 public:
  void operator()(Mix_Chunk* c) { Mix_FreeChunk(c); }
};

using mix_chunk_unique_ptr = std::unique_ptr<Mix_Chunk, mix_chunk_deleter>;

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

  //! The number of elements to allocate in the picture queue
  static constexpr std::size_t picture_buffer_size = 4;

  //! Whether we are in the process of aborting
  std::atomic<bool> aborting;

  //! Whether the picture buffer is currently allocated
  bool allocated;

  //! The number of elements currently written to the picture queue
  int picture_count;

  //! The position in the picture queue to be read next
  std::size_t read_index;

  //! The position in the picture queue to be written to next
  std::size_t write_index;

  //! The context for software scaling and pixel conversion when writing to the
  //! picture queue
  SwsContext* sws_context;

  //! The (potentially hardware) texture to draw the picture to. In OpenGL this
  //! should only be accessed on the main thread
  SDL_Texture* texture;

  //! A mutex for restricting access to the picture buffer to a single thread
  std::mutex mutex;

  //! A condition for indicating access to the picture buffer
  std::condition_variable cond;

  //! The picture queue, FIFO ring buffer of movie_pictures
  std::array<movie_picture, picture_buffer_size> picture_queue;
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
#endif  // CORSIX_TH_USE_FFMPEG

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
#if defined(CORSIX_TH_USE_FFMPEG) && defined(CORSIX_TH_USE_SDL_MIXER)
  static constexpr size_t movie_error_buffer_capacity =
      128;  ///< Buffer to hold last error description

  //! Get the AVCodecContext associated with a given stream
  av_codec_context_unique_ptr get_codec_context_for_stream(
      av_codec_ptr codec, AVStream* stream) const;

  //! Get the time the given frame should be played (from the start of the
  //! stream)
  //!
  //! \param frame The video or audio frame
  //! \param streamIndex The position of the stream in m_pFormatContexts
  //! streams array
  double get_presentation_time_for_frame(const AVFrame& frame,
                                         int streamIndex) const;

  //! Decode audio from the movie into a format suitable for playback
  int decode_audio_frame(uint8_t* stream, int stream_size);

  //! Convert packet data into frames
  //!
  //! \param stream The index of the stream to get the frame for
  //! \param frame An empty frame which gets populated by the data in the
  //! packet queue.
  //! \returns FFMPEG result of avcodec_receive_frame
  int populate_frame(int stream, AVFrame& frame);

  //! Convert packet data into frames
  //!
  //! \param ctx The AVCodecContext of the stream to populate
  //! \param pq The packet queue to pull packets from
  //! \param frame An empty frame which gets populated by the data in the
  //! packet queue.
  //! \returns FFMPEG result of avcodec_receive_frame
  int populate_frame(AVCodecContext& ctx, av_packet_queue& pq, AVFrame& frame);

  SDL_Renderer* renderer;  ///< The renderer to draw to

  //! A description of the last error
  std::string last_error;

  //! A buffer for passing to ffmpeg to get error details
  char error_buffer[movie_error_buffer_capacity];

  //! Indicate that we are in the process of aborting playback
  std::atomic<bool> aborting;

  std::mutex decoding_audio_mutex;  ///< Synchronize access to #m_pAudioBuffer

  AVFormatContext* format_context;  ///< Information related to the loaded
                                    ///< movie and all of its streams
  int video_stream_index;           ///< The index of the video stream
  int audio_stream_index;           ///< The index of the audio stream
  av_codec_context_unique_ptr
      video_codec_context;  ///< The video codec and information
                            ///< related to video
  av_codec_context_unique_ptr
      audio_codec_context;  ///< The audio codec and information
                            ///< related to audio

  // queues for transferring data between threads
  av_packet_queue video_queue;  ///< Packets from the video stream
  av_packet_queue audio_queue;  ///< Packets from the audio stream
  ::movie_picture_buffer movie_picture_buffer;  ///< Buffer of processed video

  // clock sync parameters
  std::uint32_t current_sync_pts_system_time;  ///< System time matching
                                               ///< #current_sync_pts
  double current_sync_pts;  ///< The current presentation time stamp (from the
                            ///< audio stream)

  SwrContext* audio_resample_context;  ///< Context for resampling audio for
                                       ///< playback with ffmpeg

  mix_chunk_unique_ptr empty_audio_chunk;  ///< Empty chunk needed for SDL_mixer
  std::array<std::uint8_t, 1024>
      audio_chunk_buffer;  ///< 0'd out buffer for the SDL_mixer chunk

  int audio_channel;    ///< The channel to play audio on, -1 for none
  int mixer_channels;   ///< How many channels to play on (1 - mono, 2 -
                        ///< stereo)
  int mixer_frequency;  ///< The frequency of audio expected by SDL_mixer

  std::thread stream_thread;  ///< The thread responsible for reading the
                              ///< movie streams
  std::thread video_thread;   ///< The thread responsible for decoding the
                              ///< video stream
#endif                        // CORSIX_TH_USE_FFMPEG
};

#endif  // TH_VIDEO_H
