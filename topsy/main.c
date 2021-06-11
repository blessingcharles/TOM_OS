#include "lib.h"
#include "stdint.h"

void main(void){

    uint64_t timer = 0;

    while(1){
        if(timer % 10000000 == 0){
            printf("process1 %d\n",timer);
            
        }
        timer++ ;
    }
  
    return ;
}