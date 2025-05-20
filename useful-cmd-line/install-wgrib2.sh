#!/bin/bash

# Run this in a directory like 
# $HOME/pkgs-for-grib
# to keep everything contained...

# After running this:
# export PATH=$PATH:$HOME/pkgs-for-grib/wgrib2-3.7.0/build/install/bin
# to be able to use wgrib2

ipolates_install=$HOME/pkgs-for-grib/NCEPLIBS-ip/install

git clone https://github.com/NOAA-EMC/NCEPLIBS-ip
mkdir -p $ipolates_install
cmake -DCMAKE_INSTALL_PREFIX=$ipolates_install -DBUILD_SHARED_LIBS=ON -S NCEPLIBS-ip -B NCEPLIBS-ip/build
cmake --build NCEPLIBS-ip/build --parallel 4
ctest --test-dir NCEPLIBS-ip/build --parallel 4
cmake --install NCEPLIBS-ip/build

wget https://github.com/NOAA-EMC/wgrib2/archive/refs/tags/v3.7.0.tar.gz
tar -zxvf v3.7.0.tar.gz
cd wgrib2-3.7.0
[ -d "./build" ] && rm -rf ./build
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=install -DCMAKE_PREFIX_PATH=$ipolates_install -DUSE_IPOLATES=ON
LD_LIBRARY_PATH=$LD_LIBRARY_PATH/$ipolates_install/lib64 make -j 4
make install -j 4
