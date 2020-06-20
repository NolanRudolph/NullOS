/* BASIC GNU ASSEMBLER */

# Declare constants for the multiboot header.
.set ALIGN,    1<<0             // Alignment for loaded modules on paged boundaries
.set MEMINFO,  1<<1             // Memory map
.set FLAGS,    ALIGN | MEMINFO  // Multiboot flag field
.set MAGIC,    0x1BADB002       // "Magic number" for bootloader recognition
.set CHECKSUM, -(MAGIC + FLAGS) // Checksum confirms we're multiboot
 
# Declare multiboot header marking this program (multiboot) as a kernel
# Magic values apart of the multiboot standard, bootloader searches for this signature
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM
 
// Multiboot standard lacks stack pointer on startup
// Here we allocate 16 KB to the stack using two variables 
// Application Binary Interface (ABI) requires 16B alignment
.section .bss
.align 16
stack_end:
.skip 16384
stack_start:
 
// Used by linker, specifies _start as the kernel entry point
// Bootloader jumps to this position once kernel is loaded
.section .text
.global _start
.type _start, @function
_begin:
    /* Bootloader loads in 32-bit protected mode on x86 machine
     * Interrupts, paging, and other background processes are disabled
     * DO NOT infer implicit implementation of modules, the only
     * features provided to the bootloader is encased by the kernel */

    // Set esp (stack pointer) register to top of the stack 
    mov $stack_start, %esp

    /* TODO: 
     *  1. Initialize Global Descriptor Table (GDT)
     *  2. Initialize Crucial Processor State
     *  3. Enable Interrupts
     *  4. Enable Paging (optional)
     *  5. Create C++ features (e.g. global constructors, exceptions) for runtime support */

    // Enter high-level kernel
    // NOTE: 16B alignment is preserved due to zero pushes
    call kernel_main

    /* Infinite Loop
     *  1. cli flushes interrupt enable in eflags, disabling interrupts
     *  2. hlt waits for next interrupt to arrive
     *  3. jmp jumps to the hlt instruction if woken */
     cli
1:   hlt
     jmp 1b

// Set size of _begin symbol to current location '.' minus start
.size _begin, . - _begin
