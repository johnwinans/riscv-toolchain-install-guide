#!/bin/bash
# Install build prerequisites for compiling the RISC-V toolchain from source.
# Works as a normal user (uses sudo) or as root (e.g. inside Docker).
# For a faster package-based install on Ubuntu 26.04, use installdeps.sh instead.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    APT="apt-get"
else
    APT="sudo apt-get"
fi

${APT} update
${APT} install -y \
    autoconf \
    automake \
    autotools-dev \
    bc \
    bison \
    build-essential \
    cmake \
    curl \
    flex \
    gawk \
    gdb-multiarch \
    gperf \
    libexpat-dev \
    libfdt-dev \
    libglib2.0-dev \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libpixman-1-dev \
    libtool \
    make \
    ninja-build \
    patchutils \
    python3 \
    python3-pip \
    texinfo \
    zlib1g-dev
${APT} clean
rm -rf /var/lib/apt/lists/*
