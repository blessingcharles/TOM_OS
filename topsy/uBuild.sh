nasm -f elf64 -o bin/syscall.o ../Tlibc/syscall.asm
nasm -f elf64 -o bin/liba.o ../Tlibc/lib.asm

gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c ../Tlibc/print.c -o bin/print.o
ar rcs lib.a bin/print.o bin/syscall.o bin/liba.o


nasm -f elf64 -o bin/start.o start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c console.c -o bin/console.o
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c commands.c -o bin/commands.o

ld -nostdlib -Tlink.lds -o bin/user bin/start.o bin/console.o bin/commands.o lib.a 
objcopy -O binary bin/user ../boot/bin/user1.bin
