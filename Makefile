GCCPARAMS = -ffreestanding -O2 -nostdlib -lgcc
LDPARAMS = -ffreestanding -O2 -nostdlib -lgcc
# ASPARAMS = 

objects = boot.o kernel.o

%.o: %.c
	gcc $(GCCPARAMS) -o $@ -c $<

%.o: %.s
	i686-elf-as -o $@ $<

nullKernel.bin: linker.ld $(objects)
	i686-elf-gcc $(LDPARAMS) -T $< -o $@ $(objects)
