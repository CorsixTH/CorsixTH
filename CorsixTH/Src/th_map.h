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

#ifndef CORSIX_TH_TH_MAP_H_
#define CORSIX_TH_TH_MAP_H_
#include "th_gfx.h"

/*
    Object type enumeration uses same values as original TH does.
    See game string table section 39 for proof. Section 1 also has
    names in this order.
*/
enum THObjectType
{
    THOB_NoObject = 0,
    THOB_Desk = 1,
    THOB_Cabinet = 2,
    THOB_Door = 3,
    THOB_Bench = 4,
    THOB_Table = 5, // Not in game
    THOB_Chair = 6,
    THOB_DrinksMachine = 7,
    THOB_Bed = 8,
    THOB_Inflator = 9,
    THOB_PoolTable = 10,
    THOB_ReceptionDesk = 11,
    THOB_BTable = 12, // Not in game?
    THOB_Cardio = 13,
    THOB_Scanner = 14,
    THOB_ScannerConsole = 15,
    THOB_Screen = 16,
    THOB_LitterBomb = 17,
    THOB_Couch = 18,
    THOB_Sofa = 19,
    THOB_Crash = 20, // The trolley in general diagnosis
    THOB_TV = 21,
    THOB_Ultrascan = 22,
    THOB_DNAFixer = 23,
    THOB_CastRemover = 24,
    THOB_HairRestorer = 25,
    THOB_Slicer = 26,
    THOB_XRay = 27,
    THOB_RadiationShield = 28,
    THOB_XRayViewer = 29,
    THOB_OpTable = 30,
    THOB_Lamp = 31, // Not in game?
    THOB_Sink = 32,
    THOB_OpSink1 = 33,
    THOB_OpSink2 = 34,
    THOB_SurgeonScreen = 35,
    THOB_LectureChair = 36,
    THOB_Projector = 37,
    // 38 is unused
    THOB_Pharmacy = 39,
    THOB_Computer = 40,
    THOB_ChemicalMixer = 41,
    THOB_BloodMachine = 42,
    THOB_Extinguisher = 43,
    THOB_Radiator = 44,
    THOB_Plant = 45,
    THOB_Electro = 46,
    THOB_JellyVat = 47,
    THOB_Hell = 48,
    // 49 is unused
    THOB_Bin = 50,
    THOB_Loo = 51,
    THOB_DoubleDoor1 = 52,
    THOB_DoubleDoor2 = 53,
    THOB_DeconShower = 54,
    THOB_Autopsy = 55,
    THOB_Bookcase = 56,
    THOB_VideoGame = 57,
    THOB_EntranceLeftDoor = 58,
    THOB_EntranceRightDoor = 59,
    THOB_Skeleton = 60,
    THOB_ComfyChair = 61,
    // 62 through 255 are unused
};

enum THMapNodeFlags
{
    THMN_Passable   = 1 <<  0, //!< Pathfinding: Can walk on this tile
    THMN_CanTravelN = 1 <<  1, //!< Pathfinding: Can walk to the north
    THMN_CanTravelE = 1 <<  2, //!< Pathfinding: Can walk to the east
    THMN_CanTravelS = 1 <<  3, //!< Pathfinding: Can walk to the south
    THMN_CanTravelW = 1 <<  4, //!< Pathfinding: Can walk to the west
    THMN_Hospital   = 1 <<  5, //!< World: Tile is inside a hospital building
    THMN_Hospital_Shift = 5,
    THMN_Buildable  = 1 <<  6, //!< Player: Can build on this tile
    //! Pathfinding: Normally can walk on this tile, but can't due to blueprint
    THMN_PassableIfNotForBlueprint = 1 << 7,
    THMN_PassableIfNotForBlueprint_ShiftDelta = 7,
    THMN_Room       = 1 <<  8, //!< World: Tile is inside a room
    THMN_ShadowHalf = 1 <<  9, //!< Rendering: Put block 75 over floor
    THMN_ShadowFull = 1 << 10, //!< Rendering: Put block 74 over floor
    THMN_ShadowWall = 1 << 11, //!< Rendering: Put block 156 over east wall
    THMN_DoorNorth  = 1 << 12, //!< World: Door on north wall of tile
    THMN_DoorWest   = 1 << 13, //!< World: Door on west wall of tile
    THMN_DoNotIdle  = 1 << 14, //!< World: Humanoids should not idle on tile
    THMN_TallNorth  = 1 << 15, //!< Shadows: Wall-like object on north wall
    THMN_TallWest   = 1 << 16, //!< Shadows: Wall-like object on west wall
    THMN_BuildableN = 1 << 17, //!< Can build on the north side of the tile
    THMN_BuildableE = 1 << 18, //!< Can build on the east side of the tile
    THMN_BuildableS = 1 << 19, //!< Can build on the south side of the tile
    THMN_BuildableW = 1 << 20, //!< Can build on the west side of the tile
    THMN_ObjectsAlreadyErased = 1 << 23, //!< Specifies if after a load the object types in this tile were already erased
    // NB: Bits 24 through 31 reserved for object type (that being one of the
    // THObjectType values)
};

enum THMapTemperatureDisplay
{
    THMT_Red,         //!< Default warmth colouring (red gradients)
    THMT_MultiColour, //!< Different colours (blue, green, red)
    THMT_YellowRed,   //!< Gradients of yellow, orange, and red

    THMT_Count, //!< Number of temperature display values.
};

struct THMapNode : public THLinkList
{
    THMapNode();
    ~THMapNode();

    // Linked list for entities rendered at this node
    // THLinkList::pPrev (will always be NULL)
    // THLinkList::pNext

    // Linked list for entities rendered in an early (right-to-left) pass
    THLinkList oEarlyEntities;

    // Block tiles for rendering
    // For each tile, the lower byte is the index in the sprite sheet, and the
    // upper byte is for the drawing flags.
    // Layer 0 is for the floor
    // Layer 1 is for the north wall
    // Layer 2 is for the west wall
    // Layer 3 is for the UI
    // NB: In Lua, layers are numbered 1 - 4 rather than 0 - 3
    uint16_t iBlock[4];

    // Parcels (plots) of land have an ID, with each tile in the plot having
    // that ID. Parcel 0 is the outside.
    uint16_t iParcelId;

    // Rooms have an ID, with room #0 being the corridor (and the outside).
    uint16_t iRoomId;

    // A value between 0 (extreme cold) and 65535 (extreme heat) representing
    // the temperature of the tile. To allow efficent calculation of a tile's
    // heat based on the previous tick's heat of the surrounding tiles, the
    // previous temperature is also stored, with the array indicies switching
    // every tick.
    uint16_t aiTemperature[2];

    // Flags for information (lower 24 bits) and object type (top 8 bits)
    // See THMapNodeFlags for lower 24 bits, and THObjectType for top 8.
    // The point of storing the object type here is to allow pathfinding code
    // to use object types as pathfinding goals.
    uint32_t iFlags;

    // the first 3 bits of the object store the number of additional objects stored, while
    // the remaining bits store the object type of the additional objects
    uint64_t *pExtendedObjectList;
};

class THSpriteSheet;

//! Prototype for object callbacks from THMap::loadFromTHFile
/*!
    The callback function will receive 5 arguments:
      * The opaque pointer passed to THMap::loadFromTHFile (pCallbackToken).
      * The tile X/Y position of the object.
      * The object type.
      * The object flags present in the map data. The meaning of this
        value is left unspecified.
*/
typedef void (*THMapLoadObjectCallback_t)(void*, int, int, THObjectType, uint8_t);

class THMapOverlay;

class THMap
{
public:
    THMap();
    ~THMap();

    bool setSize(int iWidth, int iHeight);
    bool loadBlank();
    bool loadFromTHFile(const unsigned char* pData, size_t iDataLength,
                        THMapLoadObjectCallback_t fnObjectCallback,
                        void* pCallbackToken);

    void save(void (*fnWriter)(void*, const unsigned char*, size_t),
              void* pToken);

    //! Set the sprite sheet to be used for drawing the map
    /*!
        The sprites for map floor tiles, wall tiles, and map decorators
        all come from the given sheet.
    */
    void setBlockSheet(THSpriteSheet* pSheet);

    //! Set the draw flags on all wall blocks
    /*!
        This is typically called with THDF_Alpha50 to draw walls transparently,
        or with 0 to draw them opaque again.
    */
    void setAllWallDrawFlags(unsigned char iFlags);

    void updatePathfinding();
    void updateShadows();
    void setTemperatureDisplay(THMapTemperatureDisplay eTempDisplay);
    inline THMapTemperatureDisplay getTemperatureDisplay() const {return m_eTempDisplay;}
    void updateTemperatures(uint16_t iAirTemperature,
                            uint16_t iRadiatorTemperature);

    //! Get the map width (in tiles)
    inline int getWidth()  const {return m_iWidth;}

    //! Get the map height (in tiles)
    inline int getHeight() const {return m_iHeight;}

    //! Get the number of plots of land in this map
    inline int getParcelCount() const {return m_iParcelCount - 1;}

    inline int getPlayerCount() const {return m_iPlayerCount;}
    bool getPlayerCameraTile(int iPlayer, int* pX, int* pY) const;
    bool getPlayerHeliportTile(int iPlayer, int* pX, int* pY) const;
    void setPlayerCameraTile(int iPlayer, int iX, int iY);
    void setPlayerHeliportTile(int iPlayer, int iX, int iY);

    //! Get the number of tiles inside a given parcel
    int getParcelTileCount(int iParcelId) const;

    //! Change the owner of a particular parcel
    /*!
        \param iParcelId The parcel of land to change ownership of. Should be
            an integer between 1 and getParcelCount() inclusive (parcel 0 is
            the outside, and should never have its ownership changed).
        \param iOwner The number of the player who should own the parcel, or
            zero if no player should own the parcel.
    */
    void setParcelOwner(int iParcelId, int iOwner);

    //! Get the owner of a particular parcel of land
    /*!
        \param iParcelId An integer between 0 and getParcelCount() inclusive.
        \return 0 if the parcel is unowned, otherwise the number of the owning
            player.
    */
    int getParcelOwner(int iParcelId) const;

    //! Query if two parcels are directly connected
    /*!
        \param iParcel1 An integer between 0 and getParcelCount() inclusive.
        \param iParcel2 An integer between 0 and getParcelCount() inclusive.
        \return true if there is a path between the two parcels which does not
            go into any other parcels. false otherwise.
    */
    bool areParcelsAdjacent(int iParcel1, int iParcel2);

    //! Query if a given player is in a position to purchase a given parcel
    /*!
        \param iParcelId The parcel of land to query. Should be an integer
            between 1 and getParcelCount() inclusive.
        \param iPlayer The number of the player to perform the query on behalf
            of. Should be a strictly positive integer.
        \return true if the parcel has a door to the outside, or is directly
            connected to a parcel already owned by the given player. false
            otherwise.
    */
    bool isParcelPurchasable(int iParcelId, int iPlayer);

    //! Draw the map (and any attached animations)
    /*!
        Draws the world pixel rectangle (iScreenX, iScreenY, iWidth, iHeight)
        to the rectangle (iCanvasX, iCanvasY, iWidth, iHeight) on pCanvas. Note
        that world pixel co-ordinates are also known as absolute screen
        co-ordinates - they are not world (tile) co-ordinates, nor (relative)
        screen co-ordinates.
    */
    void draw(THRenderTarget* pCanvas, int iScreenX, int iScreenY, int iWidth,
              int iHeight, int iCanvasX, int iCanvasY) const;

    //! Perform a hit-test against the animations attached to the map
    /*!
        If there is an animation at world pixel co-ordinates (iTestX, iTestY),
        then it is returned. Otherwise NULL is returned.
        To perform a hit-test using world (tile) co-ordinates, get the node
        itself and query the top 8 bits of THMapNode::iFlags, or traverse the
        node's animation lists.
    */
    THDrawable* hitTest(int iTestX, int iTestY) const;

    // When using the unchecked versions, the map co-ordinates MUST be valid.
    // When using the normal versions, NULL is returned for invalid co-ords.
          THMapNode* getNode(int iX, int iY);
    const THMapNode* getNode(int iX, int iY) const;
    const THMapNode* getOriginalNode(int iX, int iY) const;
          THMapNode* getNodeUnchecked(int iX, int iY);
    const THMapNode* getNodeUnchecked(int iX, int iY) const;
    const THMapNode* getOriginalNodeUnchecked(int iX, int iY) const;

    uint16_t getNodeTemperature(const THMapNode* pNode) const;
    int getNodeOwner(const THMapNode* pNode) const;

    //! Convert world (tile) co-ordinates to absolute screen co-ordinates
    template <typename T>
    static inline void worldToScreen(T& x, T& y)
    {
        T x_(x);
        x = (T)32 * (x_ - y);
        y = (T)16 * (x_ + y);
    }

    //! Convert absolute screen co-ordinates to world (tile) co-ordinates
    template <typename T>
    static inline void screenToWorld(T& x, T& y)
    {
        T x_(x);
        x = y / (T)32 + x_ / (T)64;
        y = y / (T)32 - x_ / (T)64;
    }

    void persist(LuaPersistWriter *pWriter) const;
    void depersist(LuaPersistReader *pReader);

    void setOverlay(THMapOverlay *pOverlay, bool bTakeOwnership);

protected:
    THDrawable* _hitTestDrawables(THLinkList* pListStart, int iXs, int iYs,
                                  int iTestX, int iTestY) const;
    void _readTileIndex(const unsigned char* pData, int& iX, int &iY) const;
    void _writeTileIndex(unsigned char* pData, int iX, int iY) const;
    int _getParcelTileCount(int iParcelId) const;

    //! Create the adjacency matrix if it doesn't already exist
    void _makeAdjacencyMatrix();

    //! Create the purchasability matrix if it doesn't already exist
    void _makePurchaseMatrix();

    //! If it exists, update the purchasability matrix.
    void _updatePurchaseMatrix();

    THMapNode* m_pCells;
    THMapNode* m_pOriginalCells; // Cells at map load time, before any changes
    THSpriteSheet* m_pBlocks;
    THMapOverlay* m_pOverlay;
    bool m_bOwnOverlay;
    int* m_pPlotOwner; // 0 for unowned, 1 for player 1, etc.
    int m_iWidth;
    int m_iHeight;
    int m_iPlayerCount;
    int m_aiInitialCameraX[4];
    int m_aiInitialCameraY[4];
    int m_aiHeliportX[4];
    int m_aiHeliportY[4];
    int m_iParcelCount;
    int m_iCurrentTemperatureIndex;
    THMapTemperatureDisplay m_eTempDisplay;
    int* m_pParcelTileCounts;

    // 2D symmetric array giving true if there is a path between two parcels
    // which doesn't go into any other parcels.
    bool* m_pParcelAdjacencyMatrix;

    // 4 by N matrix giving true if player can purchase parcel.
    bool* m_pPurchasableMatrix;
};

enum eTHMapScanlineIteratorDirection
{
    ScanlineForward = 2,
    ScanlineBackward = 0,
};

//! Utility class for iterating over map nodes within a screen rectangle
/*!
    To easily iterate over the map nodes which might draw something within a
    certain rectangle of screen space, an instance of this class can be used.

    By default, it iterates by scanline, top-to-bottom, and then left-to-right
    within each scanline. Alternatively, by passing ScanlineBackward to the
    constructor, it will iterate bottom-to-top. Within a scanline, to visit
    nodes right-to-left, wait until isLastOnScanline() returns true, then use
    an instance of THMapScanlineIterator.
*/
class THMapNodeIterator
{
public:
    THMapNodeIterator();

    /*!
        @arg pMap The map whose nodes should be iterated
        @arg iScreenX The X co-ordinate of the top-left corner of the
            screen-space rectangle to iterate.
        @arg iScreenY The Y co-ordinate of the top-left corner of the
            screen-space rectangle to iterate.
        @arg iWidth The width of the screen-space rectangle to iterate.
        @arg iHeight The width of the screen-space rectangle to iterate.
        @arg eScanlineDirection The direction in which to iterate scanlines;
            ScanlineForward for top-to-bottom, ScanlineBackward for bottom-to-top.
    */
    THMapNodeIterator(const THMap *pMap, int iScreenX, int iScreenY,
                      int iWidth, int iHeight,
                      eTHMapScanlineIteratorDirection eScanlineDirection = ScanlineForward);

    //! Returns false iff the iterator has exhausted its nodes
    inline operator bool () const {return m_pNode != NULL;}

    //! Advances the iterator to the next node
    inline THMapNodeIterator& operator ++ ();

    //! Accessor for the current node
    inline const THMapNode* operator -> () const {return m_pNode;}

    //! Get the X position of the node relative to the top-left corner of the screen-space rectangle
    inline int x() const {return m_iXs;}

    //! Get the Y position of the node relative to the top-left corner of the screen-space rectangle
    inline int y() const {return m_iYs;}

    inline int nodeX() const {return m_iX;}
    inline int nodeY() const {return m_iY;}

    inline const THMap *getMap() {return m_pMap;}
    inline const THMapNode *getMapNode() {return m_pNode;}
    inline int getScanlineCount() { return m_iScanlineCount;}
    inline int getNodeStep() {return (static_cast<int>(m_eDirection) - 1) * (1 - m_pMap->getWidth());}

    //! Returns true iff the next node will be on a different scanline
    /*!
        To visit a scanline in right-to-left order, or to revisit a scanline,
        wait until this method returns true, then use a THMapScanlineIterator.
    */
    inline bool isLastOnScanline() const;

protected:
    // Maximum extents of the visible parts of a node (pixel distances relative
    // to the top-most corner of an isometric cell)
    // If set too low, things will disappear when near the screen edge
    // If set too high, rendering will slow down
    static const int ms_iMarginTop = 150;
    static const int ms_iMarginLeft = 110;
    static const int ms_iMarginRight = 110;
    static const int ms_iMarginBottom = 150;

    friend class THMapScanlineIterator;

    const THMapNode* m_pNode;
    const THMap* m_pMap;
    int m_iXs;
    int m_iYs;
    const int m_iScreenX;
    const int m_iScreenY;
    const int m_iScreenWidth;
    const int m_iScreenHeight;
    int m_iBaseX;
    int m_iBaseY;
    int m_iX;
    int m_iY;
    int m_iScanlineCount;
    eTHMapScanlineIteratorDirection m_eDirection;

    void _advanceUntilVisible();
};

//! Utility class for re-iterating a scanline visited by a THMapNodeIterator
class THMapScanlineIterator
{
public:
    THMapScanlineIterator();

    /*!
        @arg itrNodes A node iterator which has reached the end of a scanline
        @arg eDirection The direction in which to iterate the scanline;
            ScanlineForward for left-to-right, ScanlineBackward for right-to-left.
        @arg iXOffset If given, values returned by x() will be offset by this.
        @arg iYOffset If given, values returned by y() will be offset by this.
    */
    THMapScanlineIterator(const THMapNodeIterator& itrNodes,
                          eTHMapScanlineIteratorDirection eDirection,
                          int iXOffset = 0, int iYOffset = 0);

    inline operator bool () const {return m_pNode != m_pNodeEnd;}
    inline THMapScanlineIterator& operator ++ ();

    inline const THMapNode* operator -> () const {return m_pNode;}
    inline int x() const {return m_iXs;}
    inline int y() const {return m_iYs;}
    inline const THMapNode* getNextNode()  {return m_pNode + m_iNodeStep;}
    inline const THMapNode* getPreviousNode() { return m_pNode - m_iNodeStep;}
    THMapScanlineIterator operator= (const THMapScanlineIterator &iterator);
    inline const THMapNode* getNode() {return m_pNode;}

protected:
    const THMapNode* m_pNode;
    const THMapNode* m_pNodeFirst;
    const THMapNode* m_pNodeEnd;
    int m_iNodeStep;
    int m_iXStep;
    int m_iXs;
    int m_iYs;
    int m_takenSteps;
};

#endif // CORSIX_TH_TH_MAP_H_
