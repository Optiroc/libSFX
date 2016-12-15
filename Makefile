.PHONY: clean submodules

default: cc65 superfamicheck brrtools lz4 usb2snes

all: clean default

cc65: submodules
	@$(MAKE) -C tools/cc65 bin

superfamicheck: submodules
	@$(MAKE) -C tools/superfamicheck

brrtools: submodules
	@$(MAKE) -C tools/brrtools

lz4: submodules
	@$(MAKE) lz4 -C tools/lz4/programs

usb2snes: submodules
	@$(MAKE) -C tools/usb2snes

submodules:
	git submodule update --init --recursive

clean:
	@$(MAKE) clean -C tools/cc65
	@$(MAKE) clean -C tools/superfamicheck
	@$(MAKE) clean -C tools/brrtools
	@$(MAKE) clean -C tools/lz4/programs
	@$(MAKE) clean -C tools/usb2snes
