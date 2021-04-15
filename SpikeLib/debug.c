#include "debug.h"
#include "print.h"

void error_check(char *file,uint64_t line){

    printk(0xf,"\n ERROR CHECK \n");

    printk(0xf,"assertion failed [%s : %d]",file,line);
    while(1){}
}