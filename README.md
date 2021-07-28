# riscv-toolchain-install-guide
How to download and install qemu and the GNU toolchain for building and running 
freestanding RISC-V C/C++ programs.

Note this repository is mainly a set links to the submodules and versions that I use as 
described below.

1. Clone this repo:

```bash
git clone https://github.com/johnwinans/riscv-toolchain-install-guide.git
```

2. Update the sumbodules & checkout the correct versions

```bash
./installdeps.sh
./setup.sh
```

3. Configure, build, and install the GNU toolchain and qemu
(Note that this can take the better part of an hour to complete!)

```bash
./buildall.sh
```

4. Add the new tools to your PATH variable by altering your PATH
If you are using bash and installed the tools ion the default location then
adding the following to the end of your .bashrc file will suffice: 

```bash
export PATH=${HOME}/projects/riscv/install/rv32i/bin:${PATH}
```

5. Give qemu a basic sanity check

```bash
which qemu-system-riscv32
qemu-system-riscv32 -machine help
qemu-system-riscv32 -machine help
```

The output of the above commands on my box looks like this:

```
winans@x570:~$ which qemu-system-riscv32
/home/winans/projects/riscv/install/rv32i/bin/qemu-system-riscv32
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

6. Give the gnu toolchain a basic sanity check

```bash
which riscv32-unknown-elf-as
riscv32-unknown-elf-as --version
riscv32-unknown-elf-gcc --version
```

The output of the above commands on my box looks like this:

```
winans@x570:~$ which riscv32-unknown-elf-as
/home/winans/projects/riscv/install/rv32i/bin/riscv32-unknown-elf-as
winans@x570:~$ riscv32-unknown-elf-as --version
GNU assembler (GNU Binutils) 2.36.1
Copyright (C) 2021 Free Software Foundation, Inc.
This program is free software; you may redistribute it under the terms of
the GNU General Public License version 3 or later.
This program has absolutely no warranty.
This assembler was configured for a target of `riscv32-unknown-elf'.
winans@x570:~$ riscv32-unknown-elf-gcc --version
riscv32-unknown-elf-gcc (GCC) 11.1.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

winans@x570:~$ 
```


7. Install the gdb dashboard if you prefer

BE CAREFUL THAT YOU DO NOT CLOBBER ANY EXISTING ~/.gdbinit FILE!!!!

The following will copy the gdb-dashboard script into your home directory (possibly clobbering any existing one!)
so that it will be used when gdb is run:

```bash
cp ~/projects/riscv/riscv-toolchain-install-guide/gdb-dashboard/.gdbinit ~
```

Note that there is a problem with qemu v5.2.0 in that it tells the gdb dashboard that there are 
more registers than there really ARE.  Thus the dashboard will complain like this:

```
XXX
```

A simple hack to 'fix' this problem until there is a qemu release to address it is to filter
out the incorrect register names by adding the following lines to the ~/.gdbinit file starting
after line number 1945:

```
            if 'dscratch' in name:
                continue
            if 'mucounteren' in name:
                continue
```

The section code surrounding this addition will then look like this:

```
        for name in register_list:
            # Exclude registers with a dot '.' or parse_and_eval() will fail
            if '.' in name:
                continue
            if 'dscratch' in name:
                continue
            if 'mucounteren' in name:
                continue
            value = gdb.parse_and_eval('${}'.format(name))
            string_value = Registers.format_value(value)
            changed = self.table and (self.table.get(name, '') != string_value)
            self.table[name] = string_value
            registers.append((name, string_value, changed))
```

Keep in mind that python cares about white space (like FORTRAN, COBOL and numerous assembley languages!)
therefore the added lines have to be indented using spaces (not tabs) such that they align with the
existing `if  '.' in name:` line as can be seen above!
