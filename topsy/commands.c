#include "../Tlibc/lib.h"
#include "stdint.h"
#include "console.h"


void help_cmd(){
    printf("[TOM OS HELP]\n 1)%s\n 2)%s\n 3)%s\n",HELP_STR,TOTAL_MEM_STR,OS_INFO_STR);
}


void cmd_get_total_memory(void)
{
    uint64_t total;
    
    total = get_total_memoryu();
    printf("total memory = %d\n", total);
}

void os_info_cmd(void){
   
   printf("\t\t[TOMOS] BY TH3H04X\n\n *SUPPORTS PAGING OF2M\n\n *ROUNDROBIN SCHEDULING\n\n *SYSTEM V CALLING CONVENTION\n\n *MONOLITHIC KERNEL\n\n *FEW SYSTEM CALLS\n\n *TOPSY CONSOLE");
}
