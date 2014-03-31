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
#include <math.h>
#include <new>

THSoundArchive::THSoundArchive()
{
    m_pFiles = NULL;
    m_pData = NULL;
}

THSoundArchive::~THSoundArchive()
{
    delete[] m_pData;
}

bool THSoundArchive::loadFromTHFile(const unsigned char* pData, size_t iDataLength)
{
    if(iDataLength < sizeof(uint32_t) + sizeof(th_header_t))
        return false;

    uint32_t iHeaderPosition = reinterpret_cast<const uint32_t*>(pData + iDataLength)[-1];
    if(static_cast<size_t>(iHeaderPosition) >= iDataLength - sizeof(th_header_t))
        return false;

    m_oHeader = *reinterpret_cast<const th_header_t*>(pData + iHeaderPosition);

    delete[] m_pData;
    m_pData = new (std::nothrow) unsigned char[iDataLength];
    if(m_pData == NULL)
        return false;
    memcpy(m_pData, pData, iDataLength);

    m_pFiles = reinterpret_cast<th_fileinfo_t*>(m_pData + m_oHeader.table_position);
    m_iFileCount = m_oHeader.table_length / sizeof(th_fileinfo_t);
    return true;
}

size_t THSoundArchive::getSoundCount() const
{
    return m_iFileCount;
}

const char* THSoundArchive::getSoundFilename(size_t iIndex) const
{
    if(iIndex >= m_iFileCount)
        return NULL;
    return m_pFiles[iIndex].filename;
}

#define FOURCC(c1, c2, c3, c4) \
    ( static_cast<uint32_t>(static_cast<uint8_t>(c1) <<  0) \
    | static_cast<uint32_t>(static_cast<uint8_t>(c2) <<  8) \
    | static_cast<uint32_t>(static_cast<uint8_t>(c3) << 16) \
    | static_cast<uint32_t>(static_cast<uint8_t>(c4) << 24) )

size_t THSoundArchive::getSoundDuration(size_t iIndex)
{
    SDL_RWops *pFile = loadSound(iIndex);
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
        if(iFourCC == FOURCC('d','a','t','a'))
        {
            iWaveDataLength = iChunkLength;
        }
        if(SDL_RWseek(pFile, iChunkLength + (iChunkLength & 1), SEEK_CUR) == -1)
            break;
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

SDL_RWops* THSoundArchive::loadSound(size_t iIndex)
{
    if(iIndex >= m_iFileCount)
        return NULL;

    th_fileinfo_t *pFile = m_pFiles + iIndex;
    return SDL_RWFromConstMem(m_pData + pFile->position, pFile->length);
}

#ifdef CORSIX_TH_USE_SDL_MIXER

THSoundEffects* THSoundEffects::ms_pSingleton = NULL;

THSoundEffects::THSoundEffects()
{
    m_ppSounds = NULL;
    m_iSoundCount = 0;
    ms_pSingleton = this;
    m_iCameraX = 0;
    m_iCameraY = 0;
    m_fCameraRadius = 1.0;
    m_fMasterVolume = 1.0;
    m_fSoundEffectsVolume = 0.5;
    m_iPostionlessVolume = MIX_MAX_VOLUME;
    m_bSoundEffectsOn = true;

#define NUM_CHANNELS 32
#if NUM_CHANNELS >= 32
    m_iChannelStatus = ~0;
    Mix_AllocateChannels(32);
#else
    m_iChannelStatus = (1 << NUM_CHANNELS) - 1;
    Mix_AllocateChannels(NUM_CHANNELS);
#endif
#undef NUM_CHANNELS

    Mix_ChannelFinished(_onChannelFinish);
}

THSoundEffects::~THSoundEffects()
{
    setSoundArchive(NULL);
    if(ms_pSingleton == this)
        ms_pSingleton = NULL;
}

void THSoundEffects::_onChannelFinish(int iChannel)
{
    THSoundEffects *pThis = getSingleton();
    if(pThis == NULL)
        return;

    pThis->releaseChannel(iChannel);
}

THSoundEffects* THSoundEffects::getSingleton()
{
    return ms_pSingleton;
}

void THSoundEffects::setSoundArchive(THSoundArchive *pArchive)
{
    for(size_t i = 0; i < m_iSoundCount; ++i)
    {
        Mix_FreeChunk(m_ppSounds[i]);
    }
    delete[] m_ppSounds;
    m_ppSounds = NULL;
    m_iSoundCount = 0;

    if(pArchive == NULL)
        return;

    m_ppSounds = new Mix_Chunk*[pArchive->getSoundCount()];
    for(; m_iSoundCount < pArchive->getSoundCount(); ++m_iSoundCount)
    {
        m_ppSounds[m_iSoundCount] = NULL;
        SDL_RWops *pRwop = pArchive->loadSound(m_iSoundCount);
        if(pRwop)
        {
            m_ppSounds[m_iSoundCount] = Mix_LoadWAV_RW(pRwop, 1);
            if(m_ppSounds[m_iSoundCount])
                Mix_VolumeChunk(m_ppSounds[m_iSoundCount], MIX_MAX_VOLUME);
        }
    }
}

void THSoundEffects::playSound(size_t iIndex, double dVolume)
{
    if(m_iChannelStatus == 0 || iIndex >= m_iSoundCount || !m_ppSounds[iIndex])
        return;

    _playRaw(iIndex, (int)(m_iPostionlessVolume*dVolume));
}

void THSoundEffects::playSoundAt(size_t iIndex, int iX, int iY)
{
    if(m_bSoundEffectsOn)
        playSoundAt(iIndex, m_fSoundEffectsVolume, iX, iY);
}

void THSoundEffects::playSoundAt(size_t iIndex, double dVolume, int iX, int iY)
{
    if(m_iChannelStatus == 0 || iIndex >= m_iSoundCount || !m_ppSounds[iIndex])
        return;

    double fDX = (double)(iX - m_iCameraX);
    double fDY = (double)(iY - m_iCameraY);
    double fDistance = sqrt(fDX * fDX + fDY * fDY);
    if(fDistance > m_fCameraRadius)
        return;
    fDistance = fDistance / m_fCameraRadius;

    double fVolume = m_fMasterVolume * (1.0 - fDistance * 0.8) * (double)MIX_MAX_VOLUME * dVolume;

    _playRaw(iIndex, (int)(fVolume + 0.5));
}

void THSoundEffects::setSoundEffectsVolume(double dVolume)
{
    m_fSoundEffectsVolume = dVolume;
}

void THSoundEffects::setSoundEffectsOn(bool bOn)
{
    m_bSoundEffectsOn = bOn;
}

int THSoundEffects::reserveChannel()
{
    // NB: Callers ensure that m_iChannelStatus != 0
    int iChannel = 0;
    for(; (m_iChannelStatus & (1 << iChannel)) == 0; ++iChannel) {}
    m_iChannelStatus &=~ (1 << iChannel);

    return iChannel;
}

void THSoundEffects::releaseChannel(int iChannel)
{
    m_iChannelStatus |= (1 << iChannel);
}

void THSoundEffects::_playRaw(size_t iIndex, int iVolume)
{
    int iChannel = reserveChannel();

    Mix_Volume(iChannel, iVolume);
    Mix_PlayChannelTimed(iChannel, m_ppSounds[iIndex], 0, -1);
}

void THSoundEffects::setCamera(int iX, int iY, int iRadius)
{
    m_iCameraX = iX;
    m_iCameraY = iY;
    m_fCameraRadius = (double)iRadius;
    if(m_fCameraRadius < 0.001)
        m_fCameraRadius = 0.001;
}

#else // CORSIX_TH_USE_SDL_MIXER

THSoundEffects::THSoundEffects() {}
THSoundEffects::~THSoundEffects() {}
THSoundEffects* THSoundEffects::getSingleton() {return NULL;}
void THSoundEffects::setSoundArchive(THSoundArchive *pArchive) {}
void THSoundEffects::playSound(size_t iIndex, double dVolume) {}
void THSoundEffects::playSoundAt(size_t iIndex, int iX, int iY) {}
void THSoundEffects::playSoundAt(size_t iIndex, double dVolume, int iX, int iY) {}
int THSoundEffects::reserveChannel() { return 0; }
void THSoundEffects::releaseChannel(int iChannel) {}
void THSoundEffects::setCamera(int iX, int iY, int iRadius) {}
void THSoundEffects::setSoundEffectsVolume(double dVolume) {}
void THSoundEffects::setSoundEffectsOn(bool iOn) {}

#endif // CORSIX_TH_USE_SDL_MIXER
