/*
Copyright (c) 2009 Peter "Corsix" Cawley

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

#include "config.h"
#include "th_sound.h"
#include <cmath>
#include <new>
#include <cstring>

sound_archive::sound_archive()
{
    sound_files = nullptr;
    data = nullptr;
}

sound_archive::~sound_archive()
{
    delete[] data;
}

bool sound_archive::load_from_th_file(const uint8_t* pData, size_t iDataLength)
{
    if(iDataLength < sizeof(uint32_t) + sizeof(sound_dat_file_header))
        return false;

    uint32_t iHeaderPosition = reinterpret_cast<const uint32_t*>(pData + iDataLength)[-1];
    if(static_cast<size_t>(iHeaderPosition) >= iDataLength - sizeof(sound_dat_file_header))
        return false;

    header = *reinterpret_cast<const sound_dat_file_header*>(pData + iHeaderPosition);

    delete[] data;
    data = new (std::nothrow) uint8_t[iDataLength];
    if(data == nullptr)
        return false;
    std::memcpy(data, pData, iDataLength);

    sound_files = reinterpret_cast<sound_dat_sound_info*>(data + header.table_position);
    sound_file_count = header.table_length / sizeof(sound_dat_sound_info);
    return true;
}

size_t sound_archive::get_number_of_sounds() const
{
    return sound_file_count;
}

const char* sound_archive::get_sound_name(size_t iIndex) const
{
    if(iIndex >= sound_file_count)
        return nullptr;
    return sound_files[iIndex].sound_name;
}

#define FOURCC(c1, c2, c3, c4) \
    ( static_cast<uint32_t>(static_cast<uint8_t>(c1) <<  0) \
    | static_cast<uint32_t>(static_cast<uint8_t>(c2) <<  8) \
    | static_cast<uint32_t>(static_cast<uint8_t>(c3) << 16) \
    | static_cast<uint32_t>(static_cast<uint8_t>(c4) << 24) )

size_t sound_archive::get_sound_duration(size_t iIndex)
{
    SDL_RWops *pFile = load_sound(iIndex);
    if(!pFile)
        return 0;

    uint16_t iWaveAudioFormat = 0;
    uint16_t iWaveChannelCount = 0;
    uint32_t iWaveSampleRate = 0;
    uint32_t iWaveByteRate = 0;
    uint16_t iWaveBlockAlign = 0;
    uint16_t iWaveBitsPerSample = 0;
    uint32_t iWaveDataLength = 0;

    // This is a very crude RIFF parser, but it does the job.
    uint32_t iFourCC;
    uint32_t iChunkLength;
    for(;;)
    {
        if(SDL_RWread(pFile, &iFourCC, 4, 1) != 1)
            break;
        if(SDL_RWread(pFile, &iChunkLength, 4, 1) != 1)
            break;
        if(iFourCC == FOURCC('R','I','F','F') || iFourCC == FOURCC('L','I','S','T'))
        {
            if(iChunkLength >= 4)
            {
                if(SDL_RWread(pFile, &iFourCC, 4, 1) != 1)
                    break;
                else
                    continue;
            }
        }
        if(iFourCC == FOURCC('f','m','t',' ') && iChunkLength >= 16)
        {
            if(SDL_RWread(pFile, &iWaveAudioFormat, 2, 1) != 1)
                break;
            if(SDL_RWread(pFile, &iWaveChannelCount, 2, 1) != 1)
                break;
            if(SDL_RWread(pFile, &iWaveSampleRate, 4, 1) != 1)
                break;
            if(SDL_RWread(pFile, &iWaveByteRate, 4, 1) != 1)
                break;
            if(SDL_RWread(pFile, &iWaveBlockAlign, 2, 1) != 1)
                break;
            if(SDL_RWread(pFile, &iWaveBitsPerSample, 2, 1) != 1)
                break;
            iChunkLength -= 16;
        }
        //Finally:
        if(iFourCC == FOURCC('d','a','t','a'))
        {
            iWaveDataLength = iChunkLength;
            break;
        }
        if(SDL_RWseek(pFile, iChunkLength + (iChunkLength & 1), RW_SEEK_CUR) == -1) {
            break;
        }
    }
    SDL_RWclose(pFile);
    if(iWaveAudioFormat != 1 || iWaveChannelCount == 0 || iWaveSampleRate == 0
    || iWaveDataLength == 0 || iWaveBitsPerSample == 0)
    {
        return 0;
    }
#define mul64(a, b) (static_cast<uint64_t>(a) * static_cast<uint64_t>(b))
    return static_cast<size_t>(mul64(iWaveDataLength, 8000) /
        mul64(mul64(iWaveBitsPerSample, iWaveChannelCount), iWaveSampleRate));
#undef mul64
}

#undef FOURCC

SDL_RWops* sound_archive::load_sound(size_t iIndex)
{
    if(iIndex >= sound_file_count)
        return nullptr;

    sound_dat_sound_info *pFile = sound_files + iIndex;
    return SDL_RWFromConstMem(data + pFile->position, pFile->length);
}

#ifdef CORSIX_TH_USE_SDL_MIXER

sound_player* sound_player::singleton = nullptr;

sound_player::sound_player()
{
    sounds = nullptr;
    sound_count = 0;
    singleton = this;
    camera_x = 0;
    camera_y = 0;
    camera_radius = 1.0;
    master_volume = 1.0;
    sound_effect_volume = 0.5;
    positionless_volume = MIX_MAX_VOLUME;
    sound_effects_enabled = true;

#define NUM_CHANNELS 32
#if NUM_CHANNELS >= 32
    available_channels_bitmap = ~0;
    Mix_AllocateChannels(32);
#else
    channels_in_use_bitmap = (1 << NUM_CHANNELS) - 1;
    Mix_AllocateChannels(NUM_CHANNELS);
#endif
#undef NUM_CHANNELS

    Mix_ChannelFinished(on_channel_finished);
}

sound_player::~sound_player()
{
    populate_from(nullptr);
    if(singleton == this)
        singleton = nullptr;
}

void sound_player::on_channel_finished(int iChannel)
{
    sound_player *pThis = get_singleton();
    if(pThis == nullptr)
        return;

    pThis->release_channel(iChannel);
}

sound_player* sound_player::get_singleton()
{
    return singleton;
}

void sound_player::populate_from(sound_archive *pArchive)
{
    for(size_t i = 0; i < sound_count; ++i)
    {
        Mix_FreeChunk(sounds[i]);
    }
    delete[] sounds;
    sounds = nullptr;
    sound_count = 0;

    if(pArchive == nullptr)
        return;

    sounds = new Mix_Chunk*[pArchive->get_number_of_sounds()];
    for(; sound_count < pArchive->get_number_of_sounds(); ++sound_count)
    {
        sounds[sound_count] = nullptr;
        SDL_RWops *pRwop = pArchive->load_sound(sound_count);
        if(pRwop)
        {
            sounds[sound_count] = Mix_LoadWAV_RW(pRwop, 1);
            if(sounds[sound_count])
                Mix_VolumeChunk(sounds[sound_count], MIX_MAX_VOLUME);
        }
    }
}

void sound_player::play(size_t iIndex, double dVolume)
{
    if(available_channels_bitmap == 0 || iIndex >= sound_count || !sounds[iIndex])
        return;

    play_raw(iIndex, (int)(positionless_volume * dVolume));
}

void sound_player::play_at(size_t iIndex, int iX, int iY)
{
    if(sound_effects_enabled)
        play_at(iIndex, sound_effect_volume, iX, iY);
}

void sound_player::play_at(size_t iIndex, double dVolume, int iX, int iY)
{
    if(available_channels_bitmap == 0 || iIndex >= sound_count || !sounds[iIndex])
        return;

    double fDX = (double)(iX - camera_x);
    double fDY = (double)(iY - camera_y);
    double fDistance = sqrt(fDX * fDX + fDY * fDY);
    if(fDistance > camera_radius)
        return;
    fDistance = fDistance / camera_radius;

    double fVolume = master_volume * (1.0 - fDistance * 0.8) * (double)MIX_MAX_VOLUME * dVolume;

    play_raw(iIndex, (int)(fVolume + 0.5));
}

void sound_player::set_sound_effect_volume(double dVolume)
{
    sound_effect_volume = dVolume;
}

void sound_player::set_sound_effects_enabled(bool bOn)
{
    sound_effects_enabled = bOn;
}

int sound_player::reserve_channel()
{
    // NB: Callers ensure that m_iChannelStatus != 0
    int iChannel = 0;
    for(; (available_channels_bitmap & (1 << iChannel)) == 0; ++iChannel) {}
    available_channels_bitmap &=~ (1 << iChannel);

    return iChannel;
}

void sound_player::release_channel(int iChannel)
{
    available_channels_bitmap |= (1 << iChannel);
}

void sound_player::play_raw(size_t iIndex, int iVolume)
{
    int iChannel = reserve_channel();

    Mix_Volume(iChannel, iVolume);
    Mix_PlayChannelTimed(iChannel, sounds[iIndex], 0, -1);
}

void sound_player::set_camera(int iX, int iY, int iRadius)
{
    camera_x = iX;
    camera_y = iY;
    camera_radius = (double)iRadius;
    if(camera_radius < 0.001)
        camera_radius = 0.001;
}

#else // CORSIX_TH_USE_SDL_MIXER

sound_effect_player::sound_effect_player() {}
sound_effect_player::~sound_effect_player() {}
sound_effect_player* sound_effect_player::get_singleton() {return nullptr;}
void sound_effect_player::set_sound_archive(THSoundArchive *pArchive) {}
void sound_effect_player::play(size_t iIndex, double dVolume) {}
void sound_effect_player::play_at(size_t iIndex, int iX, int iY) {}
void sound_effect_player::play_at(size_t iIndex, double dVolume, int iX, int iY) {}
int sound_effect_player::reserve_channel() { return 0; }
void sound_effect_player::release_channel(int iChannel) {}
void sound_effect_player::set_camera(int iX, int iY, int iRadius) {}
void sound_effect_player::set_sound_effect_volume(double dVolume) {}
void sound_effect_player::set_sound_effects_enabled(bool iOn) {}

#endif // CORSIX_TH_USE_SDL_MIXER
