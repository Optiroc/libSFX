# Name
name        := SMP-Test
debug		:= 1

run_args := --show-debugger --break-on-wdm
breakpoints := SMP-Test:@xbr SMP-Play:@xbr:x:smp SMP-Play:@rwbr:rw:smp

# Use packages
libsfx_packages := LZ4

# SMP sub-projects
smp_overlays := SMP-Play SMP-Nop

# Example of custom options for derived files
SMP-Play/Data/Sample2.brr: brrflags = -rs1.2 -g

# Derived data files
derived_files := SMP-Play/Data/Sample1.brr SMP-Play/Data/Sample2.brr

# Explicit cleanup
clean_files := SMP-Play-ZP.bin

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make
