project(main)
cmake_minimum_required(VERSION 3.22)
find_package(LLVM REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})

set(CMAKE_C_COMPILER "clang")
set(CMAKE_CXX_COMPILER "clang++")
find_package(MPI REQUIRED)

file(GLOB SOURCES *.cpp)

add_library(ReplaceMPIReduce MODULE ReplaceMPIReduce.cpp)
add_executable(main main.cpp)

target_link_libraries(main ${llvm_libs} MPI::MPI_CXX)