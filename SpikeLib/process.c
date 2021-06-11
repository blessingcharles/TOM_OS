#include "process.h"
#include "../boot/traps.h"
#include "TomMemory.h"
#include "print.h"
#include "lib.h"
#include "debug.h"

extern struct TSS Tss; 
static struct Process process_table[NUM_PROC];
static struct ProcessControl pc ;
static int pid_num = 1;
// void main(void);

static void set_tss(struct Process *proc)
{
    Tss.rsp0 = proc->stack + STACK_SIZE;    
}

//finding the unused pcb by looping through the process_table
static struct Process* find_unused_process(void)
{
    struct Process *process = NULL;

    for (int i = 0; i < NUM_PROC; i++) {
        if (process_table[i].state == PROC_UNUSED) {
            process = &process_table[i];
            break;
        }
    }

    return process;
}

//set up the process entry for the new process
static void set_process_entry(struct Process *proc , uint64_t addr)
{
    uint64_t stack_top;

    proc->state = PROC_INIT;
    proc->pid = pid_num++;

    //allocating kernel stack
    proc->stack = (uint64_t)kalloc();
    ASSERT(proc->stack != 0);

    memset((void*)proc->stack, 0, PAGE_SIZE);   
    stack_top = proc->stack + STACK_SIZE;

    //for switching to the process for the first time
    //when swap occurs the ret addr points to trap return we results in process switching
    proc->context = stack_top - sizeof(struct TrapFrame) - 7*8 ;
    *(uint64_t *)(proc->context + 6*8) = (uint64_t)TrapReturn ;


    proc->tf = (struct TrapFrame*)(stack_top - sizeof(struct TrapFrame)); 
    proc->tf->cs = 0x10|3;
    proc->tf->rip = 0x400000;               //init rip ---> 0x400000 virtual address for all user process
    proc->tf->ss = 0x18|3;
    proc->tf->rsp = 0x400000 + PAGE_SIZE;   //stack grows from top to bottom 6mb to 4mb
    proc->tf->rflags = 0x202;
    
    proc->page_map = setup_kvm();
    ASSERT(proc->page_map != 0);
    ASSERT(setup_uvm(proc->page_map, (uint64_t)P2V(addr), 5120));   //size of each process is 10  sectors[512*10]
    proc->state = PROC_READY ;
}

static struct ProcessControl* get_pc(void){

    return &pc ;
}

void init_process(void)
{  

    struct ProcessControl *process_control;
    struct Process *proc ;
    struct HeadList *list;
    uint64_t addr[2] = {0x20000,0x30000};
    
    process_control = get_pc();
    list = &process_control->ready_list ;

    for(uint8_t i = 0 ; i < 2 ; i++){
        proc = find_unused_process();
        set_process_entry(proc,addr[i]);
        append_list_tail(list,(struct List *)proc);
    }

    
}

void launch(void)
{

    struct ProcessControl *process_control ;
    struct Process *process ;

    process_control = get_pc();
    process = (struct Process *)remove_list_head(&process_control->ready_list);
    process->state = PROC_RUNNING ;
    process_control->current_process = process;


    set_tss(process);
    switch_vm(process_table->page_map);   //loading the pagemap in cr3
//printk(0xf,"\n\n ))))))))))))) \n\n\n");
    pstart(process->tf); // in traps.asm from the trap frame the cpl is taken from cs register

}

static void switch_process(struct Process *prev, struct Process *current)
{
    set_tss(current);
    switch_vm(current->page_map);
    swap(&prev->context, current->context);
}


static void schedule_tom_processes(void)
{
    struct Process *prev_proc;
    struct Process *current_proc;
    struct ProcessControl *process_control;
    struct HeadList *list;

    process_control = get_pc();
    prev_proc = process_control->current_process;
    list = &process_control->ready_list;
    ASSERT(!is_list_empty(list));
    
    current_proc = (struct Process*)remove_list_head(list);
    current_proc->state = PROC_RUNNING;   
    process_control->current_process = current_proc;

    switch_process(prev_proc, current_proc);   
}

// for each timer interrupt we schedule new process
void yield_tomprocess(void)
{
    struct ProcessControl *process_control;
    struct Process *process;
    struct HeadList *list;
    
    process_control = get_pc();
    list = &process_control->ready_list;

    if (is_list_empty(list)) {
        //if no process in list queue return
        return;
    }

    process = process_control->current_process;
    process->state = PROC_READY;
    append_list_tail(list, (struct List*)process);
    schedule_tom_processes();
}
