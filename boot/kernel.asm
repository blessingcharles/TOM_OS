section .data 
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
    Tss:    
        dd 0
        dq 0xffff800000190000 ; rsp0
        times 88 db 0
        dd Tsslen 
    Tsslen: equ $-Tss


section .text
    extern kernel_main
    global K_init

    K_init:
        mov rax,Gdt64ptr
        lgdt [rax]
    ; defining task state segment as 5th entry in gdt
    SetTSS:
        mov rax,Tss
        mov rdi,TssDesc
        mov [rdi+2],ax
        shr rax,16
        mov [rdi+4],al
        shr rax,8
        mov [rdi+7],al
        shr rax,8
        mov [rdi+8],eax

        mov ax,0x20
        ltr ax

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

        mov rax,K_main
        push 8
        push rax
        db 0x48
        retf

    K_main:
      ;  xor ax,ax
       ; mov ss,ax

        mov rsp,0xffff800000200000
        call kernel_main
        ;sti
        
    K_end:
        hlt
        jmp K_end

