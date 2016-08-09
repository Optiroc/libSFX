.PHONY: clean submodules

default: cc65 superfamicheck brrtools

all: clean default

cc65: submodules
	@$(MAKE) -C tools/cc65 bin

superfamicheck: submodules
	@$(MAKE) -C tools/superfamicheck

brrtools: submodules
	@$(MAKE) -C tools/brrtools

submodules:
	git submodule update

clean:
	@$(MAKE) clean -C tools/cc65
	@$(MAKE) clean -C tools/superfamicheck
	@$(MAKE) clean -C tools/brrtools
