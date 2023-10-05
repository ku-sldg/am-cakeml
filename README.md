# About
A Copland Attestation Manager (AM). See [here](https://ku-sldg.github.io/copland/) for more information about Copland.

This project makes use of formally verified components, including the CakeML compiler, and the EverCrypt crypto implementations. It aims for portability, targeting minimal environments such as seL4.

# Building

## Automated Build (Docker)

See README instructions at the following repository for a (Docker-based) automated build: [am-docker](https://github.com/ku-sldg/am-docker).

## Manual Build

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
- OpenSSL development files/headers

### Instructions
Create a build directory at the top level of the source tree, then invoke cmake from within the directory:

    mkdir build && cd build
    cmake ..

If you need to make changes to the default configuration, type `ccmake ..` to bring up the graphical interface. (See the "Configuration" section for more details.)

To build the test suite, type `make tests`.

To build another target, type `make <target>`. Refer to the `apps` directory for the full list of targets.

The resulting binaries are found in the relevant subdirectory of `build/apps`.

### Testing a Successful Install
To test a  successful install, navigate to `apps/tests/` and run `../../build/apps/tests/tests`. Running this test suite anywhere besides `apps/tests/` will result in error messages complaining about missing input files.  On success, you should see a series of outputs including hash hex strings and test results.  All results should indicate "Passed", with one notable exception: The "Bad Signature" test should report: "Signature Check: Failed" to correctly identify a bad signature.

### Configuration
From the build directory, type `ccmake ..` to bring up the configuration GUI. Hovering over a variable displays some documentation at the bottom of the screen. After you make changes, press `c` then `g` to save your changes.

This manual configuration should not be necessary for most builds. It may be necessary if you want to use a C compiler other than your default compiler, change the compile flags, cross-compile, etc.

To add custom arguments to the C compiler (without requiring manual changes via ccmake) export the `CMAKE_C_ARGS` environment variable to a string with all arguments.  For example, to point to dynamic openssl libraries:  
>`export CMAKE_C_ARGS="-I/usr/local/opt/openssl@1.1/include -L/usr/local/opt/openssl@1.1/lib"`.

# Source File Layout

## Top-level files/scripts

`CMakeLists.txt`:  This file is the main "dependency configuration" file for the CMake build workflow.  Adding new source files will likely require changes to this file to allow re-compilation.

`print_cakeml_types.sh`:  Script that prints out the types of functions provided by the CakeML standard library.

`do_extract.sh`:  Once customized, this script supports copying extracted CakeML source files (.cml extension) from their initially-extracted location to their end location in this project.  To customize, replace the contents of the `COQ_DIR` variable with the full path to the directory containing the extracted .cml files.  If using the [Copland AVM repo](https://github.com/ku-sldg/copland-avm) for extraction, this path would be something like:  `.../copland-avm/src`.

## Top-level directories

`/am`:  This directory contains source files related to Attestation Manager (AM) capabilities and utilities.
* ServerAM.sml:  Helper functions for configuring AMs and performing AM-to-AM communication.
* CommTypes.sml:  Datatypes and utility functions for dealing with AM communication and encoding/decoding of AM structures.
* CoplandCommUtil.sml:  Utility functions to facilitate AM communication, including interpreting Copland remote requests.

`/apps`:  This directory contains a collection of applications used to generate executables for specific attestation scenarios and also for testing.
* blockchain/:  blockchain-related testing
* repl/:  a REPL for prototyping parsing of Copland concrete syntax.  (NOTE:  this code is likely deprecated at the moment due to slight changes in the Copland representation).
* demo/:  A client-server demo scenario, with executables for each in their respecrive subdirectories.  See the README in demo/ for more details around configuration and running of this scenario.
* serverClient/:  An older client-server scenario used primarily for testing.
* template/:  A template used as a basis for creating new apps.
* tests/:  Test executables for testing various parts of the system, with different library dependencies.

`/build`:  A working directory for building application executables.  This folder must be created before first use (See top-level README instructions).
`/copland`:  Contains source files with utilities and various wrappers around Copland datatypes and functionality.
* CoplandUtil.sml:  Mostly ToString methods for common Copland datatypes.
* CvmUtil.sml:  ToString and other utilities related to the internal CVM state structure.
* Parser.sml:  Parser utilities for everything from string-based numerals to Copland concrete syntax (commented out at present--needs updating).
* /json:  Sub-directory containing source files for converting Copland datatypes to (CoplandToJson.sml) and from (JsonToCopland.sml) their JSON representations.

`/extracted`:  Directory that holds extracted source files.  These files should NOT be modified by hand.  Our current extraction pipeline uses the formal Coq specification [here](https://github.com/ku-sldg/copland-avm) in addition to a custom Coq plugin for CakeML extraction [here](https://github.com/ku-sldg/cakeml-synthesis).  

`/stubs`:  This directory holds a collection of source files that define datatypes and functions that instantiate code left empty in extracted code.  These "stubbed out" items are deemed inappropriate (or infeasible) for direct formalization at present due to their external IO requirements or low-level nature.
* IO_Stubs.sml:  Fills in external IO stubs left abstract in the definition of the Copland Virtual Machine (CVM).
* Appraisal_IO_Stubs.sml:  Fills in external IO stubs left abstract in the Copland generalized appraisal procedure.
* BS.sml:  Instantiates a concrete representation of binary data (and some default values).
* Compare_Stub.sml:  Instantiates equality stubs for string and number comparison.
* Example_Phrases_Demo_Admits.sml:  Demo-specific instantiations of parameters for custom Copland terms.
* Params_Admits_hardcoded.sml:  Similar to Example_Phrases_Demo_Admits.sml.
* IO_Stubs_extra.sml:  Some hard-coded configuration parameters necessary for CVM execution (This file will hopefully go away once the CVM is more "externally-configurable").
* appraise_\<asp name\>_ASP.sml:  Custom appraisal procedures, where \<asp name\> is the name of the ASP being appraised. 
* \<asp name\>_ASP_Stub.sml:  Custom ASP stub implementations, where \<asp name\> is the ID of the ASP being defined.


`/system`:  A collection of system-level utilities.  Of note is the `/crypto` sub-directory which holds stubs and wrappers for various cryptographic implementations.


`/util`:  Source files with miscellaneous utility functions used throughout this codebase.  Examples include parsing (Parser.sml), Json (Json.sml), and binary data representation (ByteString.sml).


# Steps to integrate and execute a new ASP

1. Define and extract a new Copland phrase that involves the new ASP
    * Good examples can be found in src/Example_Phrases.v and src/Example_Phrases_Demo.v of [copland-avm](https://github.com/ku-sldg/copland-avm).
    * First:  Define (Admitted) ASP params.  See `ssl_sig_*` in src/Example_Phrases_Demo_Admits.v.
    * Next:  Use those params to define a full Copland phrase that includes the ASP.  See `ssl_sig_parameterized` in src/Example_Phrases_Demo.v.
    * Finally:  Add that phrase to the list of extracted items in src/Extraction_Cvm_Cake.v, then type `make` in the src/ directory of the copland-avm repo to compile the Coq source and extract the newly defined phrase.
1. Bring newly extracted code over to am-cakeml (run the top-level ./do_extract script).  You should see changes to the corresponding .cml files in /extracted where you defined the phrase.
1. Fill in stubs for Admitted extracted parameters.  If you extracted to Example_Phrases_Demo_Admits.cml, these stubs should go in /stubs/Example_Phrases_Demo_Admits.sml.  You should be able to just copy similar definitions and rename them (i.e. the ssl_sig_* params).
1. Define a new ASP stub (in /stubs/attestation_asps) with the desired functionality.  Again, copying an existing stub to get started is usually best (i.e. `cp /stubs/ssl_sig_ASP_Stub.sml /stubs/<new_ASP_Stub>.sml`).  NOTE:  cakeml function names should be unique, so re-name the ASP stub.
1.  Add this new source file dependency to the CMakeLists.txt (in /stubs/attestation_asps/CMakeLists.txt).  NOTE:  at this point, check that the project is compiling (i.e. `make manCompDemo`).  Modify something in your new ASP stub code to produce a type error, and check that the compiler catches it.
1.  This phrase is now available to use in any code beyond where the extracted source file is defined in the CMakeLists dependencies.
1. TODO:  Describe linking stubs in AM Library
1. TODO:  Describe setting up phrase to execute in new (or existing) Copland app

# Misc.

### Why are you using the sml file extension for CakeML files?
To make use of sml syntax highlighting. CakeML does stray from SML syntax slightly, but it is better than nothing 😃.

# Contact
Primary maintainer:  [Adam Petz](https://ampetz.github.io/) (ampetz@ku.edu)

Contributors:  TJ Barclay, Andrew Cousino, Anna Fritz, Ed Komp, [Grant Jurgensen](https://grant.jurgensen.dev/), [Garrett Mills](https://garrettmills.dev/), Michael Nieses, Sarah Scott, [Perry Alexander](https://perry.alexander.name/)

# Notes
This branch has been archived at `backup-am-cakeml`
