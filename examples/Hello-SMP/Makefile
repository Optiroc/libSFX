# Name
name		:= Hello-SMP

# Debug
debug := 1
run_args := --show-debugger --break-on-wdm
breakpoints := SMP:@breakpoint_reset_sequence:x:smp

# Packages
libsfx_packages	:= SMP_Runtime

# SMP sub-projects
smp_overlays := SMP

# Include libSFX.make
libsfx_dir	:= ../..
include $(libsfx_dir)/libSFX.make
