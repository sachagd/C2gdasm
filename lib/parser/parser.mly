%{
  open Ast
%}

%token <string> DIRECTIVE 
%token <string> STRING
%token <string> LABEL 
%token <string> REGISTER 
%token <string> IMMEDIATE  (* c'était un int avant *)
%token <int> NUMBER 
%token <string> IDENT
%token <string> FUNCTION
%token ADDL PUSHL MOVL ANDL SUBL CALL JMP CMPB CLTD IDIVL RET
%token XORL MOVB TESTL JNE CMPL JL JE JLE LEAVE
%token COMMA LPAREN RPAREN EOF

%start program
%type <Ast.program> program

%%

argument:
  // there are more possible combination for registers but for now we'll only support these ones
  | REGISTER { Reg1($1) }
  | LPAREN REGISTER RPAREN { Reg2($2) }
  | NUMBER LPAREN REGISTER RPAREN { Reg3($1, $3) }
  | NUMBER LPAREN REGISTER COMMA REGISTER COMMA NUMBER RPAREN { Reg4($1, $3, $5, $7) }
  | IMMEDIATE { Imm($1) }
  | IDENT { Id($1) }

instruction:
  | ADDL argument COMMA argument  { Addl($2, $4) }
  | PUSHL argument                { Pushl($2) }
  | MOVB argument COMMA argument  { Movb($2, $4) }
  | MOVL argument COMMA argument  { Movl($2, $4) }
  | ANDL argument COMMA argument  { Andl($2, $4) }
  | SUBL argument COMMA argument  { Subl($2, $4) }
  | CALL argument                 { Call($2) }
  | JMP argument                  { Jmp($2) }
  | JNE argument                  { Jne($2) }
  | JE argument                   { Je($2) }
  | JL argument                   { Jl($2) }
  | JLE argument                  { Jle($2) }
  | CMPB argument COMMA argument  { Cmpb($2, $4) }
  | CMPL argument COMMA argument  { Cmpl($2, $4) }
  | CLTD                          { Cltd }
  | IDIVL argument                { Idivl($2) }
  | RET                           { Ret }
  | XORL argument COMMA argument  { Xorl($2, $4) }
  | TESTL argument COMMA argument { Testl($2, $4) }
  | LEAVE                         { Leave }

dirarg:
  | IDENT { Id($1) }
  | STRING { Str($1) }
  | NUMBER { Num($1) }

dirargs:
  | dirarg COMMA dirargs { $1 :: $3 }
  | dirarg dirargs { $1 :: $2 }
  | dirarg { [$1] }
  | { [] }

directives:
  | DIRECTIVE dirargs directives { Dir($1, $2) :: $3 }
  | DIRECTIVE dirargs { [Dir($1, $2)] }

instructions:
  | directives instructions { $2 }
  | instruction instructions { $1 :: $2 } 
  | instruction { [$1] }
  | { [] }

label: 
  | LABEL instructions { Label ($1, $2) }

labels:
  | label labels { $1 :: $2 }
  | label { [$1] }
  | { [] }

func:
  | FUNCTION instructions labels { Function ($1, Label ($1, $2) :: $3) }

functions:
  | func functions { $1 :: $2 }
  | func { [$1] }

program:
  | directives functions EOF { Program $2 }