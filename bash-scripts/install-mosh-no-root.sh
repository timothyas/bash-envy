#!/bin/bash

## README 
#
# This will install mosh locally in the directory:
#	~/local
# 
# ESSENTIAL: Make sure to set the following in your bashrc:
#
# export PATH=$PATH:$HOME/local/bin
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/local/lib
#
# ---------------------------------------------------------- 

# Exit on error
set -e 

export setup_root=$HOME/mosh-setup
export build_dir=$setup_root/build
export install_dir=$setup_root/install

export local_dir=$HOME/local
export proto_dir="protobuf"
export mosh_dir="mosh"


if [[ ! -d ${setup_root} ]] ; then 
	mkdir ${setup_root}
	mkdir ${build_dir}
	mkdir ${install_dir}
fi

echo "==================================="
echo "about to build packages in ${build_dir}"
echo "entering ${build_dir}... "
echo "==================================="
echo "================="
echo "cloning protobuf"
echo "================="

cd ${build_dir}
git clone https://github.com/google/protobuf.git

echo "================="
echo "building protobuf"
echo "================="

cd ${build_dir}/${proto_dir}
export CFLAGS="$CFLAGS -fPIC"
export CXXFLAGS="$CXXFLAGS -fPIC"
./autogen.sh
./configure --prefix=${local_dir}
make
make check
make install

echo "============="
echo "cloning mosh"
echo "============="

cd ${build_dir}
git clone https://github.com/mobile-shell/mosh

echo "============="
echo "building mosh"
echo "============="

cd ${build_dir}/${mosh_dir}
export PROTOC=${local_dir}/bin/protoc
export protobuf_CFLAGS="-I${local_dir}/include"
export protobuf_LIBS="-lprotobuf"
export CFLAGS="$CFLAGS -fPIC"
export LDFLAGS="$LDFLAGS -L${local_dir}/lib"
./autogen.sh
./configure --prefix=${local_dir}
make 
make install

echo "==="
echo "if all was successful, binaries are now in ${local_dir}/bin"
echo "==="
