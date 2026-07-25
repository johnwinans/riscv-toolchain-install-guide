#!/bin/bash
# This script is only needed if building the toolchain from source.
# For a native Ubuntu 26.04 install, use installdeps.sh instead.
set -euo pipefail

# First arg: install directory. Default = /install/riscv
INSTALL_DIR="${1:-/install/riscv}"
# Second arg: path to the riscv-gnu-toolchain source tree. Default = ./riscv-gnu-toolchain
SRC_DIR="${2:-riscv-gnu-toolchain}"
echo "Source:      $SRC_DIR"
echo "Install dir: $INSTALL_DIR"

# FYI - For a native install these should have already been run:
# ./installdeps-src.sh
# ./setup.sh

# configure and build binutils, GCC, newlib, and QEMU for bare-metal RV32I
cd "${SRC_DIR}"
./configure --prefix="${INSTALL_DIR}" --with-arch=rv32i --with-abi=ilp32 --disable-llvm --disable-gdb --with-sim=qemu --enable-qemu-system
make -j $(nproc)
make build-qemu
make install
