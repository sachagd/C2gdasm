open Ast

let flabelf label_references program_counter label =
  match label with
  |Label(name, instructions) ->
    Hashtbl.add label_references (String.sub name 0 (String.length name - 1)) !program_counter;
    program_counter := !program_counter + List.length instructions

let rec ffunctionsf functions label_references program_counter =
  match functions with 
  |[] -> ()
  |Function(name, labels)::t ->
    if name = "main:" then 
      begin
      List.iter (flabelf label_references program_counter) labels;
      ffunctionsf t label_references program_counter;
      end
    else 
      begin
      ffunctionsf t label_references program_counter;
      List.iter (flabelf label_references program_counter) labels;
      end

let fprogramf (Program(functions)) = 
  let program_counter = ref 0 in 
  let label_references = Hashtbl.create 0 in
  ffunctionsf functions label_references program_counter;
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
  |Imm(s) -> insts := [|100; 9995 + argoffset; (if s = "$_GLOBAL_OFFSET_TABLE_" then 0 else int_of_string (String.sub s 1 (String.length s - 1)))|]::!insts
  |Reg1(reg) -> insts := [|100; 9995 + argoffset; get_register reg|]::!insts
  |Reg2(reg) -> insts := [|101; 9995 + argoffset; get_register reg|]::!insts
  |Reg3(offset, reg) -> insts := [|101; 9995 + argoffset; get_register reg|]::[|102; 9995 + argoffset; offset|]::!insts
  |Reg4(offset, base, index, scale) -> insts := [|101; 9995 + argoffset; get_register index|]::[|104; 9995 + argoffset; scale|]::[|103; 9995 + argoffset; get_register base|]::[|102; 9995 + argoffset; offset|]::!insts
  | _ -> failwith "invalid argument"

let inst_type arg = 
  match arg with
  |Imm(_) -> 0
  |Reg1(_) |Reg2(_) |Reg3(_, _) |Reg4(_, _, _, _) -> 1
  | _ -> failwith "invalid argument"

let twoarg_instruction src dst code insts base = 
    insts := [|base + inst_type src|]::!insts;
    argumentf src insts 0;
    argumentf dst insts 2;
    code := !insts::!code

let get_label target label_references = 
  match target with 
  |Id(label) -> Hashtbl.find label_references label
  | _ -> failwith "invalid target"

let instructionf code label_references instruction = 
  let insts = ref [] in 
  match instruction with 
  |Add(src, dst) -> twoarg_instruction src dst code insts 1
    
  |Sub(src, dst) -> twoarg_instruction src dst code insts 3

  |Cmp(src, dst) -> twoarg_instruction src dst code insts 5

  |Testl(op1, op2) -> twoarg_instruction op1 op2 code insts 7

  |Andl(src, dst) -> twoarg_instruction src dst code insts 9

  |Xorl(src, dst) -> twoarg_instruction src dst code insts 11
    
  |Idivl(op) ->
    insts := [|13|]::!insts;
    argumentf op insts 0;
    code := !insts::!code;

  |Cltd -> code := [[|14|]]::!code

  |Mov(src, dst) -> twoarg_instruction src dst code insts 15

  |Jmp(target) -> code := [[|100; 9995; get_label target label_references|];[|17|]]::!code;

  |Jl(target) -> code := [[|100; 9995; get_label target label_references|];[|18|]]::!code;

  |Jle(target) -> code := [[|100; 9995; get_label target label_references|];[|19|]]::!code;

  |Je(target) -> code := [[|100; 9995; get_label target label_references|];[|20|]]::!code;

  |Jne(target) -> code := [[|100; 9995; get_label target label_references|];[|21|]]::!code;

  |Call(target) -> code := [[|100; 9995; get_label target label_references|];[|22|]]::!code;

  |Ret -> code := [[|23|]]::!code;

  | _ -> failwith "invalid instruction"

let slabelf label_references code label =
  match label with
  |Label(_, instructions) ->
    List.iter (instructionf code label_references) instructions

let rec sfunctionsf functions label_references code =
  match functions with 
  |[] -> ()
  |Function(name, labels)::t ->
    if name = "main:" then 
      begin
      List.iter (slabelf label_references code) labels;
      sfunctionsf t label_references code;
      end
    else 
      begin
      sfunctionsf t label_references code;
      List.iter (slabelf label_references code) labels;
      end

let sprogramf (Program(functions)) label_references = 
  let code = ref [] in
  sfunctionsf functions label_references code;
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