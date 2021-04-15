[BITS 16]
;---------------------------------------------------------------------------
;  ########## LOADER UTILS ##########

;   loadkernel
;   longmodetests
;   printc
;   printnewline
;   GetMemoryMap
;   TestA20
;   NotSupported/end
;----------------------------------------------------------------------------
;;loading above 1mb
loadkernel:
    pusha

    mov si,readblock
    mov word[si],0x10       ;size 16 bytes   
    mov word[si+2],100      ;100 sectors for kernel in img
    mov word[si+4],0        ;offset
    mov word[si+6],0x1000   ; segment 1mb
    mov dword[si+8],6       ;lba of 6 which means sector 7 in disk  CHS[007]  
    mov dword[si+0xc],0      ; higher lba sets to 0    
    mov dl,[driveid]
    mov ah,0x42             
    int 0x13
    jz NotSupported

    popa
    ret

loaduser:
   pusha

    mov si,readblock
    mov word[si],0x10       ;size 16 bytes   
    mov word[si+2],10      ;10 sectors for user in img
    mov word[si+4],0        ;offset
    mov word[si+6],0x2000   ; segment 1mb
    mov dword[si+8],106       ;lba of 106 which means sector 107 in disk 
    mov dword[si+0xc],0      ; higher lba sets to 0    
    mov dl,[driveid]
    mov ah,0x42             
    int 0x13
    jz NotSupported

    popa
    ret

longmodetests:
    pusha

    mov eax,0x80000000      ;testing for long mode
    cpuid
    cmp eax,0x80000001
    jb NotSupported
    mov eax,0x80000001
    cpuid
    test edx,(1<<29)
    jz NotSupported
    test edx,(1<<26)
    jz NotSupported

    popa
    ret

;get memory map via the bios routine
GetMemoryMap:
    pusha

    mov eax,0xe820
    mov edx,0x534d4150          ;ascii for SMAP
    mov ecx,20                  ;one memory block of size 20
    mov dword[0x9000],0         ;count 
    mov edi,0x9008              ;destination addr 0x9008
    xor ebx,ebx
    int 0x15
    jc NotSupported
    
    ;loop through to get all blocks of memory map 
    GetMemoryLoopInfo:
        add edi,20              ;storing the next block at (0x9014) and looping
        inc dword[0x9000]
        test ebx,ebx                
        jz GetMemoryDone

        mov eax,0xe820
        mov edx,0x534d4150          ;ascii for SMAP
        mov ecx,20  
        int 0x15
        jnc GetMemoryLoopInfo            ;if zeroflag is set return

    
    GetMemoryDone:
        popa
        ret

; test if our address bus greater that 20 [enabled by default in motherboard]
; checking by storing a random value in 0x7c00(boot code) cuz it is not used anymore
;and comparing it with 0x107c00 if a20 not enables then address 0x107c00 is truncated to 0x7c00 
TestA20:
    pusha
    mov ax,0xffff
    mov es,ax                  ;    LA                      PA
    mov word[ds:0x7c00],0xa200 ;0:0x7c00       = 0*16    [shift by 4bits] + 0x7c00 = 0x7c00         
    cmp word[es:0x7c10],0xa200 ;0xffff:0x7c10  = 0xffff*16[shift by 4bits] + 0x7c10= 0x107c00 [if a20 if enables]
    jne TestA20done
    ;may be if we are unlucky the junk in 0x107c00 is 0xa20 
    ; then we need to do a another test WTF case
    mov word[ds:0x7c00],0xb200
    cmp word[es:0x7c10],0xb200 
    ;if now also same then  a20 is disabled
    je NotSupported
    TestA20done:
        xor ax,ax
        mov es,ax
        popa
        ret
;after switcing to protected mode we cant use bios routine
;so we use video memory at 0xb8000 (80*25) text mode
VideoModePrint:
    pusha
    mov ax,3            ; for setting text mode
    int 0x10

    mov si,videomodemsg
    mov ax,0xb800
    mov es,ax
    xor di,di
    mov cx,videomodemsglen      ;for looping counter
;   0xb8000 contain char and 0xb8001 contains color where
;   upper 4 bits for background and lower 4 bits for foregound
    printmsg:
        mov al,[si]         ;storing a char in al
        mov [es:di],al      ;storing in video mode memory at 0xb8000
        mov byte[es:di+1],0xa   ;for green color 

        add di,2            ;offset++
        add si,1            ;*str++
        loop printmsg
    popa
    ret
;print a single char by looping though the string untill \0
;[ parameters bx=&str]
printc:
    pusha
    mov ah,0x0e             ; ttymode
    loop:
        mov al,[bx]         ; ah=*bx
        cmp al,0            ; while(al!=0 loop through)
        je endloop
        int 0x10
        add bx,1            ; bx++
        jmp loop
    endloop:
    popa

;print newline
printnewline:
    pusha
    
    mov ah,0x0e             ;set to tty
    mov al,0x0a             ;char newline
    int 0x10
    
    mov al,0x0d             ;char carriage return
    int 0x10
    popa
    ret

NotSupported:
end:
    hlt
    jmp end