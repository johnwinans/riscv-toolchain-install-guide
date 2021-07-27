#!/bin/bash

git submodule init
git submodule update

# To manually select specific versions of qemu and/or riscv-gnu-toolchain, do something like this:
#
#cd riscv-gnu-toolchain
#git checkout 2021.06.26
#
#cd ../qemu
#git checkout v5.2.0
