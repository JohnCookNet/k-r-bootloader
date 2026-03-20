BITS 16
ORG 0x7C00

start:
    jmp 0:init

init:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; VGA Mode 13h
    mov ax, 0x0013
    int 0x10

    ; Video Segment
    mov ax, 0xA000
    mov es, ax

    ; --- INITIAL STATE IN REGISTERS ---
    ; BL = X position (0-220)
    ; BH = Y position (0-150)
    ; CL = X direction (1 or -1)
    ; CH = Y direction (1 or -1)
    mov bx, 0x0A0A      ; X=10, Y=10
    mov cx, 0x0101      ; DX=1, DY=1

main_loop:
    ; 1. Wait for Vertical Retrace
    mov dx, 0x03DA
.wait_not_vr:
    in al, dx
    test al, 8
    jnz .wait_not_vr
.wait_vr:
    in al, dx
    test al, 8
    jz .wait_vr

    ; 2. Erase old box (Color 0)
    mov al, 0
    call draw_box

    ; 3. Update X
    add bl, cl          ; X = X + DX
    cmp bl, 220
    jb .check_left
    mov bl, 220
    neg cl
    jmp .move_y
 
.check_left:
    cmp bl, 0
    ja .move_y
    mov bl, 0
    neg cl

.move_y:
    ; 4. Update Y
    add bh, ch          ; Y = Y + DY
    cmp bh, 150
    jb .check_top
    mov bh, 150
    neg ch
    jmp .draw

.check_top:
    cmp bh, 0
    ja .draw
    mov bh, 0
    neg ch

.draw:
    ; 5. Draw new box (Color 4 = Red)
    mov al, 4
    call draw_box

    ; 6. Delay
    push cx
    mov cx, 0x3FFF
.delay1:
    push cx
    mov cx, 0x00FF
.delay2:
    loop .delay2
    pop cx
    loop .delay1
    pop cx

    jmp main_loop

; -----------------------------------------------
; draw_box: draws a 100x50 box
; AL = color
; BL = X, BH = Y (from registers!)
; -----------------------------------------------
draw_box:
    pusha
    mov dl, al          ; Save color in DL
    
    xor ax, ax
    mov al, bh          ; AL = Y start
    mov dh, al
    add dh, 50          ; DH = Y end

.y_loop:
    ; DI = Y * 320 + X
    mov di, ax
    shl di, 8           ; Y * 256
    mov si, ax
    shl si, 6           ; Y * 64
    add di, si          ; Y * 320
    xor si, si
    mov si, bx
    and si, 0x00FF      ; Strip BH, keep only BL (X value)
    add di, si          ; DI = Y * 320 + X

    mov cx, 100         ; Width 100
.x_loop:
    mov [es:di], dl     ; Write color from DL
    inc di
    loop .x_loop

    inc ax
    cmp al, dh
    jb .y_loop
    
    popa
    ret

times 510-($-$$) db 0
dw 0xAA55
