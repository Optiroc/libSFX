.PHONY: clean submodules docs

default: cc65 superfamiconv superfamicheck brrtools lz4

all: clean default

cc65: submodules
	@$(MAKE) -C tools/cc65 bin -j4

superfamiconv: submodules
	@$(MAKE) -C tools/superfamiconv -j4

superfamicheck: submodules
	@$(MAKE) -C tools/superfamicheck

brrtools: submodules
	@$(MAKE) -C tools/brrtools

lz4: submodules
	@$(MAKE) lz4 -C tools/lz4/programs -j4

submodules:
	git submodule update --init --recursive

docs:
ifeq (, $(shell which perl))
  $(error "'perl' not found in $$PATH")
endif
ifeq (, $(shell which sassc))
  $(error "'sassc' not found in $$PATH")
endif
ifeq (, $(shell which awk))
  $(error "'awk' not found in $$PATH")
endif
	@rm -frd docs
	@mkdir -pv docs
	sassc extras/NaturalDocs/config/libsfx.scss extras/NaturalDocs/config/libsfx.css
	extras/NaturalDocs/bin/NaturalDocs -r -i include -o HTML docs -p extras/NaturalDocs/config -s libsfx -t 2
	@rm -frd ./docs/index && rm -frd ./docs/search && rm -frd ./docs/javascript
	@cp ./extras/NaturalDocs/config/readme ./docs/README.md
	@cp ./extras/NaturalDocs/config/favicon.ico ./docs/favicon.ico

clean:
	@$(MAKE) clean -C tools/cc65
	@$(MAKE) clean -C tools/superfamiconv
	@$(MAKE) clean -C tools/superfamicheck
	@$(MAKE) clean -C tools/brrtools
	@$(MAKE) clean -C tools/lz4/programs
