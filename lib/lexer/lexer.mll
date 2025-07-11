{
  
open Parser
exception Lexing_error of string
}

let not_separator = [^' ' '\t' '\n' ',' '(' ')']
let digit = ['0'-'9']

rule token = parse
  | [' ' '\t' '\r' '\n']+           { token lexbuf }
  | "." (['a'-'z' '_'])+ as d       { DIRECTIVE d }
  | "." not_separator+ ":" as l     { LABEL l }
  | not_separator+ ":" as f         { FUNCTION f } 
  | "%" not_separator+ as r         { REGISTER r }
  | "\"" ([^'"'])* "\"" as s        { STRING s }
  | "$" digit+ as s                 { IMMEDIATE (int_of_string (String.sub s 1 (String.length s - 1))) }
  | ['-']? ['0'-'9']+ as num        { NUMBER (int_of_string num) }

  | "addb"       { ADDB }
  | "addw"       { ADDW }
  | "addl"       { ADDL }
  | "subb"       { SUBB }
  | "subw"       { SUBW }
  | "subl"       { SUBL }
  | "cmpb"       { CMPB }
  | "cmpw"       { CMPW }
  | "cmpl"       { CMPL }
  | "imulb"      { IMULB }
  | "imulw"      { IMULW }
  | "imull"      { IMULL }
  | "idivb"      { IDIVB }
  | "idivw"      { IDIVW }
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

  | ","                             { COMMA }
  | "("                             { LPAREN }
  | ")"                             { RPAREN }

  | not_separator+ as id            { IDENT id }

  | eof                             { EOF }
  | _ as c                          { raise (Lexing_error ("Unexpected character: " ^ (String.make 1 c))) }
