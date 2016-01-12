.PHONY: clean

default: cc65 superfamicheck

all: clean default

cc65:
	@$(MAKE) -C tools/cc65

superfamicheck:
	@$(MAKE) -C tools/superfamicheck

clean:
	@$(MAKE) clean -C tools/cc65
	@$(MAKE) clean -C tools/superfamicheck
