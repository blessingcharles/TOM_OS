section .text
global start
extern console
extern exitu
;default starting for all elf binaries else defaulted to 0x400000
start:
    call console
    call exitu
    jmp $

