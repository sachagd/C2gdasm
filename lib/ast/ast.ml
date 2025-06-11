type argument = 
  | Reg1 of string
  | Reg2 of string
  | Reg3 of int * string 
  | Reg4 of int * string * string * int
  | Imm of string
  | Num of int
  | Str of string
  | Id of string 

type instruction = 
  | Testl of argument * argument
  | Andl of argument * argument
  | Xorl of argument * argument
  | Addl of argument * argument
  | Subl of argument * argument
  | Cmpb of argument * argument
  | Cmpl of argument * argument
  | Idivl of argument
  | Cltd
  | Movb of argument * argument
  | Movl of argument * argument
  | Pushl of argument
  | Jmp of argument
  | Jl of argument
  | Jle of argument
  | Je of argument
  | Jne of argument
  | Jo of argument
  | Jno of argument
  | Leave
  | Call of argument
  | Ret
  | Dir of string * argument list

type label = 
  | Label of string * instruction list

type func = 
  | Function of string * label list

type program = Program of func list