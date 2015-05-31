.PHONY: clean

default: cc65

cc65:
	@$(MAKE) -C tools/cc65

clean:
	@$(MAKE) clean -C tools/cc65
