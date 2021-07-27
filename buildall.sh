#!/bin/bash

# Pass in one arg to specify the install directory.
# Default = ../install/rv32i

if [ "$1" = "" ]; then
	INSTALL_DIR=$(cd ..; pwd)/install/rv32i
else
	INSTALL_DIR=$1
fi

echo "Installing into: $INSTALL_DIR"


# FYI - These should have already been run once before the first time this script is run:
# ./installdeps.sh
# ./config.sh

# configure and build gcc & friends
cd riscv-gnu-toolchain
./configure --prefix=$INSTALL_DIR/rv32i --with-arch=rv32i --with-multilib-generator="rv32i-ilp32--;rv32ima-ilp32--;rv32imafd-ilp32--"
#make


# configure and build qemu
cd ../qemu
./configure --target-list=riscv32-softmmu --prefix=$INSTALL_DIR
#make
#make install
