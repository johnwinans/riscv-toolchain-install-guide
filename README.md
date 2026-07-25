# RISC-V Toolchain Install Guide

How to install QEMU and the GNU toolchain on Ubuntu 26.04 for building and running
freestanding RISC-V assembler and C/C++ programs.

## More sample code

A repo with stand-alone tutorial applications covering interrupt handlers, virtual memory,
and more: [rv32-tutorials](https://github.com/johnwinans/rv32-tutorials)

## YouTube videos discussing the use of QEMU and these test programs

- [Installation and Setup](https://youtu.be/iWQRV-KJ7tQ)

A playlist of RISC-V videos: [RISC-V Lectures](https://www.youtube.com/playlist?list=PL3by7evD3F53Dz2RiB47Ztp9l_piGVuus)


## Clone this repo

```bash
git clone https://github.com/johnwinans/riscv-toolchain-install-guide.git
```

## Toolchain Setup

Four setup options are supported:

| | Native (Ubuntu 26.04) | Docker | Docker + dev tools |
|---|---|---|---|
| **Packages** (recommended, fast) | [Option 1](#option-1-native--packages) | [Option 3](#option-3-docker--packages) | [Dev container](#dev-container) |
| **Build from source** (slow, flexible) | [Option 2](#option-2-native--build-from-source) | [Option 4](#option-4-docker--build-from-source) | [Dev container](#dev-container) |

---

### Option 1: Native + Packages

```bash
./installdeps.sh
```

Installs the following packages from the Ubuntu archive:

| Package | Purpose |
|---|---|
| `binutils-riscv64-unknown-elf` | Assembler and linker |
| `gcc-riscv64-unknown-elf` | C cross-compiler |
| `picolibc-riscv64-unknown-elf` | Bare-metal C library |
| `qemu-system-riscv` | QEMU (includes `qemu-system-riscv32`) |
| `gdb-multiarch` | GDB with RISC-V support |
| `git` | For gdb-dashboard submodule |
| `make` | Build system |

> **Note:** The tools are prefixed `riscv64-unknown-elf-*` but fully support RV32I
> targets when passed `-march=rv32i_zicsr -mabi=ilp32`.

---

### Option 2: Native + Build from Source

> **Note:** Building from source takes a significant amount of time. Use
> [Option 1](#option-1-native--packages) if you are on Ubuntu 26.04.

Install build prerequisites (also installs `gdb-multiarch` and `make`):

```bash
./installdeps-src.sh
```

Initialise submodules and build:

```bash
./setup.sh
./buildall.sh /opt/riscv
```

Add the toolchain to your PATH:

```bash
export PATH=/opt/riscv/bin:$PATH
```

> **Tip:** To persist across shells, add the export to `~/.bashrc` or `~/.zshrc`.

---

### Option 3: Docker + Packages

```bash
docker build -t riscv .
docker run --rm -it -v $(pwd)/test-freestanding:/work -w /work riscv /bin/bash
```

---

### Option 4: Docker + Build from Source

> **Note:** Building from source takes a significant amount of time and requires
> network access to github.com during the build.

```bash
docker build -f Dockerfile.src -t riscv-src .
docker run --rm -it -v $(pwd)/test-freestanding:/work -w /work riscv-src /bin/bash
```

---

### Dev Container

`Dockerfile.dev` adds a non-root user and developer tools (vim, nano, tmux,
ripgrep, fd-find, jq, bash-completion, cmake, man pages, and more) on top of
either toolchain image. The result is suitable for use as a VS Code dev
container or a general-purpose development shell.

Build on top of the packages image:

```bash
docker build -t riscv .
docker build -f Dockerfile.dev -t riscv-dev .
docker run --rm -it -v $(pwd):/workspace -w /workspace riscv-dev bash
```

Or on top of the from-source image:

```bash
docker build -f Dockerfile.src -t riscv-src .
docker build -f Dockerfile.dev --build-arg BASE=riscv-src -t riscv-src-dev .
docker run --rm -it -v $(pwd):/workspace -w /workspace riscv-src-dev bash
```

**VS Code:** Install the
[Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
extension, then open the command palette and choose
**Dev Containers: Reopen in Container**. VS Code will show a picker for the
two configurations (`packages` or `from-source`). The base toolchain image
must be built first (see options 3 or 4 above).

---

## Sanity check: QEMU

```bash
which qemu-system-riscv32
qemu-system-riscv32 --version
qemu-system-riscv32 -machine help
```

## Sanity check: GNU toolchain

```bash
which riscv64-unknown-elf-as
riscv64-unknown-elf-as --version
riscv64-unknown-elf-gcc --version
```

## Install the gdb-dashboard (optional)

> **Note:** Do not overwrite an existing `~/.gdbinit` file you want to keep.

If you used [Option 1](#option-1-native--packages) (native packages), initialise the submodule first:

```bash
git submodule update --init gdb-dashboard
```

[Option 2](#option-2-native--build-from-source) users already have it from `setup.sh`.
Docker images have gdb-dashboard pre-installed.

```bash
cp gdb-dashboard/.gdbinit ~
```

## Build the test app

```bash
cd test-freestanding
make
```

To do a clean rebuild: `make world`

## Run in QEMU

```bash
qemu-system-riscv32 -machine virt -m 128M -bios none -device loader,file=./prog -nographic
```

You should see `Hello World!` printed and QEMU will exit automatically.
If running your own code that has no shutdown, press `CTRL+A` then `x` to terminate QEMU.

## Run the automated test

```bash
make test
```

This builds the program (if needed), runs it under QEMU, and verifies the output.

## Debug with GDB

In one terminal, start QEMU and tell it to wait for GDB to connect before executing
any instructions (the `-S` flag):

```bash
qemu-system-riscv32 -machine virt -m 128M -bios none -device loader,file=./prog -nographic -s -S
```

In a second terminal, connect GDB:

```bash
gdb-multiarch ./prog
(gdb) set architecture riscv:rv32
(gdb) target remote :1234
```

Once connected you are ready to start experimenting with your own freestanding programs!
