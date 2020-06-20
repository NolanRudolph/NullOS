GCCPARAMS = -ffreestanding -O2 -nostdlib -lgcc
LDPARAMS = -ffreestanding -O2 -nostdlib -lgcc
SRCPREFIX = boot/
# ASPARAMS = 

objects = obj/boot.o obj/kernel.o

obj/%.o: $(SRCPREFIX)%.c
	i686-elf-gcc $(GCCPARAMS) -o $@ -c $<

obj/%.o: $(SRCPREFIX)%.s
	i686-elf-as -o $@ $<

iso/boot/nullOS.bin: linker.ld $(objects)
	i686-elf-gcc $(LDPARAMS) -T $< -o $@ $(objects)
