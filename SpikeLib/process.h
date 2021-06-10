#ifndef _PROCESS_H_
#define _PROCESS_H_

#include "../boot/traps.h"
#include "lib.h"

#define STACK_SIZE (2*1024*1024)
#define NUM_PROC 10 	// max of 10 process

#define PROC_UNUSED 0
#define PROC_INIT 1
#define PROC_RUNNING 2
#define PROC_READY 3
#define PROC_SLEEP 4
#define PROC_KILLED 5

//process control block for a proces
struct Process {
	struct List *next ;
    int pid;
	int state;		//state of the process
	int wait;
	uint64_t context;
	uint64_t page_map;	//its virtual page map points to pml4 of the process
	uint64_t stack;
	struct TrapFrame *tf;
};

//Ready wait kill list for the process
struct ProcessControl{

	struct Process *current_process;
	struct HeadList ready_list ;
	struct HeadList wait_list ;
	struct HeadList kill_list ;
};

//task state segment for storing kernel stack in rsp0 for using in context switch to ring0
struct TSS {
    uint32_t res0;
    uint64_t rsp0;
    uint64_t rsp1;
    uint64_t rsp2;
	uint64_t res1;
	uint64_t ist1;
	uint64_t ist2;
	uint64_t ist3;
	uint64_t ist4;
	uint64_t ist5;
	uint64_t ist6;
	uint64_t ist7;
	uint64_t res2;
	uint16_t res3;
	uint16_t iopb;
} __attribute__((packed));



void init_process(void);
void launch(void);
void pstart(struct TrapFrame *tf);
void yield_tomprocess(void);
void swap(uint64_t *prev, uint64_t next);
void sleep(int wait);
void wake_up(int wait);
void exit(void);
void wait(void);

#endif