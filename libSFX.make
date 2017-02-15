# Validate variables
ifndef name
name		:= out
endif

ifeq ($(name),)
name 		:= out
endif

ifndef debug
debug		:= 0
endif

# Output
rom		:= $(name).sfc

# Default rule
.SUFFIXES:
.PHONY: clean

default: $(rom)

# Tools
libsfx_bin	:= $(libsfx_dir)/tools
as		:= $(libsfx_bin)/cc65/bin/ca65
ld		:= $(libsfx_bin)/cc65/bin/ld65
sfcheck		:= $(libsfx_bin)/superfamicheck/bin/superfamicheck
superfamiconv	:= $(libsfx_bin)/superfamiconv/bin/superfamiconv
brr_enc		:= $(libsfx_bin)/brrtools/bin/brr_encoder
lz4_compress	:= $(libsfx_bin)/lz4/programs/lz4
usb2snes	:= $(libsfx_bin)/usb2snes/bin/usb2snes

rwildcard = $(strip $(filter $(if $2,$2,%),$(foreach f,$(wildcard $1*),$(eval t = $(call rwildcard,$f/)) $(if $t,$t,$f))))

# File extensions
debug_sym_ext	:= dsym
debug_map_ext	:= dmap
debug_nfo_ext	:= dnfo

# Set defaults
ifndef obj_dir
obj_dir		:= .build
endif
ifndef stack_size
stack_size	:= 100
endif
ifndef zpad_size
zpad_size	:= 10
endif
ifndef znmi_size
znmi_size	:= 10
endif
ifndef rpad_size
rpad_size	:= 100
endif

obj_dir_sfx	:= $(obj_dir)_libsfx

# Flags
libsfx_inc	:= $(libsfx_dir)/include
asflags		:= -D __STACKSIZE__=\$$$(stack_size) -D __ZPADSIZE__=\$$$(zpad_size) -D __ZNMISIZE__=\$$$(znmi_size) -D __RPADSIZE__=\$$$(rpad_size)
ldflags       	:=

ifeq ($(debug),1)
asflags 	+= -D __DEBUG__=1
ldflags 	+= -Ln $(name).$(debug_sym_ext) -m $(name).$(debug_map_ext) -vm --dbgfile $(name).$(debug_nfo_ext)
endif

asflags		+= -g -U -I ./ -I $(libsfx_inc) -I $(libsfx_inc)/Configurations
ldflags		+= --cfg-path ./ --cfg-path $(libsfx_inc)/Configurations/
brr_flags	:= -rn1.0 -g
lz4_flags	:= -f -9
palette_flags   := -v
tiles_flags     := -v
map_flags       := -v


# Include all source files under working directory if $(src) isn't set
ifndef src
src		:= $(call rwildcard, ,%.s)
endif
ifndef src_smp
src_smp		:= $(call rwildcard, ,%.s700)
endif
ifndef src_gsu
src_gsu		:= $(call rwildcard, ,%.sgs)
endif

# libSFX
libsfx_src	:= $(wildcard $(libsfx_inc)/CPU/*.s)
libsfx_src_smp	:= $(wildcard $(libsfx_inc)/SMP/*.s700)

# libSFX packages
sfx_incs	:= $(foreach inc,$(addprefix $(libsfx_inc)/Packages/,$(libsfx_packages)),$(wildcard $(inc)/config))
include $(sfx_incs)


# Configure SMP sub-projects
smp_overlays_src :=
smp_overlays_obj :=

define smp_overlay_add_src
smp_overlays_obj += $(patsubst %,$(obj_dir)/%,$(patsubst %.s700,%.o700,$(1)))
$(patsubst %,$(obj_dir)/%,$(patsubst %.s700,%.o700,$(1))): asflags = -g -U -I $(dir $(1)) -I ./ -I $(libsfx_inc) -I $(libsfx_inc)/Configurations
endef

define smp_overlay_add_product
smp_overlays_products := $(smp_overlays_products) $(1).bin
$(1).bin : $(filter $(obj_dir)/$(1)/%,$(smp_overlays_obj))
ifeq ($(debug),1)
	$(ld) --cfg-path ./$(1) --cfg-path $(libsfx_inc)/Configurations/SMP -C Map.cfg -Ln $(1).$(debug_sym_ext) -m $(1).$(debug_map_ext) -vm --dbgfile $(1).$(debug_nfo_ext) -o $(1).bin $(filter $(obj_dir)/$(1)/%,$(smp_overlays_obj))
else
	$(ld) --cfg-path ./$(1) --cfg-path $(libsfx_inc)/Configurations/SMP -C Map.cfg -o $(1).bin $(filter $(obj_dir)/$(1)/%,$(smp_overlays_obj))
endif
endef

ifdef smp_overlays
src_smp := $(filter-out $(foreach sub,$(smp_overlays),$(call rwildcard,$(sub)/,%.s700)),$(src_smp))
smp_overlays_src += $(foreach sub,$(smp_overlays),$(call rwildcard,$(sub)/,%.s700))
$(foreach src,$(smp_overlays_src),$(eval $(call smp_overlay_add_src,$(src))))
$(foreach sub,$(smp_overlays),$(eval $(call smp_overlay_add_product,$(sub))))
endif


# Configuration file dependencies
cfg_files	:= Makefile $(libsfx_dir)/libSFX.make
ifneq ("$(wildcard libSFX.cfg)","")
cfg_files	+= libSFX.cfg
endif
ifneq ("$(wildcard Map.cfg)","")
cfg_files	+= Map.cfg
endif

# Source -> obj targets
obj_sfx		:= $(patsubst $(libsfx_inc)%,$(obj_dir_sfx)%,$(patsubst %.s,%.o,$(libsfx_src)))
obj_smp_sfx	:= $(patsubst $(libsfx_inc)%,$(obj_dir_sfx)%,$(patsubst %.s700,%.o700,$(libsfx_src_smp)))
obj		:= $(patsubst %,$(obj_dir)/%,$(patsubst %.s,%.o,$(src)))
obj_smp		:= $(patsubst %,$(obj_dir)/%,$(patsubst %.s700,%.o700,$(src_smp)))
obj_gsu		:= $(patsubst %,$(obj_dir)/%,$(patsubst %.sgs,%.ogs,$(src_gsu)))


# Rules
all: clean default

run: $(rom)
ifdef LIBSFX_RUNCMD
	$(LIBSFX_RUNCMD)
else
	@echo NB! To enable running set LIBSFX_RUNCMD, for example \(macOS\):
	@echo \ \ \ \ export LIBSFX_RUNCMD\=\'open -a \~/bsnes/bsnes+.app --args \$$\(realpath \$$\(rom\)\)\'
endif

clean:
	@rm -f $(rom) *.$(debug_sym_ext) *.$(debug_map_ext) *.$(debug_nfo_ext) $(derived_files) $(smp_overlays_products)
	@rm -frd $(obj_dir) $(obj_dir_sfx)


# Data/configuration files as prerequisites
$(derived_files) : $(cfg_files)
$(smp_overlays_obj) : $(derived_files) $(cfg_files)
$(obj) : $(smp_overlays_products) $(derived_files) $(cfg_files)
$(obj_gsu) : $(derived_files) $(cfg_files)
$(obj_smp) : $(derived_files) $(cfg_files)
$(obj_sfx) : $(cfg_files)
$(obj_smp_sfx) : $(cfg_files)

# Link
$(rom) : $(obj_sfx) $(obj_smp_sfx) $(obj) $(obj_smp) $(obj_gsu)
	$(ld) $(ldflags) -C Map.cfg -o $@ $^
	$(sfcheck) $@ -f

# Project obj : src
$(obj_dir)/%.o : %.s | $(smp_overlays_products)
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(pkg_asflags) -o $@ $<

$(obj_dir)/%.o700 : %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(pkg_asflags) -D TARGET_SMP -o $@ $<

$(obj_dir)/%.ogs : %.sgs
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(pkg_asflags) -D TARGET_GSU -o $@ $<

# libSFX obj : src
$(obj_dir_sfx)/%.o : $(libsfx_inc)/%.s
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(pkg_asflags) -o $@ $<

$(obj_dir_sfx)/%.o700 : $(libsfx_inc)/%.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) $(pkg_asflags) -D TARGET_SMP -o $@ $<


# Derived file transformations
$(filter %.palette,$(derived_files)) : %.palette : %
	$(superfamiconv) palette $(palette_flags) --in-image $* --out-data $@

$(filter %.tiles,$(derived_files)) : %.tiles : % %.palette
	$(superfamiconv) tiles $(tiles_flags) --in-image $* --in-palette $*.palette --out-data $@

$(filter %.map,$(derived_files)) : %.map : % %.palette %.tiles
	$(superfamiconv) map $(map_flags) --in-image $* --in-palette $*.palette --in-tiles $*.tiles --out-data $@

$(filter %.m7d,$(derived_files)) : %.m7d : % %.palette %.tiles
	$(superfamiconv) map $(map_flags) --mode snes_mode7 --in-image $* --in-palette $*.palette --in-tiles $*.tiles --out-m7-data $@

$(filter %.brr,$(derived_files)): %.brr : %.wav
	@rm -f $@
	$(brr_enc) $(brr_flags) $< $@

$(filter %.lz4,$(derived_files)) : %.lz4 : %
	$(lz4_compress) $(lz4_flags) $* $@
	@touch $@
