/*
Copyright (c) 2010 Peter "Corsix" Cawley

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

#include "th_lua_internal.h"
#include "th_gfx.h"
#include "th_map.h"

/* this variable is used to determine the layer of the animation, it should be rewriten at some
  point so that the it is passed as an argument in the function l_anim_set_tile */
static int lastLayer = 2;

static int l_anims_new(lua_State *L)
{
    luaT_stdnew<THAnimationManager>(L, luaT_environindex, true);
    return 1;
}

static int l_anims_set_spritesheet(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    THSpriteSheet* pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    lua_settop(L, 2);

    pAnims->setSpriteSheet(pSheet);
    luaT_setenvfield(L, 1, "sprites");
    return 1;
}

//! Set the video target for the sprites.
/*!
    setCanvas(<video-surface>)
 */
static int l_anims_set_canvas(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    lua_settop(L, 2);

    pAnims->setCanvas(pCanvas);
    luaT_setenvfield(L, 1, "target");
    return 1;
}

static int l_anims_load(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    size_t iStartDataLength, iFrameDataLength, iListDataLength, iElementDataLength;
    const uint8_t* pStartData = luaT_checkfile(L, 2, &iStartDataLength);
    const uint8_t* pFrameData = luaT_checkfile(L, 3, &iFrameDataLength);
    const uint8_t* pListData = luaT_checkfile(L, 4, &iListDataLength);
    const uint8_t* pElementData = luaT_checkfile(L, 5, &iElementDataLength);

    if(pAnims->loadFromTHFile(pStartData, iStartDataLength, pFrameData, iFrameDataLength,
        pListData, iListDataLength, pElementData, iElementDataLength))
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }

    return 1;
}

//! Load custom animations.
/*!
    loadCustom(<data-of-an-animation-file>) -> true/false
 */
static int l_anims_loadcustom(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    size_t iDataLength;
    const uint8_t* pData = luaT_checkfile(L, 2, &iDataLength);

    if (pAnims->loadCustomAnimations(pData, iDataLength))
    {
        lua_pushboolean(L, 1);
    }
    else
    {
        lua_pushboolean(L, 0);
    }

    return 1;
}

//! Lua interface for getting a set of animations by name and tile size (one for
//! each view direction, 'nil' if no animation is available for a direction).
/*!
    getAnimations(<tile-size>, <animation-name>) -> (<anim-north>, <anim-east>,  <anim-south>, <anim-west>)
 */
static int l_anims_getanims(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    int iTileSize = static_cast<int>(luaL_checkinteger(L, 2));
    const char *pName = luaL_checkstring(L, 3);

    const AnimationStartFrames &oFrames = pAnims->getNamedAnimations(pName, iTileSize);
    if (oFrames.iNorth < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.iNorth)); }
    if (oFrames.iEast  < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.iEast));  }
    if (oFrames.iSouth < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.iSouth)); }
    if (oFrames.iWest  < 0) { lua_pushnil(L); } else { lua_pushnumber(L, static_cast<double>(oFrames.iWest));  }
    return 4;
}


static int l_anims_getfirst(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    int iAnim = static_cast<int>(luaL_checkinteger(L, 2));

    lua_pushinteger(L, pAnims->getFirstFrame(iAnim));
    return 1;
}

static int l_anims_getnext(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    int iFrame = static_cast<int>(luaL_checkinteger(L, 2));

    lua_pushinteger(L, pAnims->getNextFrame(iFrame));
    return 1;
}

static int l_anims_set_alt_pal(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    size_t iAnimation = luaL_checkinteger(L, 2);
    size_t iPalLen;
    const uint8_t *pPal = luaT_checkfile(L, 3, &iPalLen);
    if(iPalLen != 256)
    {
        return luaL_argerror(L, 3, "GhostPalette string is not a valid palette");
    }
    uint32_t iAlt32 = static_cast<uint32_t>(luaL_checkinteger(L, 4));

    pAnims->setAnimationAltPaletteMap(iAnimation, pPal, iAlt32);

    lua_getfenv(L, 1);
    lua_insert(L, 2);
    lua_settop(L, 4);
    lua_settable(L, 2);
    lua_settop(L, 1);
    return 1;
}

static int l_anims_set_marker(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    lua_pushboolean(L, pAnims->setFrameMarker(luaL_checkinteger(L, 2),
        static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4))) ? 1 : 0);
    return 1;
}

static int l_anims_set_secondary_marker(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    lua_pushboolean(L, pAnims->setFrameSecondaryMarker(luaL_checkinteger(L, 2),
        static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4))) ? 1 : 0);
    return 1;
}

static int l_anims_draw(lua_State *L)
{
    THAnimationManager* pAnims = luaT_testuserdata<THAnimationManager>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    size_t iFrame = luaL_checkinteger(L, 3);
    THLayers_t* pLayers = luaT_testuserdata<THLayers_t>(L, 4, luaT_upvalueindex(2));
    int iX = static_cast<int>(luaL_checkinteger(L, 5));
    int iY = static_cast<int>(luaL_checkinteger(L, 6));
    int iFlags = static_cast<int>(luaL_optinteger(L, 7, 0));

    pAnims->drawFrame(pCanvas, iFrame, *pLayers, iX, iY, iFlags);

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_new(lua_State *L)
{
    T* pAnimation = luaT_stdnew<T>(L, luaT_environindex, true);
    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, pAnimation);
    lua_pushvalue(L, -3);
    lua_rawset(L, -3);
    lua_pop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_persist(lua_State *L)
{
    T* pAnimation;
    if(lua_gettop(L) == 2)
    {
        pAnimation = luaT_testuserdata<T>(L, 1, luaT_environindex, false);
        lua_insert(L, 1);
    }
    else
    {
        // Fast __persist call
        pAnimation = (T*)lua_touserdata(L, -1);
    }
    LuaPersistWriter* pWriter = (LuaPersistWriter*)lua_touserdata(L, 1);

    pAnimation->persist(pWriter);
    lua_rawgeti(L, luaT_environindex, 1);
    lua_pushlightuserdata(L, pAnimation);
    lua_gettable(L, -2);
    pWriter->writeStackObject(-1);
    lua_pop(L, 2);
    return 0;
}

template <typename T>
static int l_anim_pre_depersist(lua_State *L)
{
    // Note that anims and the map have nice reference cycles between them
    // and hence we cannot be sure which is depersisted first. To ensure that
    // things work nicely, we initialise all the fields of a THAnimation as
    // soon as possible, thus preventing issues like an anim -> map -> anim
    // reference chain whereby l_anim_depersist is called after l_map_depersist
    // (as anim references map in its environment table) causing the pPrev
    // field to be set during map depersistence, then cleared to nullptr by the
    // constructor during l_anim_depersist.
    T* pAnimation = luaT_testuserdata<T>(L);
    new (pAnimation) T; // Call constructor
    return 0;
}

template <typename T>
static int l_anim_depersist(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    lua_settop(L, 2);
    lua_insert(L, 1);
    LuaPersistReader* pReader = (LuaPersistReader*)lua_touserdata(L, 1);

    lua_rawgeti(L, luaT_environindex, 2);
    lua_pushlightuserdata(L, pAnimation);
    lua_pushvalue(L, 2);
    lua_settable(L, -3);
    lua_pop(L, 1);
    pAnimation->depersist(pReader);
    lua_rawgeti(L, luaT_environindex, 1);
    lua_pushlightuserdata(L, pAnimation);
    if(!pReader->readStackObject())
        return 0;
    lua_settable(L, -3);
    lua_pop(L, 1);
    return 0;
}

static int l_anim_set_hitresult(lua_State *L)
{
    luaL_checktype(L, 1, LUA_TUSERDATA);
    lua_settop(L, 2);
    lua_rawgeti(L, luaT_environindex, 1);
    lua_pushlightuserdata(L, lua_touserdata(L, 1));
    lua_pushvalue(L, 2);
    lua_settable(L, 3);
    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_frame(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->setFrame(luaL_checkinteger(L, 2));
    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_frame(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_pushinteger(L, pAnimation->getFrame());
    return 1;
}

static int l_anim_set_crop(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    pAnimation->setCropColumn(static_cast<int>(luaL_checkinteger(L, 2)));
    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_crop(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_pushinteger(L, pAnimation->getCropColumn());
    return 1;
}

static int l_anim_set_anim(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THAnimationManager* pManager = luaT_testuserdata<THAnimationManager>(L, 2);
    size_t iAnim = luaL_checkinteger(L, 3);
    if(iAnim < 0 || iAnim >= pManager->getAnimationCount())
        luaL_argerror(L, 3, "Animation index out of bounds");

    if(lua_isnoneornil(L, 4))
        pAnimation->setFlags(0);
    else
        pAnimation->setFlags(static_cast<uint32_t>(luaL_checkinteger(L, 4)));

    pAnimation->setAnimation(pManager, iAnim);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "animator");
    lua_pushnil(L);
    luaT_setenvfield(L, 1, "morph_target");

    return 1;
}

static int l_anim_set_morph(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THAnimation* pMorphTarget = luaT_testuserdata<THAnimation>(L, 2, luaT_environindex);

    unsigned int iDurationFactor = 1;
    if(!lua_isnoneornil(L, 3) && luaL_checkinteger(L, 3) > 0)
        iDurationFactor = static_cast<unsigned int>(luaL_checkinteger(L, 3));

    pAnimation->setMorphTarget(pMorphTarget, iDurationFactor);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "morph_target");

    return 1;
}

static int l_anim_set_drawable_layer(lua_State *L)
{
    lastLayer = static_cast<int>(luaL_checkinteger(L, 2));
    return 1;
}

static int l_anim_get_anim(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_pushinteger(L, pAnimation->getAnimation());

    return 1;
}

template <typename T>
static int l_anim_set_tile(lua_State *L)
{

    T* pAnimation = luaT_testuserdata<T>(L);
    if(lua_isnoneornil(L, 2))
    {
        pAnimation->removeFromTile();
        lua_pushnil(L);
        luaT_setenvfield(L, 1, "map");
        lua_settop(L, 1);
    }
    else
    {
        THMap* pMap = luaT_testuserdata<THMap>(L, 2);
        THMapNode* pNode = pMap->getNode(static_cast<int>(luaL_checkinteger(L, 3) - 1), static_cast<int>(luaL_checkinteger(L, 4) - 1));
        if(pNode)
            pAnimation->attachToTile(pNode, lastLayer);

        else
        {
            luaL_argerror(L, 3, lua_pushfstring(L, "Map index out of bounds ("
                LUA_NUMBER_FMT "," LUA_NUMBER_FMT ")", lua_tonumber(L, 3),
                lua_tonumber(L, 4)));
        }

        lua_settop(L, 2);
        luaT_setenvfield(L, 1, "map");
    }

    return 1;
}

static int l_anim_get_tile(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 1);
    lua_getfenv(L, 1);
    lua_getfield(L, 2, "map");
    lua_replace(L, 2);
    if(lua_isnil(L, 2))
    {
        return 0;
    }
    THMap* pMap = (THMap*)lua_touserdata(L, 2);
    const THLinkList* pListNode = pAnimation->getPrevious();
    while(pListNode->m_pPrev)
    {
        pListNode = pListNode->m_pPrev;
    }
    // Casting pListNode to a THMapNode* is slightly dubious, but it should
    // work. If on the normal list, then pListNode will be a THMapNode*, and
    // all is fine. However, if on the early list, pListNode will be pointing
    // to a member of a THMapNode, so we're relying on pointer arithmetic
    // being a subtract and integer divide by sizeof(THMapNode) to yield the
    // correct map node.
    const THMapNode *pRootNode = pMap->getNodeUnchecked(0, 0);
    uintptr_t iDiff = reinterpret_cast<const char*>(pListNode) -
                      reinterpret_cast<const char*>(pRootNode);
    int iIndex = (int)(iDiff / sizeof(THMapNode));
    int iY = iIndex / pMap->getWidth();
    int iX = iIndex - (iY * pMap->getWidth());
    lua_pushinteger(L, iX + 1);
    lua_pushinteger(L, iY + 1);
    return 3; // map, x, y
}

static int l_anim_set_parent(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    THAnimation* pParent = luaT_testuserdata<THAnimation>(L, 2, luaT_environindex, false);
    pAnimation->setParent(pParent);
    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_set_flag(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->setFlags(static_cast<uint32_t>(luaL_checkinteger(L, 2)));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_set_flag_partial(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    uint32_t iFlags = static_cast<uint32_t>(luaL_checkinteger(L, 2));
    if(lua_isnone(L, 3) || lua_toboolean(L, 3))
    {
        pAnimation->setFlags(pAnimation->getFlags() | iFlags);
    }
    else
    {
        pAnimation->setFlags(pAnimation->getFlags() & ~iFlags);
    }
    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_make_visible(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->setFlags(pAnimation->getFlags() & ~static_cast<uint32_t>(THDF_Alpha50 | THDF_Alpha75));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_make_invisible(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->setFlags(pAnimation->getFlags() | static_cast<uint32_t>(THDF_Alpha50 | THDF_Alpha75));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_get_flag(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    lua_pushinteger(L, pAnimation->getFlags());

    return 1;
}

template <typename T>
static int l_anim_set_position(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);

    pAnimation->setPosition(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_checkinteger(L, 3)));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_get_position(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);

    lua_pushinteger(L, pAnimation->getX());
    lua_pushinteger(L, pAnimation->getY());

    return 2;
}

template <typename T>
static int l_anim_set_speed(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);

    pAnimation->setSpeed(static_cast<int>(luaL_optinteger(L, 2, 0)), static_cast<int>(luaL_optinteger(L, 3, 0)));

    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_set_layer(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);

    pAnimation->setLayer(static_cast<int>(luaL_checkinteger(L, 2)), static_cast<int>(luaL_optinteger(L, 3, 0)));

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_layers_from(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    const THAnimation* pAnimationSrc = luaT_testuserdata<THAnimation>(L, 2, luaT_environindex);

    pAnimation->setLayersFrom(pAnimationSrc);

    lua_settop(L, 1);
    return 1;
}

static int l_anim_set_tag(lua_State *L)
{
    luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "tag");
    return 1;
}

static int l_anim_get_tag(lua_State *L)
{
    luaT_testuserdata<THAnimation>(L);
    lua_settop(L, 1);
    lua_getfenv(L, 1);
    lua_getfield(L, 2, "tag");
    return 1;
}

static int l_anim_get_marker(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    int iX = 0;
    int iY = 0;
    pAnimation->getMarker(&iX, &iY);
    lua_pushinteger(L, iX);
    lua_pushinteger(L, iY);
    return 2;
}

static int l_anim_get_secondary_marker(lua_State *L)
{
    THAnimation* pAnimation = luaT_testuserdata<THAnimation>(L);
    int iX = 0;
    int iY = 0;
    pAnimation->getSecondaryMarker(&iX, &iY);
    lua_pushinteger(L, iX);
    lua_pushinteger(L, iY);
    return 2;
}

template <typename T>
static int l_anim_tick(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    pAnimation->tick();
    lua_settop(L, 1);
    return 1;
}

template <typename T>
static int l_anim_draw(lua_State *L)
{
    T* pAnimation = luaT_testuserdata<T>(L);
    THRenderTarget* pCanvas = luaT_testuserdata<THRenderTarget>(L, 2);
    pAnimation->draw(pCanvas, static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)));
    lua_settop(L, 1);
    return 1;
}

static int l_srl_set_sheet(lua_State *L)
{
    THSpriteRenderList *pSrl = luaT_testuserdata<THSpriteRenderList>(L);
    THSpriteSheet *pSheet = luaT_testuserdata<THSpriteSheet>(L, 2);
    pSrl->setSheet(pSheet);

    lua_settop(L, 2);
    luaT_setenvfield(L, 1, "sheet");
    return 1;
}

static int l_srl_append(lua_State *L)
{
    THSpriteRenderList *pSrl = luaT_testuserdata<THSpriteRenderList>(L);
    pSrl->appendSprite(luaL_checkinteger(L, 2),
                       static_cast<int>(luaL_checkinteger(L, 3)), static_cast<int>(luaL_checkinteger(L, 4)));
    lua_settop(L, 1);
    return 1;
}

static int l_srl_set_lifetime(lua_State *L)
{
    THSpriteRenderList *pSrl = luaT_testuserdata<THSpriteRenderList>(L);
    pSrl->setLifetime(static_cast<int>(luaL_checkinteger(L, 2)));
    lua_settop(L, 1);
    return 1;
}

static int l_srl_is_dead(lua_State *L)
{
    THSpriteRenderList *pSrl = luaT_testuserdata<THSpriteRenderList>(L);
    lua_pushboolean(L, pSrl->isDead() ? 1 : 0);
    return 1;
}

void THLuaRegisterAnims(const THLuaRegisterState_t *pState)
{
    // Anims
    luaT_class(THAnimationManager, l_anims_new, "anims", MT_Anims);
    luaT_setfunction(l_anims_load, "load");
    luaT_setfunction(l_anims_loadcustom, "loadCustom");
    luaT_setfunction(l_anims_set_spritesheet, "setSheet", MT_Sheet);
    luaT_setfunction(l_anims_set_canvas, "setCanvas", MT_Surface);
    luaT_setfunction(l_anims_getanims, "getAnimations");
    luaT_setfunction(l_anims_getfirst, "getFirstFrame");
    luaT_setfunction(l_anims_getnext, "getNextFrame");
    luaT_setfunction(l_anims_set_alt_pal, "setAnimationGhostPalette");
    luaT_setfunction(l_anims_set_marker, "setFrameMarker");
    luaT_setfunction(l_anims_set_secondary_marker, "setFrameSecondaryMarker");
    luaT_setfunction(l_anims_draw, "draw", MT_Surface, MT_Layers);
    luaT_setconstant("Alt32_GreyScale",   THDF_Alt32_GreyScale);
    luaT_setconstant("Alt32_BlueRedSwap", THDF_Alt32_BlueRedSwap);
    luaT_endclass();

    // Weak table at AnimMetatable[1] for light UD -> object lookup
    // For hitTest / setHitTestResult
    lua_newtable(pState->L);
    lua_createtable(pState->L, 0, 1);
    lua_pushliteral(pState->L, "v");
    lua_setfield(pState->L, -2, "__mode");
    lua_setmetatable(pState->L, -2);
    lua_rawseti(pState->L, pState->aiMetatables[MT_Anim], 1);

    // Weak table at AnimMetatable[2] for light UD -> full UD lookup
    // For persisting Map
    lua_newtable(pState->L);
    lua_createtable(pState->L, 0, 1);
    lua_pushliteral(pState->L, "v");
    lua_setfield(pState->L, -2, "__mode");
    lua_setmetatable(pState->L, -2);
    lua_rawseti(pState->L, pState->aiMetatables[MT_Anim], 2);

    // Anim
    luaT_class(THAnimation, l_anim_new<THAnimation>, "animation", MT_Anim);
    luaT_setmetamethod(l_anim_persist<THAnimation>, "persist");
    luaT_setmetamethod(l_anim_pre_depersist<THAnimation>, "pre_depersist");
    luaT_setmetamethod(l_anim_depersist<THAnimation>, "depersist");
    luaT_setfunction(l_anim_set_anim, "setAnimation", MT_Anims);
    luaT_setfunction(l_anim_set_crop, "setCrop");
    luaT_setfunction(l_anim_get_crop, "getCrop");
    luaT_setfunction(l_anim_set_morph, "setMorph");
    luaT_setfunction(l_anim_set_frame, "setFrame");
    luaT_setfunction(l_anim_get_frame, "getFrame");
    luaT_setfunction(l_anim_get_anim, "getAnimation");
    luaT_setfunction(l_anim_set_tile<THAnimation>, "setTile", MT_Map);
    luaT_setfunction(l_anim_get_tile, "getTile");
    luaT_setfunction(l_anim_set_parent, "setParent");
    luaT_setfunction(l_anim_set_flag<THAnimation>, "setFlag");
    luaT_setfunction(l_anim_set_flag_partial<THAnimation>, "setPartialFlag");
    luaT_setfunction(l_anim_get_flag<THAnimation>, "getFlag");
    luaT_setfunction(l_anim_make_visible<THAnimation>, "makeVisible");
    luaT_setfunction(l_anim_make_invisible<THAnimation>, "makeInvisible");
    luaT_setfunction(l_anim_set_tag, "setTag");
    luaT_setfunction(l_anim_get_tag, "getTag");
    luaT_setfunction(l_anim_set_position<THAnimation>, "setPosition");
    luaT_setfunction(l_anim_get_position, "getPosition");
    luaT_setfunction(l_anim_set_speed<THAnimation>, "setSpeed");
    luaT_setfunction(l_anim_set_layer<THAnimation>, "setLayer");
    luaT_setfunction(l_anim_set_layers_from, "setLayersFrom");
    luaT_setfunction(l_anim_set_hitresult, "setHitTestResult");
    luaT_setfunction(l_anim_get_marker, "getMarker");
    luaT_setfunction(l_anim_get_secondary_marker, "getSecondaryMarker");
    luaT_setfunction(l_anim_tick<THAnimation>, "tick");
    luaT_setfunction(l_anim_draw<THAnimation>, "draw", MT_Surface);
    luaT_setfunction(l_anim_set_drawable_layer, "setDrawingLayer");
    luaT_endclass();

    // Duplicate AnimMetatable[1,2] to SpriteListMetatable[1,2]
    lua_rawgeti(pState->L, pState->aiMetatables[MT_Anim], 1);
    lua_rawseti(pState->L, pState->aiMetatables[MT_SpriteList], 1);
    lua_rawgeti(pState->L, pState->aiMetatables[MT_Anim], 2);
    lua_rawseti(pState->L, pState->aiMetatables[MT_SpriteList], 2);

    // SpriteList
    luaT_class(THSpriteRenderList, l_anim_new<THSpriteRenderList>, "spriteList", MT_SpriteList);
    luaT_setmetamethod(l_anim_persist<THSpriteRenderList>, "persist");
    luaT_setmetamethod(l_anim_pre_depersist<THSpriteRenderList>, "pre_depersist");
    luaT_setmetamethod(l_anim_depersist<THSpriteRenderList>, "depersist");
    luaT_setfunction(l_srl_set_sheet, "setSheet", MT_Sheet);
    luaT_setfunction(l_srl_append, "append");
    luaT_setfunction(l_srl_set_lifetime, "setLifetime");
    luaT_setfunction(l_srl_is_dead, "isDead");
    luaT_setfunction(l_anim_set_tile<THSpriteRenderList>, "setTile", MT_Map);
    luaT_setfunction(l_anim_set_flag<THSpriteRenderList>, "setFlag");
    luaT_setfunction(l_anim_set_flag_partial<THSpriteRenderList>, "setPartialFlag");
    luaT_setfunction(l_anim_get_flag<THSpriteRenderList>, "getFlag");
    luaT_setfunction(l_anim_make_visible<THSpriteRenderList>, "makeVisible");
    luaT_setfunction(l_anim_make_invisible<THSpriteRenderList>, "makeInvisible");
    luaT_setfunction(l_anim_set_position<THSpriteRenderList>, "setPosition");
    luaT_setfunction(l_anim_set_speed<THSpriteRenderList>, "setSpeed");
    luaT_setfunction(l_anim_set_layer<THSpriteRenderList>, "setLayer");
    luaT_setfunction(l_anim_tick<THSpriteRenderList>, "tick");
    luaT_setfunction(l_anim_draw<THSpriteRenderList>, "draw", MT_Surface);
    luaT_endclass();
}
