#include "print.h"
#include "TomMemory.h"
#include "debug.h"
#include "stddef.h"
#include "lib.h"
#include "stdbool.h"

static int free_page_count = 0 ;
static struct FreeMemRegion free_mem_region[50];
extern char end;
static struct Page free_memory;
static uint64_t memory_end;

static void free_region(uint64_t v, uint64_t e);

static uint64_t total_mem = 0;

uint64_t get_total_memory(void){
   
    return total_mem/1024/1024 ;
}

//getting the memory map and collecting free regions under 1 gb
void Get_Tom_Memory(void){

    int32_t count = *(int32_t*)0x9000;
    
    struct TomMemoryMap *mem_map = (struct TomMemoryMap*)0x9008;	
    int free_region_count = 0;

    //assert error if our assumption of entries is > 50
    ASSERT(count <= 50);
    printk(0xa3,"  [ADDRESS] [LENGTH] [TYPE]            \n");
	for(int32_t i = 0; i < count; i++) {        
        if(mem_map[i].type == 1) {
            free_mem_region[free_region_count].address = mem_map[i].address;
            free_mem_region[free_region_count].length = mem_map[i].length;
            total_mem += mem_map[i].length;
            free_region_count++;
        }
        
        printk(0x5,"%d [%x]      [%uKB]     [%u] \n",i, mem_map[i].address, mem_map[i].length/1024, (uint64_t)mem_map[i].type);
	}
    printk(0x4,"\nTotal Free memory is %uMB\n", total_mem/1024/1024);

    // collecting free pages of 2mb
    for (int i = 0; i < free_region_count; i++) {                  
        uint64_t vstart = P2V(free_mem_region[i].address);
        uint64_t vend = vstart + free_mem_region[i].length;

        //end(kernel end)
        if (vstart > (uint64_t)&end) {
            free_region(vstart, vend);
        } 
        else if (vend > (uint64_t)&end) {
            free_region((uint64_t)&end, vend);
        }       
    }

    memory_end = (uint64_t)free_memory.next+PAGE_SIZE;
   

}

//given a region it collects 2mb block from it
static void free_region(uint64_t v, uint64_t e)
{
    for (uint64_t start = PA_UP(v); start+PAGE_SIZE <= e; start += PAGE_SIZE) {        
        if (start+PAGE_SIZE <= 0xffff800040000000) {            
           kfree(start);
        }
    }
}

void kfree(uint64_t v)
{
    ASSERT(v % PAGE_SIZE == 0);
    ASSERT(v >= (uint64_t) & end);
    ASSERT(v+PAGE_SIZE <= 0xffff800040000000);

    //adding the page in freelist
    struct Page *page_address = (struct Page*)v;
    page_address->next = free_memory.next;
    free_memory.next = page_address;
}

//allocating kernel memory from free list
void* kalloc(void)
{
    struct Page *page_address = free_memory.next;

    if (page_address != NULL) {
        ASSERT((uint64_t)page_address % PAGE_SIZE == 0);
        ASSERT((uint64_t)page_address >= (uint64_t)&end);
        ASSERT((uint64_t)page_address+PAGE_SIZE <= 0xffff800040000000);

        free_memory.next = page_address->next;            
    }
    
    return page_address;
}

//mapping page directory pointer table in pml4 table
static PDPTR find_pml4t_entry(uint64_t map, uint64_t v, int alloc, uint32_t attribute)
{
    PDPTR *map_entry = (PDPTR*)map;
    PDPTR pdptr = NULL;

    //get the 40-48 bits from the virtual address
    unsigned int index = (v >> 39) & 0x1FF;

    //if map_entry already presents return that value
    if ((uint64_t)map_entry[index] & PTE_P) {
        pdptr = (PDPTR)P2V(PDE_ADDR(map_entry[index]));       
    } 
    else if (alloc == 1) {
       
    // else allocate 
        //create a new pdptr table
        pdptr = (PDPTR)kalloc();          
        if (pdptr != NULL) {     
            memset(pdptr, 0, PAGE_SIZE);  
            //enter that address in the pml4 table index   
            map_entry[index] = (PDPTR)(V2P(pdptr) | attribute);           
        }
    } 

    return pdptr;    
}
//mapping page directory in page directory pointer table
static PD find_pdpt_entry(uint64_t map, uint64_t v, int alloc, uint32_t attribute)
{
    PDPTR pdptr = NULL;
    PD pd = NULL;
    //get the bits of 31-39 in the VA 
    unsigned int index = (v >> 30) & 0x1FF;

    pdptr = find_pml4t_entry(map, v, alloc, attribute);
    if (pdptr == NULL)
        return NULL;
       
    if ((uint64_t)pdptr[index] & PTE_P) {      
        pd = (PD)P2V(PDE_ADDR(pdptr[index]));      
    }
    else if (alloc == 1) {
        //if pd is not present and allocate new one
        pd = (PD)kalloc();  
        if (pd != NULL) {    
            memset(pd, 0, PAGE_SIZE);       
            pdptr[index] = (PD)(V2P(pd) | attribute);
        }
    } 

    return pd;
}

//mapping pages in page directory table
bool map_pages(uint64_t map, uint64_t v, uint64_t e, uint64_t pa, uint32_t attribute)
{
    uint64_t vstart = PA_DOWN(v);
    uint64_t vend = PA_UP(e);
    PD pd = NULL;
    unsigned int index;

    ASSERT(v < e);
    ASSERT(pa % PAGE_SIZE == 0);
    ASSERT(pa+vend-vstart <= 1024*1024*1024);

    do {
        pd = find_pdpt_entry(map, vstart, 1, attribute);    
        if (pd == NULL) {
            return false;
        }

        //getting the 22-30 bits for the page directory table entry
        index = (vstart >> 21) & 0x1FF;
        ASSERT(((uint64_t)pd[index] & PTE_P) == 0);
        
        //storing the physical address in page directory table
        pd[index] = (PDE)(pa | attribute | PTE_ENTRY);

        vstart += PAGE_SIZE;
        pa += PAGE_SIZE;
    } while (vstart + PAGE_SIZE <= vend);
  
    return true;
}

void switch_vm(uint64_t map)
{   
    //cr3 register holds the base address to pml4 table
    load_cr3(V2P(map));   
}


// allocating kernel virtual memory
uint64_t setup_kvm(void)
{
    //getting a new fresh page from the freelist for pml4 table [freememory.next]
    uint64_t page_map = (uint64_t)kalloc();

    if (page_map != 0) {
        memset((void*)page_map, 0, PAGE_SIZE); 

        //mapping kernel and the kernel end to allocate in page table levels       
        if (!map_pages(page_map, KERNEL_BASE, memory_end, V2P(KERNEL_BASE), PTE_P|PTE_W)) {
            //if fail to enter entries in the tables
            free_vm(page_map);
            page_map = 0;
        }
    }
    return page_map;
}

void init_Tom_Virtual_Memory(void)
{   
    // initialising kernel virtual memory
    uint64_t page_map = setup_kvm();
    ASSERT(page_map != 0);

    //storing pml4 base addr in cr3 register
    switch_vm(page_map);
   // printk(0xf,"memory manager is working now\n\n");
}

//user virtual memory mapping
bool setup_uvm(uint64_t map, uint64_t start, int size)
{
    bool status = false;
    void *page = kalloc();

    if (page != NULL) {
        memset(page, 0, PAGE_SIZE);

        //we allocate user pages only at 0x400000 ie [4mb to 6mb]
        status = map_pages(map, 0x400000, 0x400000+PAGE_SIZE, V2P(page), PTE_P|PTE_W|PTE_U);
        if (status == true) {
            //copy the program into the page
            memcpy(page, (void*)start, size);
        }
        else {
            kfree((uint64_t)page);
            free_vm(map);
        }
    }
    
    return status;
}

void free_pages(uint64_t map, uint64_t vstart, uint64_t vend)
{
    //free each page by looping through the pd table
    unsigned int index; 

    ASSERT(vstart % PAGE_SIZE == 0);
    ASSERT(vend % PAGE_SIZE == 0);

    do {
        PD pd = find_pdpt_entry(map, vstart, 0, 0);

        if (pd != NULL) {
            index = (vstart >> 21) & 0x1FF;
            if (pd[index] & PTE_P) {        
                kfree(P2V(PTE_ADDR(pd[index])));
                pd[index] = 0;
            }
        }

        vstart += PAGE_SIZE;
    } while (vstart+PAGE_SIZE <= vend);
}

static void free_pdt(uint64_t map)
{
    PDPTR *map_entry = (PDPTR*)map;

    //looping throught the 512 entries in pml4 table
    for (int i = 0; i < 512; i++) {
        if ((uint64_t)map_entry[i] & PTE_P) {            
            PD *pdptr = (PD*)P2V(PDE_ADDR(map_entry[i]));
            
            //loop  through the 512 entries in pdptr to locate the pd pages
            for (int j = 0; j < 512; j++) {
                if ((uint64_t)pdptr[j] & PTE_P) {
                    kfree(P2V(PDE_ADDR(pdptr[j])));
                    pdptr[j] = 0;
                }
            }
        }
    }
}

static void free_pdpt(uint64_t map)
{
    PDPTR *map_entry = (PDPTR*)map;

    //looping the 512 entries in pml4 entry
    for (int i = 0; i < 512; i++) {
        //present bit is present free the page table
        if ((uint64_t)map_entry[i] & PTE_P) {          
            kfree(P2V(PDE_ADDR(map_entry[i])));
            map_entry[i] = 0;
        }
    }
}

static void free_pml4t(uint64_t map)
{
    kfree(map);
}

void free_vm(uint64_t map)
{   

    //only freeing the 2mb to 4mb of physical space where user process resides
    free_pages(map, 0x400000, 0x400000+PAGE_SIZE);

    //clearing all the paging entries created by the user process
    free_pdt(map);
    free_pdpt(map);
    free_pml4t(map);
}