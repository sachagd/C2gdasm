type argument = 
  | Reg1 of string
  | Reg2 of string
  | Reg3 of int * string 
  | Reg4 of int * string * string * int
  | Imm of int
  | Num of int
  | Str of string
  | Id of string 

type instruction = 
  | Addb of argument * argument
  | Addw of argument * argument
  | Addl of argument * argument
  | Subb of argument * argument
  | Subw of argument * argument
  | Subl of argument * argument
  | Cmpb of argument * argument
  | Cmpw of argument * argument
  | Cmpl of argument * argument
  | Cltd
  | Idivl of argument
  | Andb of argument * argument
  | Andw of argument * argument
  | Andl of argument * argument
  | Testb of argument * argument
  | Testw of argument * argument
  | Testl of argument * argument
  | Xorb of argument * argument
  | Xorw of argument * argument
  | Xorl of argument * argument
  | Pushl of argument
  | Movb of argument * argument
  | Movw of argument * argument
  | Movl of argument * argument
  | Jmp of argument
  | Jl of argument
  | Jnl of argument
  | Jle of argument
  | Jnle of argument
  | Je of argument
  | Jne of argument
  | Jo of argument
  | Jno of argument
  | Js of argument
  | Jns of argument
  | Jz of argument
  | Jnz of argument
  | Jg of  argument
  | Jng of argument
  | Jge of argument
  | Jnge of argument
  | Call of argument
  | Ret
  | Leave
  | Dir of string * argument list

type label = 
  | Label of string * instruction list

type func = 
  | Function of string * label list

type program = Program of func list