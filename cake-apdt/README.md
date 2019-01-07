# Building

## How to
[Download](https://cakeml.org/download.html) and build the 64-bit version of the CakeML compiler (It should include a makefile, just type `make cake`). The makefile for this project assumes the cake compiler and `basis_ffi.c` to be in the directory `~/cake-x64-64`. If you want to put it somewhere else, just change the `CAKE_DIR` variable in the makefile accordingly. Also, our build script requires python3 be installed.

To build this project, just type `make`.

## Why are you using the sml file extension for CakeML files

To make use of sml syntax highlighting.

## Why does the makefile append CakeML files together?

CakeML does not support any mechanism of combining source files. For the purpose of organization and modularity, we separate the source code regardless. In order to build our scattered CakeML, we therefore employ a python script which will append them all together in order to feed a single file to the CakeML compiler. This, however, necessitates that we append in an order which respects the dependencies of each file. Currently, I have adopted the convention of listing the dependencies at the top of each file within a comment, and then manually deriving an appension order. As the interpreter grows, a more automated solution may prove necessary.

## Adding CakeML source files

To add a CakeML source file to the build, just add it to the `APPEND_LIST` variable in the makefile. Note however that files are appended in the order of the list, so you must add the file such that each of its dependencies are above it. As I mentioned in the preceding section, I can try to automate this if and when this becomes difficult to manage by hand.
