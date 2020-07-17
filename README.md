# About
A Copland Attestation Manager (AM). See [here](https://ku-sldg.github.io/copland/) for more information about Copland.

This project makes use of formally verified components, including the CakeML compiler, and the EverCrypt crypto implementations. It aims for portability, targeting minimal environments such as seL4.

# Building

The following documents the process of building standalone executables for Linux and MacOS.

### Prerequisites
- CakeML: [Download](https://cakeml.org/download.html) and build the 64-bit version (or the 32-bit version if you are building for the Odroid). This project assumes the `cake` executable and `basis_ffi.c` to be in the directory `~/cake-x64-64`. See the "Configuration" section if you want to put it elsewhere.
- CMake: Version 3.10.2 or higher.
- CCMake: Optional, but highly recommended. Provides a GUI for configuring CMake parameters. Download through your package manager (the Ubuntu package is `cmake-curses-gui`).

### Instructions
Create a build directory at the top level of the source tree, then invoke cmake from within the directory:

    mkdir build && cd build
    cmake ..

If you need to make changes to the default configuration, type `ccmake ..` to bring up the graphical interface. (See the following section for more details.)

Finally, type `make <target>`, where `<target>` is `server`, `client`, `tests`, etc. Refer to the `apps` directory for the full list of targets.

### Configuration
From the build directory, type `ccmake ..` to bring up the configuration GUI. Hovering over a variable displays some documentation at the bottom of the screen. After you make changes, press `c` then `g` to save your changes.

This manual configuration should not be necessary for most builds. It may be necessary if you want to use a C compiler other than your default compiler, if your cake files are in an unexpected location, if you want to cross-compile, etc.

# Misc.

### Why are you using the sml file extension for CakeML files?
To make use of sml syntax highlighting. CakeML does stray from SML syntax slightly, but it is better than nothing 😃.
