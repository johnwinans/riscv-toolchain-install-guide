#!/bin/bash

git submodule init
git submodule update

cd riscv-gnu-toolchain
git checkout 2021.06.26

cd ../qemu
git checkout v5.2.0
