#!/bin/bash

cc=$(which arm-linux-gnueabi-gcc)

cmake .. -DCMAKE_C_COMPILER=${cc} -DSTATIC_LINKING=ON -DTARGET_ARCH=armv8
