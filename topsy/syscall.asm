
;SYS_WRITE 0 [writeu]

section .text
global writeu
global sleepu
global exitu
global waitu
global keyboard_readu
global get_total_memoryu
writeu:
    sub rsp,16
    xor eax,eax         ;rax stores the system call number

    mov [rsp],rdi       ;*buffer
    mov [rsp+8],rsi     ;bufferlen    

    mov rdi,2        ; two arguments passed
    mov rsi,rsp 
    int 0x80

    add rsp,16
    ret

sleepu:
    sub rsp,8
    mov eax,1

    mov [rsp],rdi 
    mov rdi,1 
    mov rsi,rsp

    int 0x80

    add rsp,8
    ret


exitu:
    mov eax,2
    mov rdi,0

    int 0x80

    ret

waitu:
    mov eax,3
    mov rdi,0

    int 0x80

    ret

keyboard_readu:
    mov eax,4
    xor rdi,rdi 

    int 0x80
    ret

get_total_memoryu:
    mov eax,5
    xor rdi,rdi 

    int 0x80
    ret