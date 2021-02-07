cmake_minimum_required(VERSION 3.16)
project(signal_gait)

set(CMAKE_CXX_STANDARD 14)

include_directories("lib/include")
include_directories("src")
include_directories("lib/bindings")
include_directories("lib")
link_directories("lib")

add_executable(signal_gait main.cpp src/position_control.cpp src/position_control.h lib/b0RemoteApi.cpp lib/b0RemoteApi.h)

target_link_libraries(signal_gait b0)