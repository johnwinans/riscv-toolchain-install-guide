/* Copied from the Script for -z combreloc and heavily hacked up by jrw */
/* Copyright (C) 2014-2020 Free Software Foundation, Inc.
   Copying and distribution of this script, with or without modification,
   are permitted in any medium without royalty provided the copyright
   notice and this notice are preserved.  */

OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)

MEMORY
{
   /* qemu-system-risc32 virt machine */
   RAM (rwx)  : ORIGIN = 0x80000000, LENGTH = 128M 
}

ENTRY(_start) /* this will cause an error if the symbol _start is not present */

SECTIONS
{
	. = ORIGIN(RAM);

	.text : {
		KEEP(*(.text.crt0))		/* this is why _start comes before any other function */
		*(.text.*)
	}

	.rodata :
	{
		. = ALIGN(0x10);		/* aligning here will align the section & update the loc counter */
		*(.rodata.*)
		*(.srodata.*)
	}

	.data : 
	{ 
		. = ALIGN(0x1000);
		__data_start = .;
		*(.data.*) 
		*(.sdata*) 				/* small data objects */
	}

    PROVIDE(__global_pointer$ = (__data_start + 0x800));	/* PROVIDE global pinter address */

	.bss : 
	{
		. = ALIGN(0x100);
		__bss_start__ = .;
  		PROVIDE(__bss_start = __bss_start__); /* Need to PROVIDE this as it is used in crt0.S */
		*(.sbss*) 			/* small data objects */
		*(.bss*) 
		__bss_end__ = .;
  		PROVIDE(__bss_end = __bss_end__); /* Need to PROVIDE this as it is used in crt0.S */
	}

	. = ALIGN(16); 
  	PROVIDE(_init_stack_top = ORIGIN(RAM) + LENGTH(RAM)); /* Setting top of the stack last memory address. Need to PROVIDE this as it is used in crt0.S */
	_end = .; 
}
