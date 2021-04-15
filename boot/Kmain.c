#include "traps.h"
#include "stddef.h"
#include "K_utils.h"
#include "../SpikeLib/print.h"
#include "../SpikeLib/debug.h"
#include "../SpikeLib/TomMemory.h"
#include "../SpikeLib/process.h"
#include "../SpikeLib/syscall.h"

void kernel_main(void){

    init_idt();
    printbanner();
    Get_Tom_Memory();
    init_Tom_Virtual_Memory();
    init_system_call();
    init_process();
    launch();
   // ASSERT(0);

}
