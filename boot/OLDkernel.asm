[BITS 64]
[ORG 0x200000]

K_init:
    ;handler for division by 0  
    mov rdi,Idt64           ;storing the interrupt handlers in idt with offset
    mov rax,handler0          
    call SetHandler

; handler for system timer at interrupt 32 cuz 0-31 are initialised by the processor
    ;IRQ0  in PIC
    mov rax,timerhandler           
    mov rdi,Idt64+32*16
    call SetHandler

;handler for spurious interrupts [IRQ7]
    mov rax,spurioushandler
    mov rdi,Idt64+32*16+7*16
    call SetHandler

    lgdt [Gdt64ptr]
    lidt [IdtPtr]
; defining task state segment as 5th entry in gdt
SetTSS:
    mov rax,Tss
    mov [TssDesc+2],ax
    shr rax,16
    mov [TssDesc+4],al
    shr rax,8
    mov [TssDesc+7],al
    shr rax,8
    mov [TssDesc+8],eax

    mov ax,0x20
    ltr ax

    push 8
    push K_main
    db 0x48
    retf

K_main:
    mov byte[0xb8000],'k'
    mov byte[0xb8001],0xa

;programmable interrupt controller channels hardware interrupts to specific handlers
;MASTER IRQ[0-7] AND SLAVE IRQ[8-15] SLAVE USE masters IRQ2 to reach processor

;programmble interval time IRQ0
;contains 1mode command , 3 data registers
;moderegister 0         123  45    67 bits
;contains    binaryform mode  type  channel 
PIT:
    mov al,(1<<2)|(3<<4)
    out 0x43,al         ; address of command register

    mov ax,11931        ; 1.2million/100 = 11931 per second pit calls interrupt
    out 0x40,al
    mov al,ah
    out 0x40,al

;initializing programmable interrupt controller  for hardware interrupts  
;master at 0x20 slave at 0xa0
InitPIC:
    mov al,0x11
    out 0x20,al
    out 0xa0,al

    mov al,32
    out 0x21,al
    mov al,40
    out 0xa1,al

    mov al,4
    out 0x21,al
    mov al,2
    out 0xa1,al

    mov al,1
    out 0x21,al
    out 0xa1,al

    mov al,11111110b
    out 0x21,al
    mov al,11111111b
    out 0xa1,al

    ;sti

    ;switch to ring3

    push 0x18|3
    push 0x7c00
    push 0x202
    push 0x10|3
    push Ring3Entry
    iretq   ; to pop all the above 5 values into rip , cs ,rflags ,rsp , ss respectively

K_end:
    hlt
    jmp K_end

Ring3Entry:
    ; lower 2 bit checks in cs for privilige level checks
    ; mov ax,cs
    ; and ax,11b 
    ; cmp ax,3
    ; jne Ring3End

    inc byte[0xb8020]
    mov byte[0xb8021],0xE

Ring3End:
    jmp Ring3Entry

%include "boot/I_handlers.asm"
%include "boot/kernel_utils.asm"
;---------  
;; GDT64

GDT64: 
       dq 0 ; first null entry
       dq 0x0020980000000000 ; code segment for ring 0
       dq 0x0020f80000000000 ; code segment for ring 3  || DPL = 11 (ring3)
       dq 0x0000f20000000000 ; code segment for ring 3  || DPL = 11 (ring3)
TssDesc:
        dw Tsslen-1
        dw 0
        db 0
        db 0x89   ; p DPL TYPE  1 00 01001
        db 0
        db 0
        dq 0

GDT64len: equ $-GDT64

Gdt64ptr: dw GDT64len-1
          dq GDT64

Idt64:
    %rep 256  ; 256 entries each of 16 bytes
        dw 0
        dw 0x8 ;code segment descriptor
        db 0
        db 0x8e  ;P DPL TYPE 1 00 01110
        dw 0
        dd 0
        dd 0
    %endrep

Idtlen: equ $-Idt64
IdtPtr: dw Idtlen
        dq Idt64


Tss:    
    dd 0
    dq 0x150000 ; rsp0
    times 88 db 0
    dd Tsslen 
Tsslen: equ $-Tss

