#!/bin/bash
# Install the RISC-V toolchain from Ubuntu packages.
# Works as a normal user (uses sudo) or as root (e.g. inside Docker).
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    APT="apt-get"
else
    APT="sudo apt-get"
fi

${APT} update
${APT} install -y \
    binutils-riscv64-unknown-elf \
    gcc-riscv64-unknown-elf \
    picolibc-riscv64-unknown-elf \
    qemu-system-riscv \
    gdb-multiarch \
    git \
    make
${APT} clean
rm -rf /var/lib/apt/lists/*
