
ENTRY(_start)

SECTIONS {
    . = 0x7C00;

    .text : {
        boot.o(.text)   /* asm stub goes first */
        *(.text)        /* then C code */
    }

    .data : {
        *(.data)
        *(.rodata)
    }

    .bss : {
        *(.bss)
    }

    . = 0x7C00 + 510;
    .sig : { SHORT(0xAA55) }
}
