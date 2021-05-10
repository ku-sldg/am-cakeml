cmake_minimum_required(VERSION 3.10.2)
# cmake_policy(SET CMP0076 NEW)
include(ExternalProject)
set(CMAKE_USER_MAKE_RULES_OVERRIDE "DefaultConfig.cmake")
project(CakemlAM C ASM)

include(CakeMLHelper.cmake)

set(util_src util/ByteString.sml util/CoqDefaults.sml util/Json.sml)
set(cop_src ${util_src} copland/Instr.sml copland/AM.sml copland/VM.sml
    copland/json/CoplandToJson.sml copland/json/JsonToCopland.sml)
set(socket_src system/sockets/SocketFFI.sml)
set(server_am_src ${cop_src} ${crypto_src} system/crypto/MeasFFI.sml am/Measurements.sml ${socket_src}
    am/CommTypes.sml am/ServerAm.sml)
set(standalone_am_src ${cop_src} am/CommTypes.sml)

set(case2_client_src ${server_am_src} apps/case2/Client.sml)
set(heli_src ${standalone_am_src} apps/case2/HamrFFI.sml apps/case2/Heli.sml)

mark_as_advanced(FORCE CMAKE_INSTALL_PREFIX)
mark_as_advanced(CLEAR
    CMAKE_C_COMPILER CMAKE_ASM_COMPILER CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG
    CMAKE_C_FLAGS_RELEASE CMAKE_EXE_LINKER_FLAGS CMAKE_VERBOSE_MAKEFILE
)

add_link_options(-nodefaultlibs -nostartfiles)
build_cake("heli_am" ENTRY_NAME "run" SOURCES "${heli_src}")