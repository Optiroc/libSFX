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
	@rm -frd docs
	@mkdir -pv docs
	python -m scss < extras/NaturalDocs/libsfx.scss -C >extras/NaturalDocs/libsfx.css
	naturaldocs -r -i include -o HTML docs -p extras/NaturalDocs -s libsfx -t 2
	./extras/NaturalDocs/wash.sh `find ./docs/files -name '*.html'`
	@rm -frd ./docs/index && rm -frd ./docs/search
	@cp ./extras/NaturalDocs/readme ./docs/README.md

clean:
	@$(MAKE) clean -C tools/cc65
	@$(MAKE) clean -C tools/superfamiconv
	@$(MAKE) clean -C tools/superfamicheck
	@$(MAKE) clean -C tools/brrtools
	@$(MAKE) clean -C tools/lz4/programs
