#libSFX
Super Nintendo development framework
by David Lindecrantz, <optiroc@gmail.com>


##features
* Basic system runtime for initialization and interrupt handling.
* 65816 register size tracking macros to minimize rep/sep instructions.
* Full set of memcpy/memset routines for efficiently transferring data to different parts of the system.
* S-SMP communication and SPC playing routines.
* LZ4 decompression.
* Sublime Text syntax definitions.

Look into the the include files (*.i) in the libSFX directory for full documentation of the library features.


##dependencies
GNU Make and a decent command line interface.


##building
First you need to build ca65, which is included as a git submodule. Run `git submodule init` and `git submodule update` to fetch the submodules, then run `make` to build.

Now that the toolchain is in place you can run `make` in any of the example directories to assemble the source files into a Super Nintendo ROM image (*.sfc).


##setting up a project
For the most basic setup, copy "examples/Template" to a location of your liking. Then edit "Makefile" and make sure that *libsfx_dir* points to the libSFX subdirectory in the project root.

For project customization (for example extending the ROM size from the default 1 megabit configuration or changing the default stack and scratchpad sizes) the build script looks for two files inside the project directory; "libSFX.cfg" and "Map.cfg". If these aren't found (like in the Template project), the defaults inside "libSFX/Configurations" are used.

To override the defaults, simply copy these two files into your project directory and edit them to your liking. Inside "libSFX/Configurations" there's a couple more Map.cfg examples, and you can also check out the *SixteenMegaPower* example project (which uses a whopping 64 x 32kB ROM banks and a healthy amount of save RAM).


##work in progress
* More fleshed out examples.
* Macros for handling common CPU/PPU register flags.
* Asset conversion tools.


##acknowledgments
libSFX includes the following code and snippets:

* SPC-700 assembler for ca65 and S-SMP transfer routines by Shay Green, aka [Blargg](http://blargg.8bitalley.com)
* ca65 define/undefine macros by [Movax12](http://forums.nesdev.com/memberlist.php?mode=viewprofile&u=4680)
