#!/bin/bash
# This script is only needed if building the toolchain from source.
# For a native Ubuntu 26.04 install, use installdeps.sh instead.
set -euo pipefail

git submodule sync --recursive

# Init top-level submodules
git submodule update --init

# Init only the riscv-gnu-toolchain submodules needed for a
# bare-metal newlib RV32I toolchain + QEMU. Omitting musl, glibc,
# uclibc-ng, llvm, spike, and pk keeps the checkout small and
# prevents the build system from attempting to build them.
git -C riscv-gnu-toolchain submodule update --init binutils gcc newlib qemu
