let a = 3

#require "stdint"
open Stdint
open Int32

let print_i32 n = 
  print_int (Int32.to_int n);
  print_newline ()

let print_list l =
    let rec aux l = 
    match l with 
    |[] -> print_string "[]"; print_newline ();
    |h :: [] -> print_int (Int32.to_int h); print_char ']'; print_newline ();
    |h :: t -> print_int (Int32.to_int h); print_string "; "; aux t 
  in print_char '['; aux l

let bin_to_int l = 
  let rec aux acc1 acc2 l = 
    match l with 
    |[] -> acc1
    |h::t -> aux (Int32.add acc1 (Int32.mul acc2 h)) (Int32.mul acc2 2l) t
  in aux 0l 1l (List.rev l)

let int_to_bin n = 
  let rec aux acc n = 
    if n = 0l then 
      List.init (Int.sub 32 (List.length acc)) (fun _ -> 0l) @ acc
    else 
      let bit =
        if Int32.logand n 1l = 1l then 1l else 0l
      in
      aux (bit :: acc) (Int32.shift_right_logical n 1)
  in aux [] n

let () = 
  let a = -1l in 
  let b = 5 in 
  print_int (Int32.to_int (shift_right_logical a b)) 

let test c = 
  print_i32 c;
  print_list (int_to_bin c)

let () = 
  let a = -397487328l in 
  let b = 7 in 
  let c = shift_right_logical a b in 
  test c
   

let () = 
  let a = bin_to_int [1l;1l;1l;1l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l;0l] in 
  print_i32 a;
  let b = 3 in 
  let c = shift_right_logical a b in
  print_i32 c; 
  print_list (int_to_bin c);
  let d = shift_right a b in
  print_i32 d;
  print_list (int_to_bin d); 
  let e = Int32.add d (shift_left 1l 29) in 
  print_i32 e; 
  print_list (int_to_bin e)
 