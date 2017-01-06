# Output
ifeq ($(name),)
	name := out
endif

rom				:= $(name).sfc
debug_sym		:= $(name).dsym
debug_map		:= $(name).dmap

# Tools
libsfx_bin		:= $(libsfx_dir)/tools
as				:= $(libsfx_bin)/cc65/bin/ca65
ld				:= $(libsfx_bin)/cc65/bin/ld65
sfcheck			:= $(libsfx_bin)/superfamicheck/bin/superfamicheck
brr_enc			:= $(libsfx_bin)/brrtools/bin/brr_encoder
lz4_compress	:= $(libsfx_bin)/lz4/programs/lz4
usb2snes		:= $(libsfx_bin)/usb2snes/bin/usb2snes

rwildcard		= $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Set defaults
ifndef obj_dir
	obj_dir		:= .o
endif
ifndef stack_size
	stack_size	:= 100
endif
ifndef zpad_size
	zpad_size	:= 20
endif
ifndef rpad_size
	rpad_size  := 100
endif

# Flags
libsfx_inc		:= $(libsfx_dir)/include
asflags			:= -D __STACKSIZE__=\$$$(stack_size) -D __ZPADSIZE__=\$$$(zpad_size) -D __RPADSIZE__=\$$$(rpad_size)
ldflags       	:=

ifdef debug
	ifeq ($(debug),1)
		asflags += -D __DEBUG__=1
		ldflags += -Ln $(debug_sym) -m $(debug_map) -vm
	endif
endif

asflags			+= -g -U -I ./ -I $(libsfx_inc) -I $(libsfx_inc)/Configurations
ldflags			+= --cfg-path ./ --cfg-path $(libsfx_inc)/Configurations/
brrflags		:= -rn1.0 -g
lz4flags		:= -f -9


# Include all source files under working directory if $(src) isn't set
ifndef src
  	src			+= $(call rwildcard, , *.s)
endif
ifndef src_smp
	src_smp		+= $(call rwildcard, , *.s700)
endif
ifndef src_gsu
	src_gsu		+= $(call rwildcard, , *.sgs)
endif

derived_files	+=


# libSFX
libsfx_src		:= $(wildcard $(libsfx_inc)/CPU/*.s)
libsfx_src_smp	:= $(wildcard $(libsfx_inc)/SMP/*.s700)

# libSFX packages
sfx_incs := $(foreach inc,$(addprefix $(libsfx_inc)/Packages/,$(libsfx_packages)),$(wildcard $(inc)/config))
include $(sfx_incs)

# Configuration file dependencies
cfg_files		:= Makefile $(libsfx_dir)/libSFX.make
ifneq ("$(wildcard libSFX.cfg)","")
	cfg_files	+= libSFX.cfg
endif
ifneq ("$(wildcard Map.cfg)","")
	cfg_files	+= Map.cfg
endif

# Source -> obj targets
obj				:= $(patsubst $(libsfx_inc)%,$(obj_dir)/__LIBSFX__%,$(patsubst %.s,%.o,$(libsfx_src)))
obj				+= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s,%.o,$(src)))
obj_smp			:= $(patsubst $(libsfx_inc)%,$(obj_dir)/__LIBSFX__%,$(patsubst %.s700,%.o700,$(libsfx_src_smp)))
obj_smp			+= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s700,%.o700,$(src_smp)))
obj_gsu			:= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.sgs,%.ogs,$(src_gsu)))


# Rules
.SUFFIXES:
.PHONY: clean

default: $(rom)

all: clean default

run: $(rom)
ifdef LIBSFX_RUNCMD
	$(LIBSFX_RUNCMD)
else
	@echo NB! To enable running set LIBSFX_RUNCMD, for example:
	@echo \ \ \ \ export LIBSFX_RUNCMD\=\'open -a \~/bsnes/bsnes+.app --args \$$\(realpath \$$\(rom\)\)\'
endif

$(obj): $(derived_files) $(cfg_files)
$(obj_gsu): $(derived_files) $(cfg_files)
$(obj_smp): $(derived_files) $(cfg_files)
$(derived_files): $(cfg_files)

# Link
$(rom): $(obj) $(obj_smp) $(obj_gsu)
	$(ld) $(ldflags) -C Map.cfg -o $@ $^
	$(sfcheck) $@ -f

# libSFX obj : src
$(obj_dir)/__LIBSFX__/%.o: $(libsfx_inc)/%.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -o $@ $<

$(obj_dir)/__LIBSFX__/%.o700: $(libsfx_inc)/%.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -D TARGET_SMP -o $@ $<

# Project obj : src
$(obj_dir)/%.o: %.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -o $@ $<

$(obj_dir)/%.o700: %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -D TARGET_SMP -o $@ $<

$(obj_dir)/%.ogs: %.sgs
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -D TARGET_GSU -o $@ $<

# Derived file transformations
$(filter %.lz4,$(derived_files)): %.lz4: %
	$(lz4_compress) $(lz4flags) $< $@

$(filter %.brr,$(derived_files)): %.brr: %.wav
	@rm -f $@
	$(brr_enc) $(brrflags) $< $@

clean:
	@rm -f $(rom) $(debug_sym) $(debug_map) $(derived_files)
	@rm -frd $(obj_dir)
