
; boot.asm - Minimal 16-bit stub, hands off to C
BITS 16
ORG 0x7C00

_start:
    cli                     ; Disable interrupts
    xor ax, ax
    mov ds, ax              ; Zero out segments
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00          ; Stack grows downward from 0x7C00
    sti                     ; Re-enable interrupts

    call boot_main          ; Jump into C!

.hang:
    hlt
    jmp .hang

; Pad to 510 bytes + boot signature
times 510-($-$$) db 0
dw 0xAA55
