# Building

The following documents the process of building standalone executables. The build process for CAmkES components will be documented elsewhere.

## Prerequisites
- CakeML: [Download](https://cakeml.org/download.html) and build the 64-bit version (or the 32-bit version if you are building for the Odroid). This project assumes the `cake` executable and `basis_ffi.c` to be in the directory `~/cake-x64-64`. See the "Configuration" section if you want to put it elsewhere.
- CMake: This should be available through your package manager.
- CCMake: Optional, but highly recommended. Provides a GUI for configuring CMake parameters. Download through your package manager (the Ubuntu package is `cmake-curses-gui`).

## Instructions
Create a build directory at the top level of the source tree, then invoke cmake from within the directory:

    mkdir build && cd build
    cmake ..

If you need to make changes to the default configuration, type `ccmake ..` to bring up the graphical interface. (See the following section for more details.)

Finally, type `make <target>`, where `<target>` is one of the following:
- `tests`: a test suite
- `server`: an attestation manager server
- `client`: an example client
- `am`: builds `server` and `client`

## Configuration
From the build directory, type `ccmake ..` to bring up the configuration GUI. Hovering over a variable displays some documentation at the bottom of the screen. After you make changes, press `c` then `g` to save your changes.

Some common use cases include changing the `CAKE` filepath (e.g. to `~/cake-x64-32/cake` for the 32-bit CakeML compiler), `CMAKE_C_COMPILER` (e.g. to compcert, a cross-compiler, etc.), or the `PRIV_KEY` values.

## Platforms
Currently, this project should run under Linux and macOS. We plan to eventually support a version which runs under a seL4 CAmkES component.

# Misc.

## Why are you using the sml file extension for CakeML files?
To make use of sml syntax highlighting. CakeML does stray from SML syntax slightly, but it is better than nothing 😃.

## Why does CMake append CakeML files together?
CakeML does not support any mechanism of combining source files. For the purpose of organization and modularity, we separate the source code regardless. In order to build our scattered CakeML, we combine them with `cat` in order to feed a single file to the CakeML compiler. This, however, necessitates that we append in an order which respects the dependencies of each file.

I have adopted the convention of listing the dependencies at the top of each file within a comment, from which you may manually derive an appension order. Alternatively, I wrote a quick python script that can derive such an ordering automatically. File dependencies are described in an external file, using syntax inspired by makefiles (checkout `buildscripts/deps.make`). You can print the ordering to the terminal by running `./topOrd.py deps.make` from the `buildscripts` directory.

The python script is probably pretty fragile (I don't write python often, and I coded this up pretty quickly), but I figured it would be nice to have an alternative to managing dependencies manually, especially as the project scales. Let me know if it is unintuitive or if something breaks.
