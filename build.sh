
#!/bin/bash

# Assemble the stub
nasm -f elf32 boot.asm -o boot_asm.o

# Compile the C code
gcc -m16 -ffreestanding -fno-pic \
    -fno-stack-protector \
    -nostdlib -nostdinc \
    -mno-sse -mno-sse2 \
    -O2 -c boot.c -o boot_c.o

# Link both together
ld -T boot.ld -m elf_i386 \
    boot_asm.o boot_c.o \
    -o boot.elf

# Strip to raw binary
objcopy -O binary boot.elf boot.bin

# Pad to 512 bytes
dd if=boot.bin of=boot.img bs=512 count=1 conv=sync 2>/dev/null

echo "Done! boot.img is ready."
stat -c "Size: %s bytes" boot.img
