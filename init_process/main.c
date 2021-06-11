#include "lib.h"
#include "stdint.h"

void main(void){

    while(1){
        //the process will do cleanup by wait systemcall
        waitu();
    }
  
    return ;
}