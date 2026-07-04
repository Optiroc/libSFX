.PHONY: clean submodules docs cc65 superfamiconv superfamicheck lz4

all: clean submodules programs

programs: cc65 superfamiconv superfamicheck brrtools lz4

cc65:
	@$(MAKE) -C tools/cc65/src -j

superfamiconv:
	@$(MAKE) -C tools/superfamiconv

superfamicheck:
	@$(MAKE) -C tools/superfamicheck

brrtools:
	@$(MAKE) -C tools/brrtools

lz4:
	@$(MAKE) lz4 -C tools/lz4/programs -j

submodules:
	git submodule update --init --recursive

docs:
	@rm -frd docs
	@mkdir -pv docs
	sassc extras/NaturalDocs/config/libsfx.scss extras/NaturalDocs/config/libsfx.css
	extras/NaturalDocs/bin/NaturalDocs -r -i include -o HTML docs -p extras/NaturalDocs/config -s libsfx -t 2
	@rm -frd ./docs/index && rm -frd ./docs/search && rm -frd ./docs/javascript
	@cp ./extras/NaturalDocs/config/readme ./docs/README.md
	@cp ./extras/NaturalDocs/config/favicon.ico ./docs/favicon.ico

clean:
	@$(MAKE) clean -C tools/cc65/src
	@$(MAKE) clean -C tools/superfamiconv
	@$(MAKE) clean -C tools/superfamicheck
	@$(MAKE) clean -C tools/brrtools
	@$(MAKE) clean -C tools/lz4/programs
