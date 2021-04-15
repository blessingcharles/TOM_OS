
SetHandler:
    mov [rdi],ax
    shr rax,16
    mov [rdi+6],ax
    shr rax,16
    mov [rdi+8],eax
    ret