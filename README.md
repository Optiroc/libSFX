# libSFX
A Super Nintendo assembler development framework featuring:

* Basic system runtime for initialization and interrupt handling
* 65816 register size tracking macros to minimize rep/sep instructions (and mental overhead)
* Full set of memcpy/memset routines for efficiently transferring data to different parts of the system
* Some useful data structures with allocation and accessor macros (FIFO and FILO are currently implemented)
* S-SMP communication and SPC playing routines.
* LZ4 decompression
* Mouse driver
* Graphics conversion via [SuperFamiconv](https://github.com/Optiroc/SuperFamiconv)
* BRR audio encoding using [BRRtools](https://github.com/Optiroc/BRRtools)
* ROM image validation via [SuperFamicheck](https://github.com/Optiroc/SuperFamicheck)
* Sublime Text [syntax definitions](./extras/SublimeText)

Work-in-progress documentation at [optiroc.github.io/libSFX](http://optiroc.github.io/libSFX).

libSFX is developed by David Lindecrantz and distributed under the terms of the [MIT license](./LICENSE).


## dependencies
A C/C++ toolchain, make, git and a decent command line interface.  

Unix-like (Mac, Linux, etc.) systems should be ready to go out of the box. If you're running Windows the best option is to install [Cygwin](https://cygwin.com/install.html) and make sure you include the `git` and `mingw64` toolchain (`mingw64-x86_64-binutils`, `mingw64-x86_64-gcc-core` and `mingw64-x86_64-gcc-g++`) packages.


## building
First you need to build the bundled tools, which are included as git submodules. Simply run `make` from the libSFX root path to initialize the submodules and build the tools.

Now the toolchain is in place and you should be able to run `make` from any of the example directories to assemble the source files and link a Super Nintendo ROM image (*.sfc).


## setting up a project
For the most basic setup, copy `examples/Template` to a location of your liking. Then edit `Makefile` and make sure that `libsfx_dir` points to the libSFX root directory.

For project customization – for example extending the ROM size, adding SRAM or special code segments, or changing the default stack and scratchpad sizes – the build script looks for two files in the project directory; `libSFX.cfg` and `Map.cfg`. If these aren't found (like in the Template project), the defaults inside `$(libsfx_dir)/include/Configurations` are used.

To override the defaults, simply copy these two files into your project directory and edit them to your liking. In [include/Configurations](./include/Configurations/) there's a few additional Map.cfg examples. You may also check out the [example](./examples/SixteenMegaPower) [projects](./examples/SuperFX) to see how a project can be customized.


## acknowledgments
libSFX includes the following code and snippets:

* SPC-700 assembler for ca65 and S-SMP transfer routines by [Blargg](http://blargg.8bitalley.com)
* GSU assembler for ca65 by [ARM9](https://github.com/ARM9/casfx)
* ca65 define/undefine macros by [Movax12](http://forums.nesdev.com/memberlist.php?mode=viewprofile&u=4680)


## resources
* [fullsnes](http://problemkaputt.de/fullsnes.htm) - comprehensive SNES reference
* [ca65 users guide](https://cc65.github.io/doc/ca65.html)
* [SNESdev forum](http://forums.nesdev.com/viewforum.php?f=12)
