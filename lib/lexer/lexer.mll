{
(* Header code *)
open Parser

exception Lexing_error of string
}

let not_separator = [^' ' '\t' '\n' ',' '(' ')']

rule token = parse
  | [' ' '\t' '\r' '\n']+           { token lexbuf }
  | "." (['a'-'z' '_'])+ as d       { DIRECTIVE d }
  | "." not_separator+ ":" as l     { LABEL l }
  | not_separator+ ":" as f         { FUNCTION f } 
  | "%" not_separator+ as r         { REGISTER r }
  | "\"" ([^'"'])* "\"" as s        { STRING s }
  (* | "$" digit+ as s { IMMEDIATE (int_of_string (String.sub s 1 (String.length s - 1))) } *)
  | "$" not_separator+ as s         { IMMEDIATE s }
  | ['-']? ['0'-'9']+ as num        { NUMBER (int_of_string num) }

  | "addb"       { ADD }
  | "addw"       { ADD }
  | "addl"       { ADD }
  | "subb"       { SUB }
  | "subw"       { SUB }
  | "subl"       { SUB }
  | "cmpb"       { CMP }
  | "cmpw"       { CMP }
  | "cmpl"       { CMP }
  | "cltd"       { CLTD }
  | "idivl"      { IDIVL }
  | "andb"       { ANDB }
  | "andw"       { ANDW }
  | "andl"       { ANDL }
  | "testb"      { TESTB }
  | "testw"      { TESTW }
  | "testl"      { TESTL }
  | "xorb"       { XORB }
  | "xorw"       { XORW }
  | "xorl"       { XORL }
  | "pushl"      { PUSHL }
  | "movb"       { MOV }
  | "movw"       { MOV }
  | "movl"       { MOV }
  | "jmp"        { JMP }
  | "jl"         { JL }
  | "jnl"        { JNL }
  | "jle"        { JLE }
  | "jnle"       { JNLE }
  | "je"         { JE }
  | "jne"        { JNE }
  | "jo"         { JO }
  | "jno"        { JNO }
  | "js"         { JS }
  | "jns"        { JNS }
  | "jz"         { JZ }
  | "jnz"        { JNZ }
  | "jg"         { JG }
  | "jng"        { JNG }
  | "jge"        { JGE }
  | "jnge"       { JNGE }
  | "call"       { CALL }
  | "ret"        { RET }
  | "leave"      { LEAVE }

  | ","                             { COMMA }
  | "("                             { LPAREN }
  | ")"                             { RPAREN }

  | not_separator+ as id            { IDENT id }

  | eof                             { EOF }
  | _ as c                          { raise (Lexing_error ("Unexpected character: " ^ (String.make 1 c))) }
