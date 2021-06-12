

#ifndef _CONSOLE_H_
#define _CONSOLE_H_


#define TOTAL_SUPPORTED_CMD 100

//cmd numbers in the cmd_list array
#define HELP_CMD 0
#define TOTAL_MEM_CMD 1


#define HELP_STR "help"
#define TOTAL_MEM_STR "totalmem"

typedef void (*CmdFunc)(void);

void help_cmd(void);
void cmd_get_total_memory(void);

#endif