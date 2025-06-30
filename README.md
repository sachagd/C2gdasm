This project is still in development !

If you want to see what this project is able to do, here's a [video](https://x.com/Sachagd_/status/1939119439732953498) for you. You can see the first prime numbers being computed and stored in an array from top to bottom.

As of now, the instruction set is : 

    - add, sub, cmp, idiv 
    - jmp, je/jz, jne/jnz, js, jns, jo, jno, jc, jnc, jge/jnl, jnge/jl, jle/jng, jnle/jg
    - mov
    - cltd
    - call, ret
    - halt

What i'm doing right now : 

    creating distinct opcode based on the operation size (add -> addb, addw, addl)
    finding optimised way to do bitwise operation (if you know a way to do that i'm interested, dm me on discord)
    adding a bunch of jump instruction

## A modest attempt at doing some sort of documentation/explanation : 

# Vocabulary :
    iid : item id

# iid layout : 
    9981 : temp mem 
    9982 : program counter
    9983-9990 : %eax, %ebx, %ecx, %edx, %esi, %edi, %ebp, %esp
    9991 : zero flag
    9992 : sign flag
    9993 : overflow flag
    9994 : carry flag
    9995 : arg1
    9996 : arg1 value
    9997 : arg2
    9998 : arg2 value
    9999 : result

# Groups :
    - 0 to 100 : opcodes
    - 100 to 200 : extra groups for instructions execution
    - 200 to 300 : flags update (surement pas besoin d'autant)
    - 300 + whatever flags update take to the same plus some tiny constant : main loop
    - 3?? to 10000 : code 

# Extra info : 
    esp is set at 9980 at the very beginning which match the very top of the memory 

# Cpu cycle : 
    Set instruction arguments :
        iid 9995 = source
        iid 9997 = destination

    Copy argument : 
        source :
            source is an immediate : 
                iid 9996 = iid 9995
            source is a register : 
                *(iid 9996) = iid 9995

        destination : 
            destination can only be a register
            *(iid 9998) = iid 9997

    Instructions

    Flags update

    Save output : 
        *(iid 9997) = iid 9999

# Instructions : 
    add : 
        iid 9999 = iid 9998 + iid 9996

    sub/cmp :
        iid 9999 = iid 9998 - iid 9996 


# Flags update :
    zero flag : 
        for all operation test if iid 9991 is equal to 0  

    sign flag : 
        for all operation test if iid 9992 is strictly less than 0 

    overflow flag : 
        add :


        and, test, xor :  
            bitwise operation cannot cause an overflow therefore it sets OF to 0

    carry flag : 
        add : (src < 0 && dst < 0) || (src < 0 && dst >= 0 && src + dst >= 0) || (src >= 0 && dst < 0 && src + dst >= 0)
        on notera que c'est équivalent à (src < 0 && dst < 0) || ((src < 0 && dst >= 0 && || src >= 0 && dst < 0) && src + dst >= 0) 
        qui est lui même équivalent à (src < 0 && dst < 0) || (src * dst < 0 && result >= 0)
        penser à l'inverser celui-là aussi