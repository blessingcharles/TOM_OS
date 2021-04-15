if [ $1 -z ];then
#run
    qemu-system-x86_64 -cpu Skylake-Server thomas.img -m 1024
    exit
fi

#debug via gdb
qemu-system-x86_64 -cpu Skylake-Server thomas.img -m 1024 -s -S
