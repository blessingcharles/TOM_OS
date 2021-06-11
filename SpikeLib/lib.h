/*
###### SPIKE LIBC FOR TOM OS ######
*/
#ifndef _LIB_H_
#define _LIB_H_

#include "stdbool.h"

//process scheduling list pointer to next process
struct List{
    struct List* next;
};

    /*
       p1-> p2-> p3
         \       /   
           -head-
    */
struct HeadList{

    struct List *next; //current process
    struct List *tail; //last process   
};

void memset(void* buffer,char value,int size);
void memmove(void* dst,void *src,int size);
void memcpy(void* dst,void* src,int size);
int memcmp(void* src1,void* src2,int size);

//process scheduling lib utils
void append_list_tail(struct HeadList *list , struct List *item);
struct List *remove_list_head(struct HeadList *list);
bool is_list_empty(struct HeadList *list);


#endif