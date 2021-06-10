#include "../Tlibc/lib.h"
#include "stdint.h"
#include "console.h"

CmdFunc cmd_list[TOTAL_SUPPORTED_CMD] ;

void init_all_commands(){

    cmd_list[HELP_CMD] = help_cmd ;
    cmd_list[TOTAL_MEM_CMD] = cmd_get_total_memory ;
    cmd_list[OS_INFO_CMD] = os_info_cmd ;
}

static int read_cmd(char *buffer)
{
    char ch[2] = { 0 };
    int buffer_size = 0;

    while (1) {
        ch[0] = keyboard_readu();
        
        if (ch[0] == '\n' || buffer_size >= 80) {
            printf("%s", ch);
            break;
        }
        else if (ch[0] == '\b') {    
            if (buffer_size > 0) {
                buffer_size--;
                printf("%s", ch);    
            }           
        }          
        else {     
            buffer[buffer_size++] = ch[0]; 
            printf("%s", ch);        
        }
    }

    return buffer_size;
}

static int parse_cmd(char *buffer, int buffer_size)
{
    int cmd = -1;

    if(buffer_size == 4 && (!memcmp(HELP_STR,buffer,4))){
        cmd = HELP_CMD;
    }
    else if (buffer_size == 8 && (!memcmp(TOTAL_MEM_STR, buffer, 8))) {
        cmd = TOTAL_MEM_CMD;
    }
    else if(buffer_size == 6 && (!memcmp(OS_INFO_STR,buffer,6))){
        cmd = OS_INFO_CMD;
    }

    return cmd;
}


static void execute_cmd(int cmd)
{   
    switch(cmd){
        case(HELP_CMD):
            cmd_list[HELP_CMD]();
            break ;
        case(TOTAL_MEM_CMD):
            cmd_list[TOTAL_MEM_CMD]();
            break ;
        case(OS_INFO_CMD):
            cmd_list[OS_INFO_CMD]();
            break;

        default:
            break ;
    }
    
}

int console(void)
{
    
    int buffer_size = 0;
    int cmd = 0;
    init_all_commands();

    while (1) {
        char buffer[80] = { 0 };
        printf("\n[TOM OS]#> ");
        buffer_size = read_cmd(buffer);

        if (buffer_size == 0) {
            continue;
        }

        //parse the cmd to check if it exists
        cmd = parse_cmd(buffer, buffer_size);
        
        if (cmd < 0) {
            printf("Oops %s Not Found!\n",buffer);
        }
        else {
            execute_cmd(cmd);             
        }            
    }

    return 0;
}

