This README helps to reproduce the verification of the correlations for differential-linear distinguisher 3, 4, 5, and 6

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

    ./speck_32_64_dl < ../distinguishers/diff_lin_3.txt
