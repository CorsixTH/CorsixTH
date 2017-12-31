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

#ifndef CORSIX_TH_TH_SOUND_H_
#define CORSIX_TH_TH_SOUND_H_
#include <SDL.h>
#ifdef CORSIX_TH_USE_SDL_MIXER
#include <SDL_mixer.h>
#endif

//! Utility class for accessing Theme Hospital's SOUND-0.DAT
class THSoundArchive
{
public:
    THSoundArchive();
    ~THSoundArchive();

    bool loadFromTHFile(const uint8_t* pData, size_t iDataLength);

    //! Returns the number of sounds present in the archive
    size_t getSoundCount() const;

    //! Gets the name of the sound at a given index
    const char* getSoundFilename(size_t iIndex) const;

    //! Gets the duration (in miliseconds) of the sound at a given index
    size_t getSoundDuration(size_t iIndex);

    //! Opens the sound at a given index into an SDL_RWops structure
    /*!
        The caller is responsible for closing/freeing the result.
    */
    SDL_RWops* loadSound(size_t iIndex);

private:
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(push)
#pragma pack(1)
#endif
    struct th_header_t
    {
        uint8_t  unknown1[50];
        uint32_t table_position;
        uint32_t unknown2;
        uint32_t table_length;
        uint32_t table_position2;
        uint8_t  unknown3[112];
        uint32_t table_position3;
        uint32_t table_length2;
        uint8_t  unknown4[48];
    } CORSIX_TH_PACKED_FLAGS;

    struct th_fileinfo_t
    {
        char     filename[18];
        uint32_t position;
        uint32_t unknown1;
        uint32_t length;
        uint16_t unknown2;
    } CORSIX_TH_PACKED_FLAGS;
#if CORSIX_TH_USE_PACK_PRAGMAS
#pragma pack(pop)
#endif

    th_header_t m_oHeader;
    th_fileinfo_t* m_pFiles;
    uint8_t* m_pData;
    size_t m_iFileCount;
};

class THSoundEffects
{
public:
    THSoundEffects();
    ~THSoundEffects();

    static THSoundEffects* getSingleton();

    void setSoundArchive(THSoundArchive *pArchive);

    void playSound(size_t iIndex, double dVolume);
    void playSoundAt(size_t iIndex, int iX, int iY);
    void playSoundAt(size_t iIndex, double dVolume, int iX, int iY);
    void setSoundEffectsVolume(double dVolume);
    void setSoundEffectsOn(bool bOn);
    void setCamera(int iX, int iY, int iRadius);
    int reserveChannel();
    void releaseChannel(int iChannel);

private:
#ifdef CORSIX_TH_USE_SDL_MIXER
    static THSoundEffects* ms_pSingleton;
    static void _onChannelFinish(int iChannel);

    inline void _playRaw(size_t iIndex, int iVolume);

    Mix_Chunk **m_ppSounds;
    size_t m_iSoundCount;
    uint32_t m_iChannelStatus;
    int m_iCameraX;
    int m_iCameraY;
    double m_fCameraRadius;
    double m_fMasterVolume;
    double m_fSoundEffectsVolume;
    int m_iPostionlessVolume;
    bool m_bSoundEffectsOn;
#endif // CORSIX_TH_USE_SDL_MIXER
};

#endif // CORSIX_TH_TH_SOUND_H_
