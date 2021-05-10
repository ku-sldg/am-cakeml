#!/bin/bash

cc=$(which arm-linux-gnueabi-gcc)
cakec=/usr/local/bin/cake-x64-32/cake

cmake .. -DCMAKE_C_COMPILER=${cc} -DCAKE=${cakec}
