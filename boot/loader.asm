[BITS 16]
[ORG 0x7e00]
start:
    ;testing for long mode
    mov [driveid],dl
    call longmodetests
    ;loading kernel
    call loadkernel
    call loaduser1
    call loaduser2
    
    call printnewline
    mov bx,loadermsg
    call printc
    
    ;getting memory map
    call GetMemoryMap
    call printnewline
    mov bx,memorymapmsg
    call printc

    ;testing a20 is enabled or not
    call TestA20
    call printnewline
    mov bx,a20msg
    call printc

    call VideoModePrint

    call SwitchToPM
    ;call EnableLongMode
    call end


%include "boot/loader_utils.asm"
%include "boot/protectedmode_utils.asm"
;%include "boot/longmode.asm"
;--------------------------------------------------------------------------
driveid:        db 0
loadermsg:      db "long mode supported",0
loadermsglen:   equ $-loadermsg
memorymapmsg:   db "got memory map from bios",0
a20msg:         db "a20 is enabled",0
videomodemsg:   db "video mode is enabled"
videomodemsglen:equ $-videomodemsg
readblock:      times 16 db 0
