cmake_minimum_required(VERSION 3.10.2)

get_files(heli_src ${cop_src} HamrStandard.sml GoldenHashes.sml Heli.sml)
get_files(heli_c_src fake_crypto_ffi.c)

build_cake("heli_am" ENTRY_NAME "run" SOURCES "${heli_src}" C_SOURCES "${heli_c_src}")