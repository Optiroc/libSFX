# Name
name		:= Mouse
debug		:= 1

# Use packages
libsfx_packages := LZ4 Mouse

# Derived data files
derived_files	:= Data/SNES.png.palette Data/SNES.png.tiles Data/SNES.png.map
derived_files	+= Data/SNES.png.tiles.lz4 Data/SNES.png.map.lz4

derived_files	+= Data/Sprites.png.palette Data/Sprites.png.tiles
derived_files	+= Data/Sprites.png.tiles.lz4

# Use --no-discard option for sprite sheets
Data/Sprites.png.tiles: tiles_flags = -v --no-discard

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make
