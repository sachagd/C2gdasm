This project is still in development !

If you want to see what this project is able to do, here's a [video](https://x.com/Sachagd_/status/1929201772364550402) for you. You can see the first prime numbers being computed and stored in an array from top to bottom.

As of now, the instruction set is : 

    - add, sub, cmp, idiv 
    - jmp, je, jne, jl, jle
    - mov
    - cltd
    - call, ret

What i'm doing right now : 
    creating distinct opcode based on the operation size (add -> addb, addw, addl)
    finding optimised way to do bitwise operation (if you know a way to do that i'm interested, dm me on discord)
    a bunch of jump instruction