[BITS 16]

; loading the loader file from disk using bios routine
; bios disk extension service
; loads the loader in 0x7e00 in ram and jump to it
loadloader:

    mov si,readblock
    mov word[si],0x10       ;size 16 bytes   
    mov word[si+2],5        ;5 sectors for loader
    mov word[si+4],0x7e00   ;offset in segmented memory[0x7c00 + 0x200(512 bytes of bootsector)]
    mov word[si+6],0        ; segment 0
    mov dword[si+8],1       ;lba of 1 which means sector 2 in disk  CHS[002]  
    mov dword[si+0xc],0      ; higher lba sets to 0    
    mov dl,[driveid]
    mov ah,0x42             
    int 0x13
    jc NotSupported         ; carry flag sets if error occurs

    mov dl,[driveid]
    jmp 0x7e00              


;printing string using bios routine
printmsg:
    pusha

    mov ah,0x13             ;print to screen, vector number in bios routine
    mov al,1                ;cursor to place at end of string
    mov bx,0xa              ;for green color
    ; mov bp,msg
    ; mov cx,msglen
    xor dx,dx               ;dx has screen resolution [rows*columns] like [dh*dl]
    int 0x10                ;interrupt bios routine
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

;executes if error occurs    
NotSupported:
    mov bx,errormsg
    call printc
    jmp $
