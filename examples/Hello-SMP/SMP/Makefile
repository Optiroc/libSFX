libsfx_dir		:= ../../..
smp_runtime_dir	:= $(libsfx_dir)/include/Packages/SMP_Runtime
smp_runtime_map	:= $(smp_runtime_dir)/Map.cfg
libsfx_inc		:= $(libsfx_dir)/include
libsfx_bin		:= $(libsfx_dir)/tools
rom				:= smp.bin
as				:= $(libsfx_bin)/cc65/bin/ca65
ld				:= $(libsfx_bin)/cc65/bin/ld65
obj_dir			:= .build
asflags			:= -I $(libsfx_inc) -I $(smp_runtime_dir) -I .

rwildcard		= $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

src_smp			+= $(call rwildcard, , *.s700)
src_smp_runtime += $(call rwildcard, $(smp_runtime_dir), *.s700)
obj_smp			+= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s700,%.o700,$(src_smp)))
obj_smp_runtime	+= $(patsubst $(src_dir)%,$(obj_dir)/%,$(patsubst %.s700,%.o700,$(src_smp_runtime)))

default: $(rom)

$(obj_dir)/%.o700 : %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -D TARGET_SMP -o $@ $<

$(obj_smp_runtime)/%.o700 : %.s700
	@mkdir -pv $(dir $@)
	$(as) $(asflags) -D TARGET_SMP -o $@ $<

$(rom) : $(obj_smp_runtime) $(obj_smp)
	$(ld) -C $(smp_runtime_map) -o $@ $^

clean:
	@rm -f $(rom)
	@rm -frd $(obj_dir)
