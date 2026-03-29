; Mandelbrot Bootloader - NASM x86 16-bit Real Mode
; Based on BASIC listing from Adrian's Basement (Tim Riker)
; Assemble: nasm -f bin mandelbrot.asm -o mandelbrot.bin
; Test:     qemu-system-x86_64 -drive format=raw,file=mandelbrot.bin

BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7BFE
    sti

    mov ax, 0x0003
    int 0x10

    mov word [y], -12

y_loop:
    mov ax, [y]
    cmp ax, 12
    jg  done

    mov word [x], -39

x_loop:
    mov ax, [x]
    cmp ax, 39
    jg  newline

    ; ca = x * 0.0458 ; cb = y * 0.08333 in Q16.16
    ; Use rational-ish constants in Q16.16:
    ; ca_step = 0.0458 * 65536 ≈ 3002
    ; cb_step = 0.08333 * 65536 ≈ 5461
    ; ca = x * 3002, cb = y * 5461  (still Q16.16)

    ; EAX = x * 3002
    movsx eax, word [x]
    imul eax, eax, 3002
    mov [ca], eax

    ; EAX = y * 5461
    movsx eax, word [y]
    imul eax, eax, 5461
    mov [cb], eax

    ; a = ca, b = cb
    mov eax, [ca]
    mov [a], eax
    mov eax, [cb]
    mov [b], eax

    xor cx, cx            ; i = 0..15

iter_loop:
    cmp cx, 16
    jge no_escape

    ; t = a*a - b*b + ca
    ; (a*a)>>16  because Q16.16 * Q16.16 => Q32.32
    mov eax, [a]
    imul dword [a]        ; EDX:EAX = a*a
    shrd eax, edx, 16     ; EAX = (a*a)>>16
    mov ebx, eax          ; ebx = a2

    mov eax, [b]
    imul dword [b]
    shrd eax, edx, 16     ; eax = b2

    sub ebx, eax          ; ebx = a2 - b2
    add ebx, [ca]         ; ebx = t
    mov [t], ebx

    ; b = 2*a*b + cb
    mov eax, [a]
    imul dword [b]        ; EDX:EAX = a*b
    shrd eax, edx, 16     ; eax = (a*b)>>16
    add eax, eax          ; *2
    add eax, [cb]
    mov [b], eax

    ; a = t
    mov eax, [t]
    mov [a], eax

    ; escape if a*a + b*b > 4.0
    ; 4.0 in Q16.16 = 4<<16 = 262144
    mov eax, [a]
    imul dword [a]
    shrd eax, edx, 16
    mov ebx, eax          ; a2

    mov eax, [b]
    imul dword [b]
    shrd eax, edx, 16
    add eax, ebx          ; a2+b2

    cmp eax, 262144
    jg  escaped

    inc cx
    jmp iter_loop

no_escape:
    call put_space
    jmp next_x

escaped:
    ; print 0-9 then A-F like BASIC mapping (I>9 => I+=7)
    mov al, cl
    cmp al, 9
    jle .digit
    add al, 7
.digit:
    add al, '0'
    call putc

next_x:
    inc word [x]
    jmp x_loop

newline:
    ; CRLF
    mov al, 0x0D
    call putc
    mov al, 0x0A
    call putc

    inc word [y]
    jmp y_loop

done:
    cli
    hlt
    jmp done

; ---------------- BIOS teletype output ----------------
put_space:
    mov al, ' '
putc:
    mov ah, 0x0E
    xor bx, bx
    int 0x10
    ret

; ---------------- Data ----------------
x   dw 0
y   dw 0

ca  dd 0
cb  dd 0
a   dd 0
b   dd 0
t   dd 0

TIMES 510-($-$$) db 0
DW 0xAA55