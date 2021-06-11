
;SYS_WRITE 0 [writeu]

section .text
global writeu
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