# Custom Bitmaps

Almost all graphics resources are loaded from the original Theme Hospital data
files, which is why there are only a few files in this directory.

The following, when in bmp format, are converted to .dat, .tab, and .pal files using the mkraw/mksheet/mkfont/mkbootstrap tools.

build_room_dialog_close.bmp : this sprite is missing from the game's REQ09V.DAT\
map_cell_outline.bmp : there is no nice outline tile in the game's VBLK-0.DAT\
flag_*.bmp : used as debug overlays\
fullscreen_border_*.bmp : used as borders as 640x480 "fullscreen" backgrounds\
bootstrap_font.bmp : a homemade bitmap font which can be used for drawing text
                     before the original data files are loaded.

### aux_ui sprite sheet (main palette)

| ID | Filename |
|----|----------|
| 01 | build_room_dialog_close.bmp |
| 02 | map_cell_outline.bmp |
| 03 | flag_passable.bmp |
| 04 | flag_travel_north.bmp |
| 05 | flag_travel_east.bmp |
| 06 | flag_travel_south.bmp |
| 07 | flag_travel_west.bmp |
| 08 | flag_hospital.bmp |
| 09 | flag_buildable.bmp |
| 10 | fullscreen_border_topleft.bmp |
| 11 | fullscreen_border_top.bmp |
| 12 | fullscreen_border_topright.bmp |
| 13 | fullscreen_border_left.bmp |
| 14 | fullscreen_border_right.bmp |
| 15 | fullscreen_border_bottomleft.bmp |
| 16 | fullscreen_border_bottom.bmp |
| 17 | fullscreen_border_bottomright.bmp |


-------------------------------------------------------------------------------

**Adding main menu backgrounds**

We support loading PNG images into CorsixTH, and main menu backgrounds should be added as such.\
Naming format cosists of `mainmenu_option_width_height.png` (case sensitive) where:
- option: id of the background (used to identify it)
- width: the width of the image in pixels
- height: the height of the image in pixels

### Current backgrounds

| ID | Description | Available Resolutions |
| -- | ----------- | --------------------- |
| 1  | CorsixTH 2011 | 640x480, 1280x720, 1920x1080 | 


