# Name
name		:= Mode7-Transform
debug		:= 1

# Use packages
libsfx_packages := LZ4 Mouse

# Derived data files
derived_files += Data/Background.png.palette Data/Background.png.tiles Data/Background.png.map
derived_files += Data/Background.png.tiles.lz4 Data/Background.png.map.lz4

Data/Background.png.palette: palette_flags = -v --colors 128
Data/Background.png.tiles: tiles_flags = -v -M snes_mode7 --max-tiles 256
Data/Background.png.map: map_flags = -v -M snes_mode7

# Sine table
derived_files += Data/Sin.bin

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make

# Custom rules
Data/Sin.bin : Sin.py
	./$< $@
