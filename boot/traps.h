/*
Handling interrupts for tom os
[traps.h ====> traps.asm,traps.c]

struct IdtEntry
struct IdtPtr
struct TrapFrame
vectors procedures
load_idt
eoi
Load_Idt
read_isr
*/

// def guards
#ifndef _TRAP_H_
#define _TRAP_H_

#include "stdint.h"

/*
    structure for each 256 idt entries
        dw 0
        dw 0x8 ;code segment descriptor
        db 0
        db 0x8e  ;P DPL TYPE 1 00 01110
        dw 0
        dd 0
        dd 0
*/
struct IdtEntry{
    uint16_t low;
    uint16_t selector;
    uint8_t res0   ;
    uint8_t attr  ;
    uint16_t mid ;
    uint32_t high ;
    uint32_t res1 ;
};

/*
idtptr structure points to start of the table
        Idtlen
        dq Idt
*/
struct IdtPtr{
    uint16_t limit;
    uint64_t addr ;
}__attribute__((packed)); // so there is no padding

/*
interrupt handler function structure to access the register which are pushed into the stack before calling
*/

struct TrapFrame {
    int64_t r15;
    int64_t r14;
    int64_t r13;
    int64_t r12;
    int64_t r11;
    int64_t r10;
    int64_t r9;
    int64_t r8;
    int64_t rbp;
    int64_t rdi;
    int64_t rsi;
    int64_t rdx;
    int64_t rcx;
    int64_t rbx;
    int64_t rax;
    int64_t trapno;
    int64_t errorcode;
    int64_t rip;
    int64_t cs;
    int64_t rflags;
    int64_t rsp;
    int64_t ss;
};

/* interrupt routines for each interrupts */
void vector0(void);
void vector1(void);
void vector2(void);
void vector3(void);
void vector4(void);
void vector5(void);
void vector6(void);
void vector7(void);
void vector8(void);
void vector10(void);
void vector11(void);
void vector12(void);
void vector13(void);
void vector14(void);
void vector16(void);
void vector17(void);
void vector18(void);
void vector19(void);
void vector32(void);
void vector33(void);
void vector39(void);
void sysint(void);
void init_idt(void);
void eoi(void);
void load_idt(struct IdtPtr *ptr);
unsigned char read_isr(void);
void dummyend(void);
void TrapReturn(void);
uint64_t get_ticks(void);

#endif



