# Recursive wildcard
rwildcard		= $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Set defaults if not already set
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
asflags			:= -g -U -I ./ -I $(libsfx_inc) -I $(libsfx_inc)/Configurations
ldflags			:= $(dflags) --cfg-path ./ --cfg-path $(libsfx_inc)/Configurations/

# Source globs
src				:= $(call rwildcard, , *.s)
src_smp			:= $(call rwildcard, , *.s700)
libsfx_src		:= $(call rwildcard, $(libsfx_inc)/, *.s)
libsfx_src_smp	:= $(call rwildcard, $(libsfx_inc)/, *.s700)
cfg_files		:= $(wildcard *.cfg)

# Targets
rom				:= $(name).sfc
sym				:= $(name).sym
obj				:= $(patsubst $(libsfx_inc)%,$(obj_dir)/libsfx%,$(patsubst %.s,%.o,$(libsfx_src)))
obj				+= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s,%.o,$(src)))
obj_smp			:= $(patsubst $(libsfx_inc)%,$(obj_dir)/libsfx%,$(patsubst %.s700,%.o,$(libsfx_src_smp)))
obj_smp			+= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s700,%.o,$(src_smp)))

# Rules
.SUFFIXES:
.PHONY: clean

default: $(rom)

all: clean default

$(rom): $(obj) $(obj_smp)
	$(ld) $(ldflags) -C Map.cfg -o $@ -Ln $(sym) $^
	$(sfcheck) $@ -f

$(obj): $(cfg_files)

# Project obj : src
$(obj_dir)/%.o: %.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -o $@ $<

$(obj_dir)/%.o: %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -D TARGET_SMP -o $@ $<

# libSFX obj : src
$(obj_dir)/libsfx/%.o: $(libsfx_inc)/%.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -o $@ $<

$(obj_dir)/libsfx/%.o: $(libsfx_inc)/%.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -D TARGET_SMP -o $@ $<

clean:
	@rm -f $(rom) $(sym)
	@rm -frd $(obj_dir)
