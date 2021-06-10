nasm -f elf64 -o bin/syscall.o ../Tlibc/syscall.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c ../Tlibc/print.c -o bin/print.o
ar rcs lib.a bin/print.o bin/syscall.o


nasm -f elf64 -o bin/start.o start.asm
gcc -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c main.c -o bin/main.o
ld -nostdlib -Tlink.lds -o bin/user bin/start.o bin/main.o lib.a 
objcopy -O binary bin/user ../boot/bin/user2.bin
