    .section    .text.crt0,"ax",@progbits
    .global _start
    .type   _start, @function
    .align 2

_start:     // This has to match the entry address in the ld script!!

    .cfi_startproc
    .cfi_undefined ra

    li      x5,0x10000000       // x5 = @ XS16550 transmitter holding register
2:
    la      x6,hello            // x6 = @ of null-terminated string to print

    // check if nothing to print
    lb      x7,0(x6)            // x7 = next byte to print from the string
    beq     x0,x7,2f            // if the character is \0 then we are done...

    // have something to print
1:
    sb      x7,0(x5)            // ...else write it to the THR 
    addi    x6,x6,1             // advance string pointer to the next character to print
    lb      x7,0(x6)            // x7 = next byte to print from the string
    bne     x0,x7,1b            // if the character is NOT \0 then keep going

2:
    // disable ALL irqs
    csrw    mie,x0

    // Shut down the QEMU virt machine via the sifive_test device (FINISHER_PASS = 0x5555).
    // This causes qemu-system-riscv32 to exit with status 0 so automated tests can detect
    // completion without a timeout.
    li      x5,0x100000         // sifive_test device base address
    li      x6,0x5555           // FINISHER_PASS
    sw      x6,0(x5)

    // Fallback spin in case the write above is somehow delayed.
1:
    wfi
    j       1b

    .cfi_endproc


    .section .rodata            // want in a data section so not end up in an exec only page!
hello:
    .asciz  "Hello World!\n"    // asciz strings have a null-character appended to it:
                                // 48 65 6c 6c 6f 20 57 6f 72 6c 64 21 0a 00

    .end
