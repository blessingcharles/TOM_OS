section .text
global start
extern main
;default starting for all elf binaries else defaulted to 0x400000
start:
    call main
    jmp $

