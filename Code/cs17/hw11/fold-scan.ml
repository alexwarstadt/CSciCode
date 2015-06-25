#use "/course/cs017/src/ocaml/CS17setup.ml" ;;


(*
scan_right
I/P : 
a two argument procedure, proc
a list of data of the type that proc takes as argument, alod
a base, base
O/P : a list of data such that each nth element is the result of applying proc to base and each successive element of alod up to the nth element
*)

(*let rec scan_right (proc : 'a -> 'b -> 'b) (alod : 'a list) (base : 'b) : 'b list =
  match alod with
  | [] -> base::[]
  | hd::tl -> (List.fold_right proc alod base)::(scan_right proc tl base)*);;

let rec scan_right (proc : 'a -> 'b -> 'b) (alod : 'a list) (base : 'b) : 'b list =
  match alod with
    | [] -> base::[]
    | hd::tl -> let h::t = scan_right proc tl base in (proc hd h)::h::t;;

check_expect (scan_right ( *. ) [] 1.) [1.];;
check_expect (scan_right (fun x y -> x^" "^y) ["once" ; "upon" ; "a" ; "time"] "")
  ["once upon a time " ; "upon a time " ; "a time " ; "time " ; ""];;







(*
scan_left
I/P : 
a two argument procedure, proc
a list of data of the type that proc takes as argument, alod
a base, base
O/P : a list of data such that each nth element is the result of applying proc to base and each successive element of alod from the nth element to the last head
*)

let rec scan_left (proc : 'a -> 'b -> 'b) (base : 'b) (alod : 'a list) : 'b list =
  match alod with
    | [] -> base::[]
    | hd::tl -> base::(scan_left proc (proc hd base) tl);;

scan_left (+) 0 [1 ; 1 ; 2 ; 3 ; 5];;





