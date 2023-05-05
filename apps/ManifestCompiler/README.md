# Manifest Compiler

The goal of this target is to create a "Manifest Compiler"

The basic interface for a Manifest Compiler is that it will take as input:

1. An AM_Library
2. A Abstract/Formal Manifest

The outputs of this compilation process are:

1. An AM executable (target system is same as compilation system). This will have taken the relevant ASPs from the AM_Library and embedded them as native code within this AM
2. A Concrete Manifest (JSON). This will contain possible translations from Plc -> UUID, PubKey, etc. as well as containing other important configuration information. It is meant to be an easily configurable file to add more Plcs, and adjust configurations as needed

## Usage:

(All file locations are relative to the top-level of the repo)

First, make sure you have made the Manifest Compiler target.
This will be done via `make manifest_compiler` (within the build folder), which will output the
ManifestCompiler executable (currently called manComp_demo).
This file will be run from `./build/apps/ManifestCompiler/manComp_demo -m <manifest> -l <am_library>`.

This will create the actual AM executable (and it does not currently output a Concrete Manifest, due to the Concrete and Formal being so similar some re-work may be merited).
This executable will be dropped in `./build/build/COMPILED_AM` and can be run as `COMPILED_AM -m <concrete_manifest>.json`.

## NOTE:

Some current issues we are working on is how to tie the executable created from the Manifest Compiler, and the Concrete Manifest together. Otherwise, we foresee issues where one may forget exactly what **ASPs** are embedded in a specific AM executable.
