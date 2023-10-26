# This is the top-level CMakeLists.txt for the am-cakeml project.
# This file:
# 1. Gathers the requisite source files
# 2. Adds third party projects
# 3. Handles selection of apps to buile

cmake_minimum_required(VERSION 3.10.2)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")

set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "Used for MacOS to configure the architecture")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/GetFiles.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/HandleOS.cmake)

add_subdirectory(system/crypto/evercrypt)
add_subdirectory(system/crypto/openssl)
add_subdirectory(system/crypto/tpm)

include(${CMAKE_CURRENT_LIST_DIR}/BuildAMFunctions.cmake)

# Define a cache variable for the app selection, but only if it's not already set
# If no variable is set, then build everything.
if(NOT DEFINED CACHE{APP_TO_BUILD})
    set(APP_TO_BUILD "all" CACHE STRING "Specify the app to build (demo,
    ManifestCompiler, ManifestGenerator, seL4_server, seL4_client, ... or all)")
endif()

message(STATUS "Building am-cakeml app: ${APP_TO_BUILD}")

# Function to add an app subdirectory based on the selected app
# Select an app by setting APP_TO_BUILD
function(add_app_subdirectory app_name subdir)
    if(APP_TO_BUILD STREQUAL "all" OR APP_TO_BUILD STREQUAL app_name)
        add_subdirectory(${subdir})
        message(STATUS "Adding subdirectory: ${app_name}")
    else()
        message(STATUS "Skipping ${app_name}")
    endif()
endfunction()

# Conditionally add these apps 
add_app_subdirectory(demo "${CMAKE_CURRENT_LIST_DIR}/apps/demo")
add_app_subdirectory(compiler "${CMAKE_CURRENT_LIST_DIR}/apps/ManifestCompiler")
add_app_subdirectory(generator "${CMAKE_CURRENT_LIST_DIR}/apps/ManifestGenerator")

# Compile the AM if and only if its particular CMakeLists.txt has been generated.
get_real_file("${CMAKE_CURRENT_LIST_DIR}/build/CMakeLists.txt" temp)
if (EXISTS ${temp})
    add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/build")
endif()

