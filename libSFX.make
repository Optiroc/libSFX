# Recursive wildcard
rwildcard		= $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Platform
ifeq ($(platform),)
  ifdef SystemRoot
    platform := win
  else
  	uname := $(shell uname -a)
  	ifneq ($(findstring Darwin,$(uname)),)
  	  platform := osx
  	else
  	  platform := x
  	endif
  endif
endif

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

# ca65 defines
dflags			:= -D __STACKSIZE__=\$$$(stack_size) -D __ZPADSIZE__=\$$$(zpad_size) -D __RPADSIZE__=\$$$(rpad_size)
ifdef debug
	ifeq ($(debug),1)
		dflags += -D __DEBUG__=1
	endif
endif

# Tools & flags
libsfx_inc		:= $(libsfx_dir)/include
libsfx_bin		:= $(libsfx_dir)/tools
as				:= $(libsfx_bin)/cc65/bin/ca65
ld				:= $(libsfx_bin)/cc65/bin/ld65
sfcheck			:= $(libsfx_bin)/superfamicheck/bin/superfamicheck
brr_enc			:= $(libsfx_bin)/brrtools/bin/brr_encoder
lz4_compress	:= $(libsfx_bin)/lz4/programs/lz4
usb2snes		:= $(libsfx_bin)/usb2snes/bin/usb2snes

asflags			:= -g -U -I ./ -I $(libsfx_inc) -I $(libsfx_inc)/Configurations
ldflags			:= $(dflags) --cfg-path ./ --cfg-path $(libsfx_inc)/Configurations/
brrflags		:= -rn1.0 -g
lz4flags		:= -f -9

# Source globs
src				+= $(call rwildcard, , *.s)
src_smp			+= $(call rwildcard, , *.s700)
src_gsu			+= $(call rwildcard, , *.sgs)
libsfx_src		:= $(call rwildcard, $(libsfx_inc)/, *.s)
libsfx_src_smp	:= $(call rwildcard, $(libsfx_inc)/, *.s700)
libsfx_src_gsu	:= $(call rwildcard, $(libsfx_inc)/, *.sfx)
cfg_files		:= Makefile $(libsfx_dir)/libSFX.make $(wildcard *.cfg)
derived_files	+=

# Targets
rom				:= $(name).sfc
sym				:= $(name).sym
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

$(obj): $(derived_files)
$(obj_gsu): $(derived_files)
$(obj_smp): $(derived_files)
$(derived_files): $(cfg_files)

# Link
$(rom): $(obj) $(obj_smp) $(obj_gsu)
	$(ld) $(ldflags) -C Map.cfg -o $@ -Ln $(sym) $^
	$(sfcheck) $@ -f

# libSFX obj : src
$(obj_dir)/__LIBSFX__/%.o: $(libsfx_inc)/%.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -o $@ $<

$(obj_dir)/__LIBSFX__/%.o700: $(libsfx_inc)/%.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -D TARGET_SMP -o $@ $<

# Project obj : src
$(obj_dir)/%.o: %.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -o $@ $<

$(obj_dir)/%.o700: %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -D TARGET_SMP -o $@ $<

$(obj_dir)/%.ogs: %.sgs
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -D TARGET_GSU -o $@ $<

# Derived data transformation
$(filter %.lz4,$(derived_files)): %.lz4: %
	$(lz4_compress) $(lz4flags) $< $@

$(filter %.brr,$(derived_files)): %.brr: %.wav
	@rm -f $@
	$(brr_enc) $(brrflags) $< $@

clean:
	@rm -f $(rom) $(sym) $(derived_files)
	@rm -frd $(obj_dir)
