# Building

## How to
[Download](https://cakeml.org/download.html) and build the 64-bit version of the CakeML compiler (It should include a makefile, just type `make cake`). The makefile for this project assumes the cake compiler and `basis_ffi.c` to be in the directory `~/cake-x64-64`. If you want to put it somewhere else, just change the `CAKE_DIR` variable in the makefile, or override the variable when you invoke the makefile (e.g. `make CAKE_DIR=/someOtherLocation/cake-x64-64"`).

Typing `make` will build the `apdt` executable.

## Platforms
Currently, this project should run under Linux and macOS*. Eventually, we will support seL4 as well.

\*This project _should_ run on macOS, but is more frequently tested on Linux. Let me know if you have any problems running under macOS.

## Compiling with CompCert
You can replace gcc with CompCert by overriding the `CC` makefile variable from the command-line, i.e. `make CC=ccomp`. You may need to re-download CakeML, since older versions were missing a necessary header include in `basis_ffi.c` (although for some reason the header wasn't required by gcc?).

## Why are you using the sml file extension for CakeML files?
To make use of sml syntax highlighting.

## Why does the makefile append CakeML files together?
CakeML does not support any mechanism of combining source files. For the purpose of organization and modularity, we separate the source code regardless. In order to build our scattered CakeML, we combine them with `cat` in order to feed a single file to the CakeML compiler. This, however, necessitates that we append in an order which respects the dependencies of each file.

I have adopted the convention of listing the dependencies at the top of each file within a comment, from which you may manually derive an appension order. Alternatively, I wrote a quick python script that can derive such an ordering automatically. File dependencies are described in an external file, using syntax inspired by makefiles (checkout `buildscripts/deps.make`). You can print the ordering to the terminal by running `./topOrd.py deps.make` from the `buildscripts` directory.

The python script is probably pretty fragile (I don't write python often, and I coded this up pretty quickly), but I figured it would be nice to have an alternative to managing dependencies manually, especially as the project scales. Let me know if it is unintuitive or if something is broken.

## Adding CakeML source files
To add a CakeML source file to the build, just add it to the `APPEND_LIST` variable in the makefile. As described in the previous section, The list must be ordered according to their dependencies, so you can figure that out by hand, or you can use my python script.

It would also be nice if you put a comment at the top of your CakeML file describing its dependencies, and maybe add it to `buildscripts/deps.make` if people like that way of managing dependencies.
