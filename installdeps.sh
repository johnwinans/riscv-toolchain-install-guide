#!/bin/bash

# This was tested on Ubuntu 20.04


# for the GNU toolchain
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

# This is used by GDB so can run a dashboard script
sudo apt-get install python-dev



# The following may not be necessary on 20.04.  But my tests included it.
sudo apt install ninja-build libglib2.0-dev libpixman-1-dev


# This is a useful tool for viewing the configuration of the QEMU-emulated machines
sudo apt install device-tree-compiler

