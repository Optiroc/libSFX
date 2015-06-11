# Set defaults if not already set
ifndef obj_dir
obj_dir     := .o
endif
ifndef stack_size
stack_size  := 100
endif
ifndef zpad_size
zpad_size  := 20
endif
ifndef rpad_size
rpad_size  := 100
endif

# Recursive wildcard
rwildcard   = $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# Tools & flags
toolsdir		:= $(libsfx_dir)/../tools
as          := $(toolsdir)/cc65/bin/ca65
ld				  := $(toolsdir)/cc65/bin/ld65

dflags      := -D __STACKSIZE__=\$$$(stack_size) -D __ZPADSIZE__=\$$$(zpad_size) -D __RPADSIZE__=\$$$(rpad_size)
asflags			:= -g -U -I ./ -I $(libsfx_dir) -I $(libsfx_dir)/Configurations
ldflags     := $(dflags) --cfg-path ./ --cfg-path $(libsfx_dir)/Configurations/

# Source globs
src := $(call rwildcard, , *.s)
src_smp := $(call rwildcard, , *.s700)
libsfx_src := $(call rwildcard, $(libsfx_dir)/, *.s)
libsfx_src_smp := $(call rwildcard, $(libsfx_dir)/, *.s700)
cfg_files := $(wildcard *.cfg)


# Targets
rom := $(name).sfc
sym := $(name).sym
obj := $(patsubst $(libsfx_dir)%,$(obj_dir)/libsfx%,$(patsubst %.s,%.o,$(libsfx_src)))
obj += $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s,%.o,$(src)))
obj_smp := $(patsubst $(libsfx_dir)%,$(obj_dir)/libsfx%,$(patsubst %.s700,%.o,$(libsfx_src_smp)))
obj_smp += $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s700,%.o,$(src_smp)))


# Rules
.SUFFIXES:
.PHONY: clean

default: $(rom)

all: clean default

$(rom): $(obj) $(obj_smp)
	$(ld) $(ldflags) -C Map.cfg -o $@ -Ln $(sym) $^

$(obj): $(cfg_files)


# Project obj : src
$(obj_dir)/%.o: %.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -o $@ $<

$(obj_dir)/%.o: %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -D TARGET_SMP -o $@ $<

# libSFX obj : src
$(obj_dir)/libsfx/%.o: $(libsfx_dir)/%.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -o $@ $<

$(obj_dir)/libsfx/%.o: $(libsfx_dir)/%.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(dflags) -D TARGET_SMP -o $@ $<


clean:
	@rm -f $(rom) $(sym)
	@rm -frd $(obj_dir)
