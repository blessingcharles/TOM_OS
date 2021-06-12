#include "lib.h"
#include "stdint.h"
#include "console.h"


void help_cmd(){
    printf("[TOM OS HELP]\n 1)%s\n 2)%s\n ",HELP_STR,TOTAL_MEM_STR);
}


void cmd_get_total_memory(void)
{
    uint64_t total;
    
    total = get_total_memoryu();
    printf("total memory = %d\n", total);
}
