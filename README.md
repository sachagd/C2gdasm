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
    1 - 4001 : screen memory buffer

    9972 : hardforce gd_waitnextframe
    9973 : global timer
    9974 - 9979 : input buffer (w a d left up right)
    9980 - 9981 : temp mem
    9982 : program counter
    9983 - 9990 : %eax, %ebx, %ecx, %edx, %esi, %edi, %ebp, %esp
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
    - sarl : 21 + 137-140
    - shrl : 22 + 130-136
    - movl : 24-25
    - pushl : 26-27
    - popl : 28-29
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
    - cltd : 46 + 122-123
    - leal : 47

    - call : 80
    - gd_drawpixel : 81
    - gd_getpixel : 82
    - gd_a : 83
    - gd_w : 84 
    - gd_d : 85
    - gd_left : 86
    - gd_up : 87
    - gd_right : 88
    - gd_wait : 89 + 102 & 141-142
    - gd_randint : 90 + 103-118

    - ZF (all) : 160-161 //donner la liste exacte des ops
    - SF (all) : 162-163 //donner la liste exacte des ops
    - OF (addl, subl, cmpl, sall/shll, sarl, shrl, andl, orl, xorl, testl) : 164-174

    - BIOS : 200-204
    - screen refresh : 205-205 + len(palette) -> max 75 colors

    - input pooling : 280-297

    - code : 300-9999 

# Extra info : 
    esp is set at 9971 at the very beginning which match the very top of the memory 

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
    
    wait : 
        if i9973 != 0 then //we want to wait 
            i9972 = 1 //we register being in the waiting state
            i9982 = i9982 - 1 //we wait
        else //we don't want to wait anymore
            if i9972 = 0 then //we are already out of the waiting state meaning computation was very quick
                i9982 = i9982 - 1 //we wait
            i9972 = 0 //we are out of the waiting state

    sarl : 
        i9996 contains 2^shift if shift < 31 else -1 because iids cannot hold 2^31

        if i9996 == -1 then //if shift = 31
            if i9998 < 0 then 
                i9999 = -1 //a 31 bits signed right shift on a negative integer always equal -1
            else 
                i9999 = 0 //a 31 bits signed right shift on a positive integer always equal 0 
        else //if shift != 31
            i9999 = flr(i9998 / i9996) //perform regular signed right shift

    sall/shll : 
        toggle g124 //toggle all spawn trigger
        i9999 = i9998
        i9980 = i9996 //for OF computation
        g124 () = //one shift
            if i9996 > 0 then //if we still need to shift 
                if abs(i9999 / 32768) <= 32768 then //if the shift won't cause an overflow
                    i9999 = i9999 + i9999 // do the shift
                else 
                    i9999 = i9999 + -2147483648 //put the value back in the range where the shift won't cause an overflow
                    i9999 = i9999 + i9999 //do the shift, note that -2147483648 * 2 ≡ 0 [2^32] so the computation is correct
                i9996 = i9996 + -1 //we did the shift
            else //all shift done
                untoggle g124 //untoggle all other spawn trigger

    shrl : 
        i9996 contains 2^shift if shift < 31 else -1 because iids cannot hold 2^31

        i9980 = i9998 //for OF computation
        if i9996 != -1 then //if shift != 31
            i9999 = flr(i9998 / i9996) //do signed right shift only work for positive integers
            if i9998 < 0 then //else the following math adjust the result (it's not trivial but easily provable)
                if 9996 != 2 then 
                    i9998 = -2147482648
                    i9998 = flr(i9998 / i9996)
                    i9999 = i9999 + i9998 * -2
                else
                    i9999 = i9999 + -2147483648
        else //if shift = 31
            if i9998 < 0 then 
                i9999 = 1 //a 31 bits unsigned right shift on a negative integer always equal 1
            else 
                i9999 = 0 //a 31 bits unsigned right shift on a negative integer always equal 0

    cltd: 
        if i9983 >= 0 then 
            i9986 = 0
        else 
            i9986 = -1


# Flags update :
    zero flag (ZF) : 
        all ops :  
            if i9999 = 0 then
                i9991 = 1
            else 
                i9991 = 0   

    sign flag (SF) : 
        all ops : 
            if i9999 < 0 then 
                i9992 = 1
            else
                i9992 = 0

    overflow flag (OF) : 
        add :


        and, test, xor :  
            bitwise operation cannot cause an overflow therefore it sets OF to 0
        
        sarl :
            if i9996 = 2 then
                i9993 = 0

        sall/shll:
            i9980 = i9996 //for OF computation

            if i9980 = 1 then 
                i9993 = 0
                if i9999 < 0 then
                    if i9998 > -1 then
                        i9993 = 1
                if i9999 > -1 then 
                    if i9998 < 0 then 
                        i9993 = 1
        
        shrl :
            i9980 = i9998 //for OF computation

            if i9996 = 2 then 
                if i9980 < 0 then
                    i9993 = 1
                else 
                    i9993 = 0

    carry flag : 
        add : (src < 0 && dst < 0) || (src < 0 && dst >= 0 && src + dst >= 0) || (src >= 0 && dst < 0 && src + dst >= 0)
        on notera que c'est équivalent à (src < 0 && dst < 0) || ((src < 0 && dst >= 0 && || src >= 0 && dst < 0) && src + dst >= 0) 
        qui est lui même équivalent à (src < 0 && dst < 0) || (src * dst < 0 && result >= 0)
        penser à l'inverser celui-là aussi