# Name
name        := SMP-Test
debug		:= 1

# Use packages
libsfx_packages := LZ4

# SMP sub-projects
smp_overlays := SMP-Play SMP-Nop

# Example of custom options for derived files
SMP-Play/Data/Sample2.brr: brrflags = -rs1.2 -g

# Derived data files
derived_files := SMP-Play/Data/Sample1.brr SMP-Play/Data/Sample2.brr

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make
