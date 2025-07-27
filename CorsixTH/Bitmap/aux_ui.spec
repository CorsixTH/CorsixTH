local SPEC = {
  sprites = { -- one bmp per line
    "build_room_dialog_close.bmp",
    "map_cell_outline.bmp",
    "flag_passable.bmp",
    "flag_travel_north.bmp",
    "flag_travel_east.bmp",
    "flag_travel_south.bmp",
    "flag_travel_west.bmp",
    "flag_hospital.bmp",
    "flag_buildable.bmp",
    "fullscreen_border_topleft.bmp",
    "fullscreen_border_top.bmp",
    "fullscreen_border_topright.bmp",
    "fullscreen_border_left.bmp",
    "fullscreen_border_right.bmp",
    "fullscreen_border_bottomleft.bmp",
    "fullscreen_border_bottom.bmp",
    "fullscreen_border_bottomright.bmp",
    "map_cell_outline_north.bmp",
    "map_cell_outline_east.bmp",
    "map_cell_outline_south.bmp",
    "map_cell_outline_west.bmp",
    "machinemenu.bmp",
    "machinemenupressed.bmp",
  },

  -- Palette options
  palette = "from bitmap",

  -- Compression options
  complex = true,
  rnc = false,

  -- Output filenames
  output_tab = "aux_ui.tab"
  output_dat = "aux_ui.dat"
}

return SPEC
