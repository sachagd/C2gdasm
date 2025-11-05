type argument = 
  | Reg1 of string
  | Reg2 of string
  | Reg3 of int * string
  | Reg4 of string * string * int
  | Reg5 of int * string * string * int
  | Imm of int
  | Num of int
  | Str of string
  | Id of string

type instruction = 
  | Addl of argument * argument
  | Subl of argument * argument
  | Cmpl of argument * argument
  | Imull of argument * argument
  | Idivl of argument
  | Cltd
  | Notb of argument * argument
  | Notw of argument * argument
  | Notl of argument * argument
  | Orb of argument * argument
  | Orw of argument * argument
  | Orl of argument * argument
  | Andb of argument * argument
  | Andw of argument * argument
  | Andl of argument * argument
  | Testb of argument * argument
  | Testw of argument * argument
  | Testl of argument * argument
  | Xorb of argument * argument
  | Xorw of argument * argument
  | Xorl of argument * argument
  | Sall of argument * argument
  | Shrl of argument * argument
  | Movb of argument * argument
  | Movw of argument * argument
  | Movl of argument * argument
  | Pushb of argument
  | Pushw of argument
  | Pushl of argument
  | Popb of argument
  | Popw of argument
  | Popl of argument
  | Leal of argument * argument
  | Jmp of argument
  | Je of argument
  | Jz of argument
  | Jne of argument
  | Jnz of argument
  | Js of argument
  | Jns of argument
  | Jo of argument
  | Jno of argument
  | Jc of argument
  | Jnc of argument
  | Jge of argument
  | Jnl of argument
  | Jnge of argument
  | Jl of argument
  | Jle of argument
  | Jng of argument
  | Jnle of argument
  | Jg of  argument
  | Call of argument
  | Ret
  | Leave
  | Nop
  | Dir of string * argument list

type label = 
  | Label of string * instruction list

type func = 
  | Function of string * label list

type program = Program of func list