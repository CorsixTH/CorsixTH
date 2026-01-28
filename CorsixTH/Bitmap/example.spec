--[[ EXAMPLE SPEC FILE FOR MAKING SPRITESHEETS ]]
-- Specify your sprites (BMP images) and output file locations
-- It is recommended to leave palette and compression options at their default values
local SPEC = {
  sprites = { -- one bmp per line
    "example1.bmp",
    "example2.bmp",
  },
  -- Palette options
  palette = "from bitmap",

  -- Compression options
  complex = true,
  rnc = false,

  -- Output filenames
  output_tab = "example.tab",
  output_dat = "example.dat",
}

return SPEC
