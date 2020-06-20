/* LINKER FOR NULLOS */

/* Bootloader starts execution at this symbol (within boot.s) */
ENTRY(_start)

/* Describe sections of object files to be placed in kernel image */
SECTIONS
{
  /* Placing kernels at/after 1MB is conventional for bootloaders */
  . = 1M;


  /* Include multiboot header first (integral to early image due to file format)
   * Then include the .text section */
  .text BLOCK(4K) : ALIGN(4K)
  {
    *(.multiboot)
    *(.text)
  }

  /* Read-only data */
  .rodata BLOCK(4K) : ALIGN(4K)
  {
    *(.rodata)
  }

  /* Read-write data (initialized) */
  .data BLOCK(4K) : ALIGN(4K)
  {
    *(.data)
  }

  /* Read-write data (uninitialized) and stack */
  .bss BLOCK(4K) : ALIGN(4K)
  {
    *(COMMON)
    *(.bss)
  }
}
