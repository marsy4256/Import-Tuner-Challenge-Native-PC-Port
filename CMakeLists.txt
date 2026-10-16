# itc_recomp - ReXGlue Recompiled Project
#
# SDK boilerplate lives in generated/rexglue.cmake.

cmake_minimum_required(VERSION 3.25)
project(itc_recomp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(generated/rexglue.cmake)

# Sources
set(ITCRECOMP_SOURCES
    src/main.cpp
)

if(WIN32)
    add_executable(itc_recomp WIN32 ${ITCRECOMP_SOURCES})
else()
    add_executable(itc_recomp ${ITCRECOMP_SOURCES})
endif()

rexglue_setup_target(itc_recomp)
