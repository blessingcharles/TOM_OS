#include "traps.h"
#include "stddef.h"
#include "K_utils.h"
#include "../SpikeLib/print.h"
#include "../SpikeLib/debug.h"
#include "../SpikeLib/TomMemory.h"

void kernel_main(void){

    init_idt();
    printbanner();
    Get_Tom_Memory();
    init_kvm();

   // ASSERT(0);

}
