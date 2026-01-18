This project is still in development !

If you want to see what this project is able to do, here's a [video](https://x.com/Sachagd_/status/1940383595673350393) for you.

As of now, the instruction set is : 

    - addl, subl, cmpl, imull, idivl, cltd 
    - notl, orl, andl, testl, xorl, sall/shll, sarl, shrl
    - jmp, je/jz, jne/jnz, js, jns, jo, jno, jc, jnc, jge/jnl, jnge/jl, jle/jng, jnle/jg
    - movb, movw, movl, lea, push, pop
    - call, ret, halt

Arithmetic operations and bitwise operations on 8bits and 16 bits registers will probably not be implemented

What i'm doing right now : 

    adding a GUI
    finding optimised way to do bitwise operation (if you know a way to do that i'm interested, dm me on discord)
    creating a heap (stopped doing that but will do it eventually)

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
    - 0 to 100 : opcodes : 
        - addl : 1-2
        - subl/cmpl : 3-6
        - imull : 7
        - idivl : 8
        - notl : 9-10
        - orl : 11-12 + 121
        - andl : 13-14 + 119-120
        - testl opti : 15
        - testl : 16-17
        - xorl : 18-19 + 130-132
        - sall/shll : 20 + 124-129
        - sarl : 21
        - shrl : 22
        - movl : 24-25
        - pushl : 26-27
        - popl : 28-29
        - leal : 29 (euh il y a un pb là)
        - jmp : 30
        - je/jz : 31
        - jne/jnz : 32
        - js : 33
        - jns : 34
        - jo : 35
        - jno : 36
        - jc : 37
        - jnc : 38 
        - jge/jnl : 39
        - jnge/jl : 40
        - jle/jng : 41
        - jnle/jg : 42 + 100-101
        - halt : 43
        - ret : 44
        - leave : 45
        - call : 46
        - gd_drawpixel : 47
        - gd_getpixel : 57
        - gd_a : 48
        - gd_w : 49 
        - gd_d : 50
        - gd_left : 51
        - gd_up : 52
        - gd_right : 53
        - gd_wait : 54 + 102 & 124-125
        - gd_randint : 55 + 103-118
        - cltd : 56 + 122-123

    - 160-161 : addl/subl/cmpl OF
    - 162-163 : all ZF
    - 164-165 : all SF
    - 
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
                iid 9996 = *(iid 9995)

        destination : 
            destination can only be a register
            iid 9998 = *(iid 9997)

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