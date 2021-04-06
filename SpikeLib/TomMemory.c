#include "print.h"
#include "TomMemory.h"
#include "debug.h"

static struct FreeMemRegion free_mem_region[50];

void Get_Tom_Memory(void){

    int32_t count = *(int32_t*)0x9000;
    uint64_t total_mem = 0;
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

}