open Ast

let rec finstructionf instructions acc =
  match instructions with 
  |[] -> acc
  |(Cltd|Nop)::t -> finstructionf t acc
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

let argumentf argument insts argoffset divf = 
  match argument with
  |Imm(imm) -> insts := [|100; 9995 + argoffset; imm|]::!insts
  |Reg1(reg) -> insts := [|100; 9995 + argoffset; get_register reg|]::!insts
  |Reg2(reg) -> insts := [|101; 9995 + argoffset; get_register reg|]::!insts
  |Reg3(offset, reg) -> insts := [|101; 9995 + argoffset; get_register reg|]::[|102; 9995 + argoffset; offset / divf|]::!insts
  |Reg4(base, index, scale) -> insts := [|101; 9995 + argoffset; get_register index|]::[|104; 9995 + argoffset; scale / divf|]::[|103; 9995 + argoffset; get_register base|]::!insts
  |Reg5(offset, base, index, scale) -> insts := [|101; 9995 + argoffset; get_register index|]::[|104; 9995 + argoffset; scale / divf|]::[|103; 9995 + argoffset; get_register base|]::[|102; 9995 + argoffset; offset / divf|]::!insts
  | _ -> failwith "invalid argument"

let inst_type arg = 
  match arg with
  |Imm(_) -> 0
  |Reg1(_) |Reg2(_) |Reg3(_, _) |Reg4(_, _, _) |Reg5(_, _, _, _) -> 1
  | _ -> failwith "invalid argument"

let twoarg_instruction src dst code insts base divf = 
    insts := [|base + inst_type src|]::!insts;
    argumentf dst insts 2 divf;
    argumentf src insts 0 divf;
    code := !insts::!code

let get_label target label_references = 
  match target with 
  |Id(label) -> Hashtbl.find label_references label
  | _ -> failwith "invalid target"

let opcall op =
  match op with
  |"gd_putpixel_simplified" -> 0
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

let sinstructionf code label_references is_main instruction = 
  let insts = ref [] in 
  match instruction with 
  |Addl(Imm(imm), Reg1("%esp")) -> code := [[|100; 9995; imm / 4|]; [|100; 9997; 9990|]; [|1|]]::!code 
  |Addl(src, dst) -> twoarg_instruction src dst code insts 1 4
  
  |Subl(Imm(imm), Reg1("%esp")) -> code := [[|100; 9995; imm / 4|]; [|100; 9997; 9990|]; [|3|]]::!code
  |Subl(src, dst) -> twoarg_instruction src dst code insts 3 4
  |Cmpl(src, dst) -> twoarg_instruction src dst code insts 5 4

  |Imull(src, dst) -> 
    insts := [|7|]::!insts;
    argumentf dst insts 2 4;
    argumentf src insts 0 4;
    code := !insts::!code

  |Idivl(op) ->
    insts := [|8|]::!insts;
    argumentf op insts 0 4;
    code := !insts::!code;

  |Cltd -> ()

  |Notl(src, dst) -> twoarg_instruction src dst code insts 9 4 (*choisir opcode*)
  |Orl(src, dst) -> twoarg_instruction src dst code insts 11 4 (*choisir opcode*)
  |Andl(src, dst) -> twoarg_instruction src dst code insts 13 4
  |Testl(Reg1(r1),Reg1(r2)) when r1 = r2 -> code := [[|100; 9995; get_register r1|]; [|15|]]::!code (*choisir le bon opcode*)
  |Testl(op1, op2) -> twoarg_instruction op1 op2 code insts 16 4
  |Xorl(src, dst)  -> twoarg_instruction src dst code insts 18 4

  |Sall(count, dst) -> twoarg_instruction count dst code insts 20 4 (*choisir opcode*)
  |Shrl(count, dst) -> twoarg_instruction count dst code insts 22 4 (*choisir opcode*)

  |Movl(src, dst) -> twoarg_instruction src dst code insts 24 4

  |Pushl(op) ->
    insts := [|26 + inst_type op|]::!insts; (* choisir opcode*)
    argumentf op insts 0 4;
    code := !insts::!code
  
  |Popl(op) ->
    insts := [|28 + inst_type op|]::!insts; (* choisir opcode*)
    argumentf op insts 0 4;
    code := !insts::!code

  |Leal(src, dst) ->
    insts := [|29|]::!insts;
    argumentf dst insts 2 1;
    argumentf src insts 0 1;
    code := !insts::!code

  |Jmp(target) -> code := [[|100; 9995; get_label target label_references|]; [|30|]]::!code;

  |Je(target) |Jz(target) -> code := [[|100; 9995; get_label target label_references|]; [|31|]]::!code;
  |Jne(target) |Jnz(target) -> code := [[|100; 9995; get_label target label_references|]; [|32|]]::!code;

  |Js(target) -> code := [[|100; 9995; get_label target label_references|]; [|33|]]::!code;
  |Jns(target) -> code := [[|100; 9995; get_label target label_references|]; [|34|]]::!code;

  |Jo(target) -> code := [[|100; 9995; get_label target label_references|]; [|35|]]::!code;
  |Jno(target) -> code := [[|100; 9995; get_label target label_references|]; [|36|]]::!code;

  |Jc(target) -> code := [[|100; 9995; get_label target label_references|]; [|37|]]::!code;
  |Jnc(target) -> code := [[|100; 9995; get_label target label_references|]; [|38|]]::!code;

  |Jge(target) |Jnl(target) -> code := [[|100; 9995; get_label target label_references|]; [|39|]]::!code;
  |Jnge(target) |Jl(target) -> code := [[|100; 9995; get_label target label_references|]; [|40|]]::!code;

  |Jle(target) |Jng(target) -> code := [[|100; 9995; get_label target label_references|]; [|41|]]::!code;
  |Jnle(target) |Jg(target) -> code := [[|100; 9995; get_label target label_references|]; [|42|]]::!code;

  |Call(target) ->
    (match target with 
    |Id(label) -> 
      if Hashtbl.mem label_references label then 
        code := [[|100; 9995; Hashtbl.find label_references label|]; [|46|]]::!code
      else
        code := [[|47 + opcall label|]]::!code
    | _ -> failwith "invalid target")

  |Ret -> if is_main then code := [[|43|]]::!code else code := [[|44|]]::!code

  |Leave -> code := [[|45|]]::!code (*choisir opcode*)
  
  |Nop -> ()

  | _ -> failwith "invalid instruction"

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

let () =
  let filename = "code.s" in
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