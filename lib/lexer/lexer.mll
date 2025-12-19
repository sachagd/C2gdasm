{
open Parser
exception Lexing_error of string
}

let not_separator = [^' ' '\t' '\n' ',' '(' ')']
let digit = ['0'-'9']

rule token = parse
  | [' ' '\t' '\r' '\n']+          { token lexbuf }
  | '#' [^ '\n']* '\n'             { token lexbuf }
  | ".file" [^ '\n']* '\n'        { token lexbuf }
  | ".text" [^ '\n']* '\n'        { token lexbuf }
  | ".globl" [^ '\n']* '\n'       { token lexbuf }
  | ".type" [^ '\n']* '\n'        { token lexbuf }
  | ".size" [^ '\n']* '\n'        { token lexbuf }
  | ".section" [^ '\n']* '\n'     { token lexbuf }
  | ".note.GNU-stack" [^ '\n']* '\n' { token lexbuf }
  | not_separator+ ":" as s        { if s.[0] = '.' then LABEL s else FUNCTION s}
  | "%" not_separator+ as r        { REGISTER r }
  | "$" ['-']? digit+ as s         { IMMEDIATE (int_of_string (String.sub s 1 (String.length s - 1))) }
  | ['-']? ['0'-'9']+ as num       { NUMBER (int_of_string num) }

  | "addl"       { ADDL }
  | "subl"       { SUBL }
  | "cmpl"       { CMPL }
  | "imull"      { IMULL }
  | "idivl"      { IDIVL }
  | "cltd"       { CLTD }
  | "notb"       { NOTB }
  | "notw"       { NOTW }
  | "notl"       { NOTL }
  | "orb"        { ORB }
  | "orw"        { ORW }
  | "orl"        { ORL }
  | "andb"       { ANDB }
  | "andw"       { ANDW }
  | "andl"       { ANDL }
  | "testb"      { TESTB }
  | "testw"      { TESTW }
  | "testl"      { TESTL }
  | "xorb"       { XORB }
  | "xorw"       { XORW }
  | "xorl"       { XORL }
  | "sall"       { SALL }
  | "shrl"       { SHRL }
  | "movb"       { MOVB }
  | "movw"       { MOVW }
  | "movl"       { MOVL }
  | "pushb"      { PUSHB }
  | "pushw"      { PUSHW }
  | "pushl"      { PUSHL }
  | "popb"       { POPB }
  | "popw"       { POPW }
  | "popl"       { POPL }
  | "leal"       { LEAL }
  | "jmp"        { JMP }
  | "je"         { JE }
  | "jz"         { JZ }
  | "jne"        { JNE }
  | "jnz"        { JNZ }
  | "js"         { JS }
  | "jns"        { JNS }
  | "jo"         { JO }
  | "jno"        { JNO }
  | "jc"         { JC }
  | "jnc"        { JNC }
  | "jge"        { JGE }
  | "jnl"        { JNL }
  | "jnge"       { JNGE }
  | "jl"         { JL }
  | "jle"        { JLE }
  | "jng"        { JNG }
  | "jnle"       { JNLE }
  | "jg"         { JG }
  | "call"       { CALL }
  | "ret"        { RET }
  | "leave"      { LEAVE }
  | "nop"        { token lexbuf }

  | ","                             { COMMA }
  | "("                             { LPAREN }
  | ")"                             { RPAREN }

  | not_separator+ as id            { IDENT id }

  | eof                             { EOF }
  | _ as c                          { raise (Lexing_error ("Unexpected character: " ^ (String.make 1 c))) }
