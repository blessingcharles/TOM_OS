#include "lib.h"
#include "stdint.h"

void main(void){

    int64_t timer = 0 ;
    while(1){
        
        if(timer %100000000 == 0)
            printf("process1 im topsy \n");   

        timer++ ;   
    }
  
    return ;
}