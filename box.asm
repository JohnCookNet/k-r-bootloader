BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; Set VGA mode 13h: 320x200x256
    mov ax, 0x0013
    int 0x10

    ; Video memory segment
    mov ax, 0xA000
    mov es, ax

    ; Rectangle:
    ; x = 100..219
    ; y = 50..149
    mov dx, 50              ; y

y_loop:
    ; di = y * 320 + 100
    mov di, dx
    shl di, 8               ; y * 256

    mov bx, dx
    shl bx, 6               ; y * 64

    add di, bx              ; y * 320
    add di, 100             ; + x start

    mov cx, 120             ; width

x_loop:
    mov byte [es:di], 1     ; blue
    inc di
    loop x_loop

    inc dx
    cmp dx, 150             ; stop after y = 149
    jl y_loop

hang:
    hlt
    jmp hang

times 510-($-$$) db 0
dw 0xAA55