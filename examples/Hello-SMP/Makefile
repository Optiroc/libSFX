# Name
name		:= Hello-SMP
debug		:= 1

src_smp := Hello-SMP.o

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make

.PHONY: smp_code
smp_code:
	cd SMP && make
