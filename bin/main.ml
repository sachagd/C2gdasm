open Ast

let rec finstructionf instructions =
  match instructions with 
  |[] -> 0
  |Cltd::t -> finstructionf t
  |_::t -> 1 + finstructionf t 

let flabelf label_references program_counter label =
  match label with
  |Label(name, instructions) ->
    Hashtbl.add label_references (String.sub name 0 (String.length name - 1)) !program_counter;
    program_counter := !program_counter + finstructionf instructions

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

let sinstructionf code label_references is_main instruction = 
  let insts = ref [] in 
  match instruction with 
  |Addb(src, dst) -> twoarg_instruction src dst code insts 1 4
  |Addw(src, dst) -> twoarg_instruction src dst code insts 3 4
  |Addl(Imm(imm), Reg1("%esp")) -> code := [[|100; 9995; imm / 4|]; [|100; 9997; 9990|]; [|5|]]::!code 
  |Addl(src, dst) -> twoarg_instruction src dst code insts 5 4
  
  |Subb(src, dst) -> twoarg_instruction src dst code insts 7 4                                                                                                                                                                                                                                                   
  |Subw(src, dst) -> twoarg_instruction src dst code insts 9 4
  |Subl(Imm(imm), Reg1("%esp")) -> code := [[|100; 9995; imm / 4|]; [|100; 9997; 9990|]; [|11|]]::!code
  |Subl(src, dst) -> twoarg_instruction src dst code insts 11 4

  |Cmpb(src, dst) -> twoarg_instruction src dst code insts 13 4
  |Cmpw(src, dst) -> twoarg_instruction src dst code insts 15 4
  |Cmpl(src, dst) -> twoarg_instruction src dst code insts 17 4

  |Andb(src, dst) -> twoarg_instruction src dst code insts 19 4
  |Andw(src, dst) -> twoarg_instruction src dst code insts 21 4
  |Andl(src, dst) -> twoarg_instruction src dst code insts 23 4

  |Testb(op1, op2) -> twoarg_instruction op1 op2 code insts 25 4
  |Testw(op1, op2) -> twoarg_instruction op1 op2 code insts 27 4
  |Testl(op1, op2) -> twoarg_instruction op1 op2 code insts 29 4

  |Xorb(src, dst) -> twoarg_instruction src dst code insts 31 4
  |Xorw(src, dst) -> twoarg_instruction src dst code insts 33 4
  |Xorl(src, dst) -> twoarg_instruction src dst code insts 35 4
    
  |Imull(src, dst) -> twoarg_instruction src dst code insts 36 4 (* il faut le diviser selon les combinaisons d'arguments possibles *)

  |Idivl(op) ->
    insts := [|38|]::!insts;
    argumentf op insts 0 4;
    code := !insts::!code;

  |Cltd -> ()

  |Movb(src, dst) -> twoarg_instruction src dst code insts 39 4
  |Movw(src, dst) -> twoarg_instruction src dst code insts 41 4
  |Movl(src, dst) -> twoarg_instruction src dst code insts 43 4

  |Leal(src, dst) -> twoarg_instruction src dst code insts 64 1 (* ne prend pas d'immediat en argument *)

  |Jmp(target) -> code := [[|100; 9995; get_label target label_references|]; [|45|]]::!code;

  |Je(target) |Jz(target) -> code := [[|100; 9995; get_label target label_references|]; [|46|]]::!code;
  |Jne(target) |Jnz(target) -> code := [[|100; 9995; get_label target label_references|]; [|47|]]::!code;

  |Js(target) -> code := [[|100; 9995; get_label target label_references|]; [|48|]]::!code;
  |Jns(target) -> code := [[|100; 9995; get_label target label_references|]; [|49|]]::!code;

  |Jo(target) -> code := [[|100; 9995; get_label target label_references|]; [|50|]]::!code;
  |Jno(target) -> code := [[|100; 9995; get_label target label_references|]; [|51|]]::!code;

  |Jc(target) -> code := [[|100; 9995; get_label target label_references|]; [|52|]]::!code;
  |Jnc(target) -> code := [[|100; 9995; get_label target label_references|]; [|53|]]::!code;

  |Jge(target) |Jnl(target) -> code := [[|100; 9995; get_label target label_references|]; [|54|]]::!code;
  |Jnge(target) |Jl(target) -> code := [[|100; 9995; get_label target label_references|]; [|55|]]::!code;

  |Jle(target) |Jng(target) -> code := [[|100; 9995; get_label target label_references|]; [|56|]]::!code;
  |Jnle(target) |Jg(target) -> code := [[|100; 9995; get_label target label_references|]; [|57|]]::!code;

  |Call(target) -> code := [[|100; 9995; get_label target label_references|]; [|62|]]::!code;

  |Ret -> if is_main then code := [[|64|]]::!code else code := [[|63|]]::!code;

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
  let filename = "test.s" in
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