open Ast

let firstinstrgroup = 299

let rec finstructionf instructions acc =
  match instructions with 
  |[] -> acc
  |(Nop)::t -> finstructionf t acc
  |_::t -> finstructionf t (acc + 1)

let flabelf label_references program_counter label =
  match label with
  |Label(name, instructions) ->
    Hashtbl.add label_references (String.sub name 0 (String.length name - 1)) !program_counter;
    program_counter := !program_counter + finstructionf instructions 0

let rec ffunctionf functions label_references program_counter =
  match functions with 
  |[] -> ()
  |Function(name, labels)::t ->
    if name = "main:" then 
      begin
      List.iter (flabelf label_references program_counter) labels;
      ffunctionf t label_references program_counter;
      end
    else 
      begin
      ffunctionf t label_references program_counter;
      List.iter (flabelf label_references program_counter) labels;
      end

let fprogramf (Program(functions)) = 
  let program_counter = ref 0 in 
  let label_references = Hashtbl.create 0 in
  ffunctionf functions label_references program_counter;
  label_references 

let get_register reg = 
  match reg with 
  |"%eax" -> 9983
  |"%ebx" -> 9984
  |"%ecx" -> 9985
  |"%edx" -> 9986
  |"%esi" -> 9987
  |"%edi" -> 9988
  |"%ebp" -> 9989
  |"%esp" -> 9990
  | _ -> failwith "unknown register"

let argumentf argument insts argoffset = 
  match argument with
  |Imm(imm) -> insts := [|100; 9995 + argoffset; imm|]::!insts
  |Reg1(reg) -> insts := [|100; 9995 + argoffset; get_register reg|]::!insts
  |Reg2(reg) -> insts := [|101; 9995 + argoffset; get_register reg|]::!insts
  |Reg3(offset, reg) -> insts := [|101; 9995 + argoffset; get_register reg|]::[|102; 9995 + argoffset; offset / 4|]::!insts
  |Reg4(base, index) -> insts := [|101; 9995 + argoffset; get_register index|]::[|103; 9995 + argoffset; get_register base|]::!insts
  |Reg5(offset, index, scale) ->  insts := [|101; 9995 + argoffset; get_register index|]::[|104; 9995 + argoffset; scale / 4|]::[|102; 9995 + argoffset; offset / 4|]::!insts
  |Reg6(base, index, scale) -> insts := [|101; 9995 + argoffset; get_register index|]::[|104; 9995 + argoffset; scale / 4|]::[|103; 9995 + argoffset; get_register base|]::!insts
  |Reg7(offset, base, index, scale) -> insts := [|101; 9995 + argoffset; get_register index|]::[|104; 9995 + argoffset; scale / 4|]::[|103; 9995 + argoffset; get_register base|]::[|102; 9995 + argoffset; offset / 4|]::!insts
  | _ -> failwith "invalid argument in argumentf"

let inst_type arg = 
  match arg with
  |Imm(_) -> 0
  |Reg1(_) |Reg2(_) |Reg3(_, _) |Reg4(_, _) |Reg5(_, _, _) |Reg6(_, _, _) |Reg7(_, _, _, _) -> 1
  | _ -> failwith "invalid argument in inst_type"

let twoarg_instruction src dst code insts base = 
    insts := [|base + inst_type src|]::!insts;
    argumentf dst insts 2;
    argumentf src insts 0;
    code := !insts::!code

let get_label target label_references = 
  match target with 
  |Id(label) -> Hashtbl.find label_references label
  | _ -> failwith "invalid target"

let opcall op =
  match op with
  |"gd_draw_pixel_simplified" -> 0
  |"gd_a_pressed" -> 1
  |"gd_w_pressed" -> 2
  |"gd_d_pressed" -> 3
  |"gd_left_pressed" -> 4
  |"gd_up_pressed" -> 5
  |"gd_right_pressed" -> 6
  |"gd_waitnextframe" -> 7
  |"gd_randint" -> 8
  |"malloc" -> 100
  |"free" -> 101
  |_ -> failwith "invalid function call"

let rec power n acc =
  if n = 0 then acc
  else power (n - 1) (acc * 2)

let sinstructionf code label_references is_main instruction = 
  let insts = ref [] in 
  match instruction with 
  |Addl(Imm(imm), Reg1("%esp")) -> code := [[|100; 9995; imm / 4|]; [|100; 9997; 9990|]; [|1|]]::!code 
  |Addl(src, dst) -> twoarg_instruction src dst code insts 1
  
  |Subl(Imm(imm), Reg1("%esp")) -> code := [[|100; 9995; imm / 4|]; [|100; 9997; 9990|]; [|3|]]::!code
  |Subl(src, dst) -> twoarg_instruction src dst code insts 3
  |Cmpl(src, dst) -> twoarg_instruction src dst code insts 5

  |Imull(src, dst) -> 
    insts := [|7|]::!insts;
    argumentf dst insts 2;
    argumentf src insts 0;
    code := !insts::!code

  |Idivl(op) ->
    insts := [|8|]::!insts;
    argumentf op insts 0;
    code := !insts::!code;

  |Notl(src, dst) -> twoarg_instruction src dst code insts 9
  |Orl(src, dst) -> twoarg_instruction src dst code insts 11
  |Andl(src, dst) -> twoarg_instruction src dst code insts 13
  |Testl(Reg1(r1),Reg1(r2)) when r1 = r2 -> code := [[|100; 9995; get_register r1|]; [|15|]]::!code 
  |Testl(op1, op2) -> twoarg_instruction op1 op2 code insts 16
  |Xorl(src, dst)  -> twoarg_instruction src dst code insts 18

  |Sall(Imm(count), dst) -> twoarg_instruction (Imm(power count 1)) dst code insts 20
  |Shrl(Imm(count), dst) -> twoarg_instruction (Imm(power count 1)) dst code insts 22

  |Cltd -> code := [[|56|]]::!code (* changer le 56 plus tard*)

  |Movl(src, dst) -> twoarg_instruction src dst code insts 24

  |Pushl(op) ->
    insts := [|26 + inst_type op|]::!insts; 
    argumentf op insts 0;
    code := !insts::!code
  
  |Popl(op) ->
    insts := [|28 + inst_type op|]::!insts;
    argumentf op insts 0;
    code := !insts::!code

  |Leal(src, dst) ->
    insts := [|29|]::!insts;
    argumentf dst insts 2;
    argumentf src insts 0;
    code := !insts::!code

  |Jmp(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|30|]]::!code;

  |Je(target) |Jz(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|31|]]::!code;
  |Jne(target) |Jnz(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|32|]]::!code;

  |Js(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|33|]]::!code;
  |Jns(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|34|]]::!code;

  |Jo(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|35|]]::!code;
  |Jno(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|36|]]::!code;

  |Jc(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|37|]]::!code;
  |Jnc(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|38|]]::!code;

  |Jge(target) |Jnl(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|39|]]::!code;
  |Jnge(target) |Jl(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|40|]]::!code;

  |Jle(target) |Jng(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|41|]]::!code;
  |Jnle(target) |Jg(target) -> code := [[|100; 9995; firstinstrgroup + get_label target label_references|]; [|42|]]::!code;

  |Ret -> if is_main then code := [[|43|]]::!code else code := [[|44|]]::!code

  |Leave -> code := [[|45|]]::!code
  
  |Nop -> ()

  |Call(target) ->
    (match target with 
    |Id(label) -> 
      if Hashtbl.mem label_references label then 
        code := [[|100; 9995; firstinstrgroup + Hashtbl.find label_references label|]; [|46|]]::!code
      else
        code := [[|47 + opcall label|]]::!code
    | _ -> failwith "invalid target")

  | _ -> failwith "invalid instruction in si"

let slabelf label_references code is_main label =
  match label with
  |Label(_, instructions) ->
    List.iter (sinstructionf code label_references is_main) instructions

let rec sfunctionf functions label_references code =
  match functions with 
  |[] -> ()
  |Function(name, labels)::t ->
    if name = "main:" then 
      begin
      List.iter (slabelf label_references code true) labels;
      sfunctionf t label_references code;
      end 
    else 
      begin     
      sfunctionf t label_references code;
      List.iter (slabelf label_references code false) labels;
      end

let sprogramf (Program(functions)) label_references = 
  let code = ref [] in
  sfunctionf functions label_references code;
  !code

let json_of_int_arr_list_list xs =
  `List (
    List.map
      (fun inner ->
         `List (
           List.map
             (fun arr ->
                `List (Array.to_list arr |> List.map (fun i -> `Int i))
             )
             inner
         )
      )
      xs
  )

open Printf

let string_of_argument = function
  | Reg1 r -> sprintf "Reg1(%s)" r
  | Reg2 r -> sprintf "Reg2(%s)" r
  | Reg3 (n, r) -> sprintf "Reg3(%d, %s)" n r
  | Reg4 (r1, r2) -> sprintf "Reg4(%s, %s)" r1 r2
  | Reg5 (n, r, s) -> sprintf "Reg5(%d, %s, %d)" n r s
  | Reg6 (r1, r2, s) -> sprintf "Reg6(%s, %s, %d)" r1 r2 s
  | Reg7 (n, r1, r2, s) -> sprintf "Reg7(%d, %s, %s, %d)" n r1 r2 s
  | Imm n -> sprintf "Imm(%d)" n
  | Num n -> sprintf "Num(%d)" n
  | Str s -> sprintf "Str(%S)" s
  | Id s -> sprintf "Id(%s)" s

let string_of_instruction = function
  | Addl(a,b) -> sprintf "Addl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Subl(a,b) -> sprintf "Subl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Cmpl(a,b) -> sprintf "Cmpl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Imull(a,b) -> sprintf "Imull(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Idivl(a) -> sprintf "Idivl(%s)" (string_of_argument a)
  | Cltd -> "Cltd"
  | Notb(a,b) -> sprintf "Notb(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Notw(a,b) -> sprintf "Notw(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Notl(a,b) -> sprintf "Notl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Orb(a,b) -> sprintf "Orb(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Orw(a,b) -> sprintf "Orw(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Orl(a,b) -> sprintf "Orl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Andb(a,b) -> sprintf "Andb(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Andw(a,b) -> sprintf "Andw(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Andl(a,b) -> sprintf "Andl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Testb(a,b) -> sprintf "Testb(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Testw(a,b) -> sprintf "Testw(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Testl(a,b) -> sprintf "Testl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Xorb(a,b) -> sprintf "Xorb(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Xorw(a,b) -> sprintf "Xorw(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Xorl(a,b) -> sprintf "Xorl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Sall(a,b) -> sprintf "Sall(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Shrl(a,b) -> sprintf "Shrl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Movb(a,b) -> sprintf "Movb(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Movw(a,b) -> sprintf "Movw(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Movl(a,b) -> sprintf "Movl(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Pushb(a) -> sprintf "Pushb(%s)" (string_of_argument a)
  | Pushw(a) -> sprintf "Pushw(%s)" (string_of_argument a)
  | Pushl(a) -> sprintf "Pushl(%s)" (string_of_argument a)
  | Popb(a) -> sprintf "Popb(%s)" (string_of_argument a)
  | Popw(a) -> sprintf "Popw(%s)" (string_of_argument a)
  | Popl(a) -> sprintf "Popl(%s)" (string_of_argument a)
  | Leal(a,b) -> sprintf "Leal(%s, %s)" (string_of_argument a) (string_of_argument b)
  | Jmp(a) -> sprintf "Jmp(%s)" (string_of_argument a)
  | Je(a) -> sprintf "Je(%s)" (string_of_argument a)
  | Jz(a) -> sprintf "Jz(%s)" (string_of_argument a)
  | Jne(a) -> sprintf "Jne(%s)" (string_of_argument a)
  | Jnz(a) -> sprintf "Jnz(%s)" (string_of_argument a)
  | Js(a) -> sprintf "Js(%s)" (string_of_argument a)
  | Jns(a) -> sprintf "Jns(%s)" (string_of_argument a)
  | Jo(a) -> sprintf "Jo(%s)" (string_of_argument a)
  | Jno(a) -> sprintf "Jno(%s)" (string_of_argument a)
  | Jc(a) -> sprintf "Jc(%s)" (string_of_argument a)
  | Jnc(a) -> sprintf "Jnc(%s)" (string_of_argument a)
  | Jge(a) -> sprintf "Jge(%s)" (string_of_argument a)
  | Jnl(a) -> sprintf "Jnl(%s)" (string_of_argument a)
  | Jnge(a) -> sprintf "Jnge(%s)" (string_of_argument a)
  | Jl(a) -> sprintf "Jl(%s)" (string_of_argument a)
  | Jle(a) -> sprintf "Jle(%s)" (string_of_argument a)
  | Jng(a) -> sprintf "Jng(%s)" (string_of_argument a)
  | Jnle(a) -> sprintf "Jnle(%s)" (string_of_argument a)
  | Jg(a) -> sprintf "Jg(%s)" (string_of_argument a)
  | Call(a) -> sprintf "Call(%s)" (string_of_argument a)
  | Ret -> "Ret"
  | Leave -> "Leave"
  | Nop -> "Nop"
  | Dir(name, args) ->
      let args_str = String.concat ", " (List.map string_of_argument args) in
      sprintf "Dir(%s, [%s])" name args_str

let string_of_label (Label (name, instrs)) =
  sprintf "Label %s:\n%s"
    name
    (String.concat "\n" (List.map (fun i -> "  " ^ string_of_instruction i) instrs))

let string_of_func (Function (name, labels)) =
  sprintf "Function %s:\n%s"
    name
    (String.concat "\n" (List.map string_of_label labels))

let string_of_program (Program funcs) =
  String.concat "\n\n" (List.map string_of_func funcs)

let print_program prog =
  print_endline (string_of_program prog)


let () =
  let filename = "snake.s" in
  let channel = open_in filename in
  let lexbuf = Lexing.from_channel channel in
  let ast = Parser.program Lexer.token lexbuf in
  close_in channel;
  let label_references = fprogramf ast in
  Hashtbl.iter (fun s i -> print_string s; print_string " "; print_int i; print_newline ()) label_references;
  let code = List.rev (sprogramf ast label_references) in
  let oc = open_out "code.json" in
  Yojson.Basic.pretty_to_channel
    oc
    (json_of_int_arr_list_list code);
  close_out oc  


(* let () =
  let channel = open_in "snake.s" in
  let lexbuf = Lexing.from_channel channel in
  let ast = Parser.program Lexer.token lexbuf in
  close_in channel;
  print_program ast *)