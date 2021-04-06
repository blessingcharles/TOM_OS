[BITS 16]
SwitchToPM:
    cli             ; stop interrupts
    lgdt [Gdt32Ptr] 
    lidt [Idt32Ptr]

    ;enable protected mode[set cr0 to 1]
    mov eax,cr0
    or eax,1
    mov cr0,eax

; Make a far jump ( i.e. to a new segment ) forces the CPU to flush its cache of
; pre - fetched and real - mode decoded instructions , which can
; cause problems if we use move instruction to update cs register
    jmp 8:PM_init

[BITS 32]
PM_init:
    mov ax,0x10    ; mov 16offset (data segment of gdt ) to all segment registers
    mov ds,ax
    mov ss,ax
    mov es,ax
    mov esp,0x7c00

   mov byte[0xb8000],'p'
   mov byte[0xb8001],0xa
;--------
EnableLongMode:
    ;setting page table at 0x7000 - 0x8000
  ;  mov byte[0xb8000],'b'
   ; mov byte[0xb8001],0xa
    cld
    mov edi,0x70000
    xor eax,eax 
    mov ecx,0x10000/4
    rep stosd

    mov dword[0x70000],0x71003
    mov dword[0x71000],10000011b

    mov eax,(0xffff800000000000>>39)
    and eax,0x1ff
    mov dword[0x70000+eax*8],0x72003
    mov dword[0x72000],10000011b

    lgdt [Gdt64ptr]

    ;setting control bits for long mode
    mov eax,cr4
    or eax,(1<<5)
    mov cr4,eax
    ;setting pagetable address in cr3
    mov eax,0x70000
    mov cr3,eax

    mov ecx,0xc0000080
    rdmsr
    or eax,(1<<8)
    wrmsr

    mov eax,cr0
    or eax,(1<<31)
    mov cr0,eax

    jmp 8:LMEntry

[BITS 64]
LMEntry:
    mov rsp,0x7c00

    mov byte[0xb8000],'L'
    mov byte[0xb8001],0xa

    ;changing the IP to kernel 
    mov rdi,0x200000
    mov rsi,0x10000     ;copying the kernel from 0x10000 to 0x200000
    mov rcx,51200/8     ; counter for copying 8 bytes at a time 512 bytes of each 100 sectors kernel
    rep movsq

    mov rax,0xffff800000200000
    jmp rax

;----------

;; hopes it never executes  
PMend:
    hlt
    jmp PMend


;global descriptor table
Gdt32:      dq 0 ; null entry
;code segment
;limit 2^20 * 2^12(pagesize) by setting granularity bit = 4gb
Code32:
    dw 0xffff   ;limit[0-15bits]
    dw 0        ;base [16-31]
    db 0        ;base [32-39]
    db 0x9a       ;flag [code segment]
    db 0xcf       ;limit and flags
    db 0          ; base[56-63]
data32:
    dw 0xffff   ;limit[0-15bits]
    dw 0        ;base [16-31]
    db 0        ;base [32-39]
    db 0x92       ;flag [data segment]
    db 0xcf       ;limit and flags
    db 0          ; base[56-63]
Gdt32Len: equ $-Gdt32

;we pass this global segment to lgdt instruction
Gdt32Ptr: ;[24 bits]consists of len and address of gdt32
    dw Gdt32Len-1   ;can contains 2^16-1/8 = atmost 8192 entries
    dd Gdt32        ; address

;interrupt descriptor table counterpart to realmode interrupt vector table by bios
Idt32Ptr:
    dw 0
    dd 0

;---------
;; GDT64

GDT64: dq 0 ; first null entry
       dq 0x0020980000000000 ; code segment
GDT64len: equ $-GDT64

Gdt64ptr: dw GDT64len-1
          dd GDT64
