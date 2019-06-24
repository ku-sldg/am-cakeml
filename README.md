# Building

## Basics
[Download](https://cakeml.org/download.html) and build the 64-bit version of the CakeML compiler (or the 32-bit version if you are building for the Odroid). The Makefile for this project assumes the CakeML compiler and `basis_ffi.c` to be in the directory `~/cake-x64-64`. If you want to put it somewhere else, just change the `CAKE_DIR` variable in the Makefile, or overwrite the variable when you invoke the Makefile (e.g. `make CAKE_DIR=/someOtherLocation/cake-x64-64"`).

Typing `make` from the top-level directory will build the `test` executable. Type `make` in the `AMserver` directory to build the server and test client executables.

## Platforms
Currently, this project should run under Linux and macOS. We plan to eventually support a version which runs under a seL4 CAmkES component.

## Advanced options
The Makefile uses several internal variables for configuration. You may overwrite the default values at build-time with the command `make <var>=<val>`, e.g. `make CC=ccomp`.

- `CC`: determines the C compiler. It defaults to gcc. CompCert is also supported. Clang is tested less frequently, but should ideally also work.

- `CFLAGS`: the flags sent to the C compiler. Defaults to `-Wall`, which enables common warnings.

- `CAKE_DIR`: the directory where the CakeML compiler and `basis_ffi.c` resides. Defaults to `~/cake-x64-64`.

# Misc.

## Why are you using the sml file extension for CakeML files?
To make use of sml syntax highlighting. CakeML does stray from SML syntax slightly, but it is better than nothing 😃.

## Why does the makefile append CakeML files together?
CakeML does not support any mechanism of combining source files. For the purpose of organization and modularity, we separate the source code regardless. In order to build our scattered CakeML, we combine them with `cat` in order to feed a single file to the CakeML compiler. This, however, necessitates that we append in an order which respects the dependencies of each file.

I have adopted the convention of listing the dependencies at the top of each file within a comment, from which you may manually derive an appension order. Alternatively, I wrote a quick python script that can derive such an ordering automatically. File dependencies are described in an external file, using syntax inspired by makefiles (checkout `buildscripts/deps.make`). You can print the ordering to the terminal by running `./topOrd.py deps.make` from the `buildscripts` directory.

The python script is probably pretty fragile (I don't write python often, and I coded this up pretty quickly), but I figured it would be nice to have an alternative to managing dependencies manually, especially as the project scales. Let me know if it is unintuitive or if something breaks.

## Adding CakeML source files
To add a CakeML source file to the build, just add it to the `APPEND_LIST` variable in the makefile. As described in the previous section, The list must be ordered according to their dependencies, so you can figure that out by hand, or you can use my python script.

It would also be nice if you put a comment at the top of your CakeML file describing its dependencies, so others can keep track of it as well.
