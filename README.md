Dependencies
------------

    - CMake version 3.21 or higher
    - C++ compiler that supports C++14
    - OpenMP


Installation
------------

    mkdir build
    cd build/
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make

This will produce the binary `speck_32_64_dl`


Usage Example
-------------

From the directory `build/` run the following

    ./speck_32_64_dl < ../distinguishers/3.txt
