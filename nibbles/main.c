#include "lib.h"
#include "stdint.h"

void main(void){

    printf("process2 nibbles\n");    
    char *p = (char *)0xffff800000200200 ;
    *p = 1 ;
      

    return ;
}