main:
    subl $8, %esp
    movl $2147483647, (%esp)
    movl $1, 4(%esp)

    movl (%esp), %eax
    addl %eax, 4(%esp)

    addl $8, %esp
    movl $0, %eax   
    ret
