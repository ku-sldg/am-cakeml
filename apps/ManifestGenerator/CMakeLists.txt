cmake_minimum_required(VERSION 3.10.2)

get_files(manGen_src ${server_am_src} ManifestGenerator.sml)
build_posix_am("manifest_generator" ${manGen_src})
