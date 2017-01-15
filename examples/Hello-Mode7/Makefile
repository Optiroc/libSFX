# Name
name		:= Hello-Mode7
debug		:= 1

# Derived data files
derived_files += Data/SNES-Mode7.png.palette Data/SNES-Mode7.png.tiles Data/SNES-Mode7.png.map
derived_files += Data/SNES-Mode7.png.tiles.lz4 Data/SNES-Mode7.png.map.lz4

Data/SNES-Mode7.png.palette: palette_flags = -v --colors 128
Data/SNES-Mode7.png.tiles: tiles_flags = -v -M snes_mode7 --max-tiles 256
Data/SNES-Mode7.png.map: map_flags = -v -M snes_mode7

# Use packages
libsfx_packages := LZ4

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make
