cmake_minimum_required(VERSION 3.10.2)

get_files(manGen_src ${server_am_src} ManifestGenerator.sml)
build_posix_am("manGen_demo" ${manGen_src})

add_custom_target(manifest_generator DEPENDS manGen_demo)
