#ifndef _TOM_MEMORY_H
#define _TOM_MEMORY_H

#include "stdint.h"
struct TomMemoryMap {
    uint64_t address;
    uint64_t length;
    uint32_t type ;
}__attribute__((packed));

struct FreeMemRegion{
    uint64_t address;
    uint64_t length;
};

void Get_Tom_Memory(void);

#endif