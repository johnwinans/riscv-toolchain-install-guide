# riscv-toolchain-install-guide
How to download and install qemu and the GNU toolchain for building and running 
freestanding RISC-V C/C++ programs.

Note this repository is mainly a set links to the submodules and versions that I use as 
described below.

1. Clone this repo:

```
git clone https://github.com/johnwinans/riscv-toolchain-install-guide.git
```

2. Update the sumbodules & checkout the correct versions

```
./installdeps.sh
./setup.sh
```

3. Configure, build, and install the GNU toolchain and qemu

```
./buildall.sh
```

4. Add the new tools to your PATH variable by altering your PATH
If you are using bash and installed the tools ion the default location then
adding the following to the end of your .bashrc file will suffice: 

```
export PATH=${HOME}/projects/riscv/install/rv32i/bin:${PATH}
```

5. Give qemu a basic sanity check

```bash
winans@x570:~$ qemu-system-riscv32 -machine help                    
QEMU emulator version 5.2.0 (v5.2.0)
Copyright (c) 2003-2020 Fabrice Bellard and the QEMU Project developers
winans@x570:~$ qemu-system-riscv32 -machine help
Supported machines are:
none                 empty machine
opentitan            RISC-V Board compatible with OpenTitan
sifive_e             RISC-V Board compatible with SiFive E SDK
sifive_u             RISC-V Board compatible with SiFive U SDK
spike                RISC-V Spike board (default)
virt                 RISC-V VirtIO board
winans@x570:~$
```
