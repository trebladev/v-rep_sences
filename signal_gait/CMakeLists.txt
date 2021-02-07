cmake_minimum_required(VERSION 3.16)
project(signal_gait)

set(CMAKE_CXX_STANDARD 14)



include_directories("include")
include_directories("remoteApi")
INCLUDE_DIRECTORIES("include/stack")
include_directories("src")

aux_source_directory(include D1)
aux_source_directory(remoteApi D2)
aux_source_directory(include/stack D3)

add_definitions(-DNON_MATLAB_PARSING)
add_definitions(-DMAX_EXT_API_CONNECTIONS=255)
add_definitions(-DDO_NOT_USE_SHARED_MEMORY)
add_definitions(-D_CONSOLE)
add_definitions(-DNDEBUG)

find_package(Threads)
add_executable(signal_gait main.cpp remoteApi/extApi.c remoteApi/extApiPlatform.c src/position_control.cpp src/position_control.h)

target_link_libraries(signal_gait ${CMAKE_THREAD_LIBS_INIT})