[BITS 16]                   ; IN REAL MODE
[ORG 0x7c00]                ; LOADED IN MBR RAM ADDRESS 

;MBR[512] = bootcode[446] + partition entries[64] + magic bytes[0xaa55]

;-----------------------------------------------------------------------------
; boot code 446 bytes
; INITIAL SET UP FOR REGISTERS
_start:
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0x7c00           ; stack pointer points to 0x7c00
main:
    ;printing boot sector starts
    mov bx,msg              ;bp contains & to string
    ;mov cx,msglen            ;cx contains the msglength
    call printc

    ;testing bios for disk reading for loading our kernel[mostly supported all firmwares]
    mov [driveid],dl
    call TestDiskExension
    ;call loadloader
    call loadloader
    

_end:
    hlt                     ;halt the processor untill nxt interrupt occurs
    jmp _end                  
;--------------------------------------------
%include "boot/realmode_utils.asm"
%include "boot/realmode_tests.asm"

driveid:    db 0
msg:        db "[+++ Boot Sector loading +++]",0
test1:      db "Disk extension supported"
test1len:   equ $-test1
readblock:  times 16 db 0            ;loader struct for reading block from disk 
errormsg:   db "[--- error ---]",0

times (0x1be-($-$$)) db 0    ;0x1be = 446 bytes making the remaining space 0

;-------------------------------------------------------------------------------------
;;next 64 bytes disk partition info [4 entries]

db 80h                  ; boot indicator
db 0,2,0                ; starting CHS value
db 0f0h                 ; type
db 0ffh,0ffh,0ffh       ; ending CHS
dd 1                    ; size
dd (20*16*63-1)         ; 10mb size

times (16*3) db 0       ;[making other 3 entries 0]
;---------------------------------------------------------------------------------------
;; magic bytes for boot sector 0xaa55
db 0x55
db 0xaa