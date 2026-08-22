.globl main
.extern printf

.section .rodata
fmt:
    .string "%d\n"

.text

print_int:
    pushl %eax
    pushl $fmt 
    call printf
    addl $8, %esp
    ret

main:
    subl $8, %esp
    movl $32, (%esp)
    movl $-3223, 4(%esp)

    movl (%esp), %eax
    shrl %ax, 4(%esp)

    movl 4(%esp), %eax
    call print_int

    addl $8, %esp
    movl $0, %eax   
    ret
