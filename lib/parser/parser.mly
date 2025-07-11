%{
  open Ast
%}

%token <string> DIRECTIVE 
%token <string> STRING
%token <string> LABEL 
%token <string> REGISTER 
%token <int> IMMEDIATE
%token <int> NUMBER 
%token <string> IDENT
%token <string> FUNCTION
%token ADDB ADDW ADDL SUBB SUBW SUBL CMPB CMPW CMPL CLTD IMULB IMULW IMULL IDIVB IDIVW IDIVL
%token NOTB NOTW NOTL ORB ORW ORL ANDB ANDW ANDL TESTB TESTW TESTL XORB XORW XORL
%token MOVB MOVW MOVL PUSHB PUSHW PUSHL POPB POPW POPL LEAL
%token JMP JE JZ JNE JNZ JS JNS JO JNO JC JNC JGE JNL JNGE JL JLE JNG JNLE JG
%token CALL RET LEAVE
%token COMMA LPAREN RPAREN EOF

%start program
%type <Ast.program> program

%%

argument:
  // there are more possible combination for registers but for now we'll only support these ones
  | REGISTER { Reg1($1) }
  | LPAREN REGISTER RPAREN { Reg2($2) }
  | NUMBER LPAREN REGISTER RPAREN { Reg3($1, $3) }
  | LPAREN REGISTER COMMA REGISTER COMMA NUMBER RPAREN { Reg4($2, $4, $6) }
  | NUMBER LPAREN REGISTER COMMA REGISTER COMMA NUMBER RPAREN { Reg5($1, $3, $5, $7) }
  | IMMEDIATE { Imm($1) }
  | IDENT { Id($1) }

instruction:
  | ADDB argument COMMA argument   { Addb($2, $4) }
  | ADDW argument COMMA argument   { Addw($2, $4) }
  | ADDL argument COMMA argument   { Addl($2, $4) }
  | SUBB argument COMMA argument   { Subb($2, $4) }
  | SUBW argument COMMA argument   { Subw($2, $4) }
  | SUBL argument COMMA argument   { Subl($2, $4) }
  | CMPB argument COMMA argument   { Cmpb($2, $4) }
  | CMPW argument COMMA argument   { Cmpw($2, $4) }
  | CMPL argument COMMA argument   { Cmpl($2, $4) }
  | IMULB argument COMMA argument  { Imulb($2, $4) }
  | IMULW argument COMMA argument  { Imulw($2, $4) }
  | IMULL argument COMMA argument  { Imull($2, $4) }
  | IDIVB argument                { Idivb($2) }
  | IDIVW argument                { Idivw($2) }
  | IDIVL argument                { Idivl($2) }
  | CLTD                          { Cltd }
  | NOTB argument COMMA argument  { Notb($2, $4) }
  | NOTW argument COMMA argument  { Notw($2, $4) }
  | NOTL argument COMMA argument  { Notl($2, $4) }
  | ORB argument COMMA argument  { Orb($2, $4) }
  | ORW argument COMMA argument  { Orw($2, $4) }
  | ORL argument COMMA argument  { Orl($2, $4) }
  | ANDB argument COMMA argument  { Andb($2, $4) }
  | ANDW argument COMMA argument  { Andw($2, $4) }
  | ANDL argument COMMA argument  { Andl($2, $4) }
  | TESTB argument COMMA argument { Testb($2, $4) }
  | TESTW argument COMMA argument { Testw($2, $4) }
  | TESTL argument COMMA argument { Testl($2, $4) }
  | XORB argument COMMA argument  { Xorb($2, $4) }
  | XORW argument COMMA argument  { Xorw($2, $4) }
  | XORL argument COMMA argument  { Xorl($2, $4) }
  | MOVB argument COMMA argument   { Movb($2, $4) }
  | MOVW argument COMMA argument   { Movw($2, $4) }
  | MOVL argument COMMA argument   { Movl($2, $4) }
  | PUSHB argument                { Pushb($2) }
  | PUSHW argument                { Pushw($2) }
  | PUSHL argument                { Pushl($2) }
  | POPB argument                { Popb($2) }
  | POPW argument                { Popw($2) }
  | POPL argument                { Popl($2) }
  | LEAL argument COMMA argument  { Leal($2, $4) }
  | JMP argument        { Jmp($2) }
  | JE argument        { Je($2) }
  | JZ argument        { Jz($2) }
  | JNE argument        { Jne($2) }
  | JNZ argument        { Jnz($2) }
  | JS argument        { Js($2) }
  | JNS argument        { Jns($2) }
  | JO argument        { Jo($2) }
  | JNO argument        { Jno($2) }
  | JC argument        { Jc($2) }
  | JNC argument        { Jnc($2) }
  | JGE argument        { Jge($2) }
  | JNL argument        { Jnl($2) }
  | JNGE argument        { Jnge($2) }
  | JL argument        { Jl($2) }
  | JLE argument        { Jle($2) }
  | JNG argument        { Jng($2) }
  | JNLE argument        { Jnle($2) }
  | JG argument        { Jg($2) }
  | CALL argument                 { Call($2) }
  | RET                           { Ret }
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