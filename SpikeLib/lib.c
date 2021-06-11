#include "lib.h"
#include "stddef.h"
#include "debug.h"
#include "process.h"
//new process are appends to the tail
void append_list_tail(struct HeadList *list, struct List *item)
{
    //append the process item in the list
    item->next = NULL;

    if (is_list_empty(list)) {
        list->next = item;
        list->tail = item;
    }
    else {
        list->tail->next = item;
        list->tail = item;
    }
}

//removing the process from the list and the next points to the item->next
struct List* remove_list_head(struct HeadList *list)
{
    struct List *item;

    if (is_list_empty(list)) {
        return NULL;
    }

    item = list->next;
    list->next = item->next;
    
    if (list->next == NULL) {
        list->tail = NULL;
    }
    
    return item;
}



struct List* remove_list(struct HeadList *list, int wait)
{
    struct List *current = list->next;
    struct List *prev = (struct List*)list;
    struct List *item = NULL;

    //looping throught the wait list
    while (current != NULL) {
        if (((struct Process*)current)->wait == wait) {
           //remove the current from the waiting list
            prev->next = current->next;
            item = current;

            if (list->next == NULL) {
                list->tail = NULL;
            }
            else if (current->next == NULL) {
            
            //the item we get is last element then tail = prev waiting process
                list->tail = prev;
            }

            break;
        }

        prev = current;
        current = current->next;    
    }

    return item;
}


bool is_list_empty(struct HeadList *list)
{
    return (list->next == NULL);
}