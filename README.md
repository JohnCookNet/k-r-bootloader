# BIOS Hello World Bootloader in C

A minimal x86 real-mode bootloader for **SeaBIOS** that boots directly in a VM and prints:

`Hello from C!` 

This project is a small learning exercise in low-level systems programming, combining:

- a tiny **16-bit assembly stub**
- a **freestanding C function**
- BIOS teletype output via `int 0x10`

## Overview

At boot time, the BIOS loads the first 512 bytes of the bootable disk into memory at address `0x7C00` and begins execution there.

This project uses:

- `boot.asm` to initialize the CPU state and stack
- `boot.c` to hold the higher-level logic
- `boot.ld` to place the code at the correct address
- `build.sh` to assemble, compile, link, and produce a bootable image

## Files

- `boot.asm` — minimal 16-bit boot stub
- `boot.c` — C entry point that prints the message
- `boot.ld` — linker script for boot-sector layout
- `build.sh` — build script that creates `boot.img`

## How it works

### Boot flow

1. BIOS loads the boot sector at `0x7C00`
2. Execution begins in `_start` from `boot.asm`
3. The assembly stub:
   - disables interrupts
   - initializes segment registers
   - sets up the stack
   - calls `boot_main()`
4. `boot_main()` in `boot.c` prints text using BIOS interrupt `0x10`
5. Control returns to the halt loop

## Requirements

You will need:

- `nasm`
- `gcc`
- `ld`
- `objcopy`
- `dd`

On Debian/Ubuntu:

```bash
sudo apt-get update
sudo apt-get install nasm gcc binutils
```

## Build

Run:

```bash
chmod +x build.sh
./build.sh
```

This produces:

- `boot.elf` — linked ELF image
- `boot.bin` — raw binary
- `boot.img` — bootable 512-byte disk image

## Run in Proxmox

This project is intended for **SeaBIOS**, not UEFI.

### Recommended VM settings

- BIOS: `SeaBIOS`
- Machine: standard x86 VM
- Boot device: disk image containing `boot.img`

### Typical workflow

1. Build `boot.img`
2. Upload it to your Proxmox storage
3. Attach it to a VM
4. Set boot order so the VM boots from that image
5. Start the VM console

Expected output:

```text
Hello from C!
```

## Important notes

### BIOS only

This project depends on BIOS interrupts, especially:

- `int 0x10` for text output

It will **not** work under pure UEFI/OVMF without rewriting it as a UEFI application.

### Boot sector size limit

A BIOS boot sector is only **512 bytes**, and must end with the signature:

```text
0x55AA
```

If the final image exceeds 512 bytes, the BIOS will not treat it as a valid boot sector unless you implement a second-stage loader.

### Freestanding C

This is not a normal userspace C program.

There is:

- no libc
- no operating system
- no `main()` runtime
- no dynamic memory
- no file I/O

The code runs directly on the machine immediately after BIOS handoff.

## Why use C at all?

Pure assembly is the most direct way to write a boot sector, but using C for logic makes experiments easier.

This project uses assembly only where absolutely necessary:

- CPU setup
- early entry point
- BIOS interrupt interface

After that, control passes into C.

## Example project structure

```text
.
├── boot.asm
├── boot.c
├── boot.ld
├── build.sh
└── README.md
```

## Future ideas

Possible next steps for this project:

- print directly to VGA text memory instead of using BIOS
- switch to VGA mode `13h`
- draw pixels on screen
- read keyboard input
- build a small game like Snake or Pong
- add a second-stage loader for larger programs

## Learning goals

This project is useful for learning about:

- x86 real mode
- BIOS boot process
- memory layout at boot
- freestanding C
- linker scripts
- assembly/C interoperability

## License

Use freely for experimentation and education.
