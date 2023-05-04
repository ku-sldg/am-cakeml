# Manifest Compiler

The goal of this target is to create a "Manifest Compiler"

The basic interface for a Manifest Compiler is that it will take as input:

1. An AM_Library
2. A Abstract/Formal Manifest

The outputs of this compilation process are:

1. An AM executable (target system is same as compilation system). This will have taken the relevant ASPs from the AM_Library and embedded them as native code within this AM
2. A Concrete Manifest (JSON). This will contain possible translations from Plc -> UUID, PubKey, etc. as well as containing other important configuration information. It is meant to be an easily configurable file to add more Plcs, and adjust configurations as needed

## NOTE:

Some current issues we are working on is how to tie the executable created from the Manifest Compiler, and the Concrete Manifest together. Otherwise, we foresee issues where one may forget exactly what **ASPs** are embedded in a specific AM executable.
