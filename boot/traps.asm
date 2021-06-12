;[traps.h ====> traps.asm,traps.c]
;functions available
;
;VECTORS:
;            vectors for each handler which calls trap which ultimately call handler procedure 
;in traps.c which handle each interrupt by a switch statement. For interrupts [8 - 14],17 the error code is pushed into stack by the processor.

;EOI :       end of interrupt
;load_idt:   load idt
;read_isr:   read isr from pic

section .text
extern handler
global vector0
global vector1
global vector2
global vector3
global vector4
global vector5
global vector6
global vector7
global vector8
global vector10
global vector11
global vector12
global vector13
global vector14
global vector16
global vector17
global vector18
global vector19
global vector32
global vector33
global vector39
global sysint
global load_cr3
global eoi
global read_isr
global load_idt
global pstart
global swap
global dummyend
global in_byte
global TrapReturn

Trap:
    push rax
    push rbx  
    push rcx
    push rdx  	  
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    ; inc byte[0xb8010]
    ; mov byte[0xb8011],0xe

    mov rdi,rsp
    call handler

TrapReturn:
    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi  
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax       

    add rsp,16      ;removing the error code and interrupt index
    iretq           ;IRETQ restores rip, cs, rflags, rsp, and ss from interrupts

vector0:
    push 0          ; error code
    push 0          ; interrupt index
    jmp Trap

vector1:
    push 0
    push 1
    jmp Trap

vector2:
    push 0
    push 2
    jmp Trap

vector3:
    push 0
    push 3	
    jmp Trap 

vector4:
    push 0
    push 4	
    jmp Trap   

vector5:
    push 0
    push 5
    jmp Trap    

vector6:
    push 0
    push 6	
    jmp Trap      

vector7:
    push 0
    push 7	
    jmp Trap  

vector8:
    push 8
    jmp Trap  

vector10:
    push 10	
    jmp Trap 
                   
vector11:
    push 11	
    jmp Trap
    
vector12:
    push 12	
    jmp Trap          
          
vector13:
    push 13	
    jmp Trap
    
vector14:
    push 14	
    jmp Trap 

vector16:
    push 0
    push 16	
    jmp Trap          
          
vector17:
    push 17	
    jmp Trap                         
                                                          
vector18:
    push 0
    push 18	
    jmp Trap 
                   
vector19:
    push 0
    push 19	
    jmp Trap

; timer handler
vector32:
    push 0
    push 32
    jmp Trap

;keyboard strokes handler
vector33:
    push 0
    push 33
    jmp Trap

;spurious interrupt
vector39:
    push 0
    push 39
    jmp Trap

sysint:
    push 0
    push 0x80
    jmp Trap

eoi:
    mov al,0x20
    out 0x20,al
    ret

read_isr:
    mov al,11
    out 0x20,al
    in al,0x20
    ret

;for loading idt from kernel_main.c
load_idt:
    lidt [rdi]
    ret

load_cr3:
    mov rax,rdi
    mov cr3,rax
    ret   

;process starts
pstart:
    mov rsp,rdi
    jmp TrapReturn

;process scheduling swap
swap:
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15

    ;change kernel stack pointer in context of pcb from one process to another while process switching
    mov [rdi],rsp
    mov rsp,rsi 

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx

    ret

;for keyboard handler
in_byte:
    mov rdx,rdi         ;0x60 port for getting scan codes
    in al,dx
    ret

dummyend:
    jmp dummyend