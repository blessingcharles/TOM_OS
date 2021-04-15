########################## TOM OS BUILD SCRIPTS ###################################
#                                                                                 #
#                                                                                 #
###################################################################################

path1="boot/bin"
gccFlags="-std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone"
ldFlags="-nostdlib -T jerrylinker.lds"

objectfiles="$path1/kernel      $path1/kernel.o   $path1/Kmain.o 
             $path1/trap.o      $path1/trapa.o    $path1/print.o 
             $path1/lib.o       $path1/debug.o    $path1/K_utils.o 
             $path1/TomMemory.o $path1/keyboard.o $path1/process.o
             $path1/syscall.o"


nasm -f bin boot/boot.asm -o $path1/thomas.bin
nasm -f bin boot/loader.asm -o $path1/loader.bin

nasm -f elf64 boot/kernel.asm -o $path1/kernel.o
nasm -f elf64  boot/traps.asm -o $path1/trapa.o
nasm -f elf64 SpikeLib/lib.asm -o $path1/lib.o

#linking the kernel object files via the
gcc $gccFlags -c boot/Kmain.c -o $path1/Kmain.o
gcc $gccFlags -c boot/traps.c -o $path1/trap.o
gcc $gccFlags -c boot/K_utils.c -o $path1/K_utils.o

gcc $gccFlags -c SpikeLib/print.c -o $path1/print.o
gcc $gccFlags -c SpikeLib/debug.c -o $path1/debug.o
gcc $gccFlags -c SpikeLib/TomMemory.c -o $path1/TomMemory.o
gcc $gccFlags -c SpikeLib/process.c -o $path1/process.o
gcc $gccFlags -c SpikeLib/syscall.c -o $path1/syscall.o

gcc $gccFlags -c ButchDrivers/keyboard.c -o $path1/keyboard.o

ld $ldFlags -o $objectfiles

objcopy -O binary $path1/kernel $path1/kernel.bin

dd if=$path1/thomas.bin of=thomas.img count=1 bs=512 conv=notrunc
dd if=$path1/loader.bin of=thomas.img count=5 seek=1 bs=512 conv=notrunc
dd if=$path1/kernel.bin of=thomas.img count=100 seek=6 bs=512 conv=notrunc
dd if=$path1/user.bin of=thomas.img count=10 seek=106 bs=512 conv=notrunc

