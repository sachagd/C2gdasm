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

  | "addl"       { ADDL }
  | "pushl"      { PUSHL }
  | "movb"       { MOVB }
  | "movl"       { MOVL }
  | "andl"       { ANDL }
  | "subl"       { SUBL }
  | "call"       { CALL }
  | "jmp"        { JMP }
  | "jne"        { JNE }
  | "je"         { JE }
  | "jl"         { JL }
  | "jle"        { JLE }
  | "cmpb"       { CMPB }
  | "cmpl"       { CMPL }
  | "cltd"       { CLTD }
  | "idivl"      { IDIVL }
  | "ret"        { RET }
  | "xorl"       { XORL }
  | "testl"      { TESTL }
  | "leave"      { LEAVE }

  | ","                             { COMMA }
  | "("                             { LPAREN }
  | ")"                             { RPAREN }

  | not_separator+ as id            { IDENT id }

  | eof                             { EOF }
  | _ as c                          { raise (Lexing_error ("Unexpected character: " ^ (String.make 1 c))) }
