#ifndef _PRINT_H_
#define _PRINT_H_
#define LINE_SIZE 160

struct TomScreenBuffer{
    char* buffer;
    int column;
    int row;
};

int printk(char colorcode,const char* format, ... );
void write_screen(const char *buffer, int size, char color);

#endif