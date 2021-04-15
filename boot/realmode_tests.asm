[BITS 16]


;testing bios for disk reading for loading our kernel[mostly supported all firmwares]
TestDiskExension:
    mov ah,0x41
    mov bx,0xa
    int 0x13
    jc NotSupported
    cmp bx,0xaa55
    jne NotSupported
    ;print msg if disk service supporte by bios
    mov bp,test1              ;bp contains & to string
    mov cx,test1len           ;cx contains the msglength
    call printmsg
    ret