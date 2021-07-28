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

	PROVIDE(__ram_origin__ = ORIGIN(RAM));
	PROVIDE(__ram_end__ = ORIGIN(RAM) + LENGTH(RAM));

	.text : 
	{
		__text_start = .;
		KEEP(*(.text.crt0))		/* this is why _start comes before any other function */
		*(.text.*)
		__text_end = .;
	}

	/*. = ALIGN(0x10);*/	/* putting this here does not cause the followng section to move */

	.rodata : /*ALIGN(0x10):*/	/* this will the align section but others can overlap */
	{
		. = ALIGN(0x10);		/* aligning here will align the section & update the loc counter */
		__rodata_start = .;
		*(.rodata.*)
		*(.srodata.*)
		__rodata_end = .;
	}

	.data : 
	{ 
		. = ALIGN(0x1000);
		__data_start = .;
		*(.data.*) 
		*(.sdata*) 				/* small data objects */
		__data_end = .; 
	}

    __global_pointer$ = (__data_start + 0x800);	/* stick this somewhere potentially useful */

	
/**/
  .preinit_array    :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  }
  .init_array    :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  }
  .fini_array    :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
    KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
    PROVIDE_HIDDEN (__fini_array_end = .);
  }
/**/

	.bss : 
	{
		. = ALIGN(0x100);
		__bss_start__ = .;
		*(.sbss*) 			/* small data objects */
		*(.bss*) 
		__bss_end__ = .;
	}

	_end = .; 
}
