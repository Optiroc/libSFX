# Name
name := MSU1

# SMP sub-projects
smp_overlays := SMP

# Cleanup MSU files
clean_files := $(name)-*.pcm $(name).msu

# Include libSFX.make
libsfx_dir := ../..
include $(libsfx_dir)/libSFX.make

# https://voyager.jpl.nasa.gov/golden-record/whats-on-the-record/greetings/
msu:
	touch $(name).msu
	printf "MSU1\0\0\0\0" > $(name)-1.pcm
	ffmpeg -i https://voyager.jpl.nasa.gov/assets/audio/golden-record/english.au -ar 44.1k -ac 2 -f s16le -acodec pcm_s16le - >> $(name)-1.pcm
	printf "MSU1\0\0\0\0" > $(name)-2.pcm
	ffmpeg -i https://voyager.jpl.nasa.gov/assets/audio/golden-record/swedish.au -ar 44.1k -ac 2 -f s16le -acodec pcm_s16le - >> $(name)-2.pcm
