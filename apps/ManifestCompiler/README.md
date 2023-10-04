# Manifest Compiler

The goal of this target is to create a "Manifest Compiler"

The basic interface for a Manifest Compiler is that it will take as input:

1. An AM_Library
2. A Abstract/Formal Manifest

The outputs of this compilation process are:

1. An AM Config structure.  This contains all of the callback functions used as stubs during attestation and appraisal.  For the moment, this is embedded directly into the AM executable.
2. An AM executable (target system is same as compilation system). This will have taken the relevant ASPs from the AM_Library and embedded them as native code within this AM (via the AM Config).

## Usage:

**Important**:
The Manifest Compiler expects the cakeml vairable for the AM_Library to be named `am_library`. This would be a good place to make configurable in the future, but not yet.

(All file locations are relative to the top-level of the repo)

First, make sure you have made the Manifest Compiler target.
This will be done via `make manifest_compiler` (within the build folder), which will output the
ManifestCompiler executable (currently called manComp_demo).
This file will be run from `./build/apps/ManifestCompiler/manComp_demo -m <manifest_file>.json -l <am_library_file>.sml [-s | -c <cvm_term_file>.sml] -o <executable_output_path>`.
The options `-c` will set it to compile as a client, and `-s` will make it compile as a server.  The client option takes a filename as a parameter that contains a copland phrase (as a cakeml variable named `clientCvmTerm`--in the future this should be more principled...likely a JSON input).  `-o` supports naming the output AM executable file.

This will create the AM executable in `./build/build/COMPILED_AM` and can be run as `COMPILED_AM -m <manifest_file>.json`.
