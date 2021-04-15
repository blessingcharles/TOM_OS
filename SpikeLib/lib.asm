section .text
global memset
global memcpy
global memmove
global memcmp

;SYSTEM V AMD64 CALLING CONVENTION
;[ rdi,rsi,rdx,rcx ]

;rdi =*buffer , rsi=value , rdx=size
memset:
    cld
    mov ecx,edx
    mov al,sil
    rep stosb ; copy al into [rdi] address
    ret

;rdi=dst , rsi=src  rdx=size
memcmp:
    cld
    xor eax,eax    
    mov ecx,edx
    repe cmpsb
    setnz al       ;set 1 in al if (str1 != str2)
    ret 

memcpy:
memmove:
    cld
    ;checking for overlap of memory of src and dstination
    ;if not overlap we jump to .copystr directive 
    cmp rsi,rdi
    jae .copystr
    mov r8,rsi
    add r8,rdx
    cmp rsi,rdi
    jbe .copystr
.overlap:
    std
    add rdi,rdx
    add rsi,rdx
    sub rdi,1
    sub rsi,1
.copystr:
    mov ecx,edx
    rep movsb       ; copy from src into destination
    cld
    ret
