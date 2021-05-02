#!/bin/bash

cc=$(which arm-linux-gnueabi-gcc)
cakec=/usr/local/bin/cake-x64-32/cake
basis=/usr/local/bin/cake-x64-32/basis_ffi.c

cmake .. -DCMAKE_C_COMPILER=${cc} -DCAKE=${cakec} -DSTATIC_LINKING=ON -DBASIS_FILE=${basis} -DTARGET_ARCH=armv8
