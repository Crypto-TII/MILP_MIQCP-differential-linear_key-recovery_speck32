cmake_minimum_required(VERSION 3.21)
project(speck_32_64_dl)

set(CMAKE_CXX_STANDARD 14)
find_package(OpenMP)

add_executable(speck_32_64_dl src/main.cpp src/speck32.hpp src/random.hpp src/utils.hpp)

if (OpenMP_CXX_FOUND)
    target_link_libraries(speck_32_64_dl PUBLIC OpenMP::OpenMP_CXX)
endif()
