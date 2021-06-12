nasm -f elf64 -o syscall.o syscall.asm
nasm -f elf64 -o liba.o lib.asm

gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c print.c
ar rcs lib.a print.o syscall.o liba.o


nasm -f elf64 -o start.o start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c console.c
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c commands.c

ld -nostdlib -Tlink.lds -o user start.o console.o commands.o lib.a 
objcopy -O binary user ../boot/bin/user1.bin

