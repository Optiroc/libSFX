# Name
name := Hello

# SMP sub-projects
smp_overlays := SMP

# Include libSFX.make
libsfx_dir := ../..
include $(libsfx_dir)/libSFX.make

.PHONY: pcm
pcm:
	echo "MSU1   " > $(name)-1.pcm
	ffmpeg -i https://voyager.jpl.nasa.gov/assets/audio/golden-record/english.au -ar 44.1k -ac 2 -f s16le -acodec pcm_s16le - >> $(name)-1.pcm
