# About
A Copland Attestation Manager (AM). See [here](https://ku-sldg.github.io/copland/) for more information about Copland.

This project makes use of formally verified components, including extracted CakeML code from the Coq theorem prover,  the CakeML compiler, and cryptographic implementations (i.e. EverCrypt). It aims for portability, targeting minimal environments such as seL4.

# Building

The following documents the process of manually building standalone executables for Linux and MacOS.

### Prerequisites
- CakeML v2076: [Download](https://github.com/CakeML/cakeml/releases/tag/v2076) the CakeML compiler (`cake-x64-64.tar.gz` is most likely the version you want, it targets 64-bit architectures). Unpack the tarball, run `make cake`, then put the `cake` executable on your system path. E.g.
```sh
tar -xzf cake-x64-64.tar.gz
cd cake-x64-64
make cake 
cp cake /usr/bin
```
- C compiler
- Make
- CMake: Version 3.10.2 or higher.
- CCMake: Optional, but highly recommended. Provides a GUI for configuring CMake parameters.

### Instructions
Create a build directory at the top level of the source tree, then invoke cmake from within the directory:

    mkdir build && cd build
    cmake ..

If you need to make changes to the default configuration, type `ccmake ..` to bring up the graphical interface. (See the "Configuration" section for more details.)

To build another target, type `make <target>`. Refer to the `apps` directory for the full list of targets.

The resulting binaries are found in the relevant subdirectory of `build/apps`.

### Testing 
To test this repository, refers to `./tests` folder and its corresponding README.

### Configuration
From the build directory, type `ccmake ..` to bring up the configuration GUI. Hovering over a variable displays some documentation at the bottom of the screen. After you make changes, press `c` then `g` to save your changes.

This manual configuration should not be necessary for most builds. It may be necessary if you want to use a C compiler other than your default compiler, change the compile flags, cross-compile, etc.

To add custom arguments to the C compiler (without requiring manual changes via ccmake) export the `CMAKE_C_ARGS` environment variable to a string with all arguments.  For example, to point to dynamic openssl libraries:  
>`export CMAKE_C_ARGS="-I/usr/local/opt/openssl@1.1/include -L/usr/local/opt/openssl@1.1/lib"`.

# Source File Layout

## Top-level files/scripts

`CMakeLists.txt`:  This file is the main "dependency configuration" file for the CMake build workflow.  Adding new source files will likely require changes to this file to allow re-compilation.

`print_cakeml_types.sh`:  Script that prints out the types of functions provided by the CakeML standard library.

`do_extract.sh`:  Once customized, this script supports copying extracted CakeML source files (.cml extension) from their initially-extracted location to their end location in this project.  To customize, replace the contents of the `COPLAND_AVM_DIR` variable with the full path to the directory containing the extracted .cml files.  If using the [Copland AVM repo](https://github.com/ku-sldg/copland-avm) for extraction, this path would be something like:  `.../copland-avm/src`.

## Top-level directories

`/apps`:  This directory contains a collection of applications used to generate executables for specific attestation scenarios and also for testing.
* AttestationManager: This is the main executable to launch a server style attestation manager
* ManifestGenerator: This executable takes in a list of terms and evidence that certain places must be able to service, and generates corresponding Manifest to configure their AMs
* TermToJson: This executable allows printing out certain key extracted flexible mechanisms into their JSON form. This is mostly just a convenience

`/build`:  A working directory for building application executables.  This folder must be created before first use (See top-level README instructions).

`/extracted`:  Directory that holds extracted source files.  These files should NOT be modified by hand.  Our current extraction pipeline uses the formal Coq specification [here](https://github.com/ku-sldg/copland-avm) in addition to a custom Coq plugin for CakeML extraction [here](https://github.com/ku-sldg/coq)
in the `cakeml-extraction` branch.

`/stubs`:  This directory holds a collection of source files that define datatypes and functions that instantiate code left empty in extracted code.  These "stubbed out" items are deemed inappropriate (or infeasible) for direct formalization at present due to their external IO requirements or low-level nature.
* Appraisal_IO_Stubs.sml:  Fills in external IO stubs left abstract in the Copland generalized appraisal procedure.
* Axioms_IO.sml: A collection of stubs regarding the running of parallel branches in a Copland phrase and the CVM Core.
* BS.sml:  Instantiates a concrete representation of binary data (and some default values).
* IO_Stubs.sml:  Fills in external IO stubs left abstract in the definition of the Copland Virtual Machine (CVM).
* JSON_Admits.sml: Fills in the stubs for conversion between Coq JSON structures and CakeML JSON structures
* Manifest_Admits.sml: Fills in stubs for the different datatypes in Manifests that must be instantiated in CakeML
* Param_Admits.sml: Fills in the stubs for the hardcoded values for the primitive Copland ASPs (SIG, HSH, etc.)
* Preamble_Stuff.sml: Fills in stubs for information we use through the development
* Serializable_Class_Admits.sml: Fills in the stubs to allow for natural numbers to be serializable


`/system`:  A collection of system-level utilities. Of note is the `/posix` sub-directory which holds stubs and wrappers for various posix operation implementations.


`/util`:  Source files with miscellaneous utility functions used throughout this codebase.  Examples include parsing (Parser.sml), Json (Json.sml), and binary data representation (ByteString.sml).


# Steps to integrate and execute a new ASP

With the release of the MAESTRO JSON Interface, ASPs are now invoked via the file system and expected to communicate through a precise JSON interface.
Given that, review the documentation on the interface [here](https://github.com/ku-sldg/copland-avm/wiki/Attestation-Manager-Interfaces) and also check out [this repo](https://github.com/ku-sldg/asp-libs), where we keep our example ASPs.

### Steps to integrate a new ASP
1. Define your ASP and make sure it conforms to the MAESTRO JSON Interface
1. Compile that ASP and remember its location as `ASP_BIN`
1. Launch an Attestation Manager and provide the `ASP_BIN` as an argument (`-b ASP_BIN`)
1. Ensure that the Manifest of the Attestation Manager mentions your ASP such that the exact name of your ASP is the ASP_ID utilized in the Manifest.

# Misc.

### Why are you using the sml file extension for CakeML files?
To make use of sml syntax highlighting. CakeML does stray from SML syntax slightly, but it is better than nothing 😃.

# Contact
Primary maintainers:  [Adam Petz](https://ampetz.github.io/) (ampetz@ku.edu) and [Will Thomas](https://github.com/Durbatuluk1701).

Contributors:  TJ Barclay, Andrew Cousino, Anna Fritz, Ed Komp, [Grant Jurgensen](https://grant.jurgensen.dev/), [Garrett Mills](https://garrettmills.dev/), Michael Nieses, Sarah Scott, [Perry Alexander](https://perry.alexander.name/)

# Notes
This branch has been archived at `backup-am-cakeml`
