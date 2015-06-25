#use "/course/cs017/src/ocaml/CS17setup.ml" ;;

type answer =
    | Less
    | Equal
    | Greater;;

(* I/P : two ints, n1 and n2
   O/P : an answer, Less if n1 < n2, Equal if n1 = n2, Greater if n1 > n2 *)
let compare (n1 : int) (n2 : int) : answer =
  if n1 < n2 then Less else (if n1 = n2 then Equal else Greater);;
(*testing*)
check_expect (compare 1 2) Less ;;
check_expect (compare 2 2) Equal ;;
check_expect (compare 3 2) Greater ;;






(* I/P : two ints, x and y, y is a natural number
   O/P : x^y *)
let rec brute_force (x : int) (y : int) : int =
  match y with
    | 0 -> 1
    | _ -> x*(brute_force x (y-1));;
(*testing*)
check_expect (brute_force 1 1) 1 ;;
check_expect (brute_force 1 3) 1 ;;
check_expect (brute_force 5 1) 5 ;;
check_expect (brute_force 2 6) 64 ;;
check_expect (brute_force 3 0) 1 ;;
check_expect (brute_force 0 9) 0 ;;
check_expect (brute_force (-3) 3) (-27) ;;


(* I/P : two ints, x and y, y is a natural number
   O/P : x^y *)
let rec super_power (x : int) (y : int) : int =
  match y with
    | 0 -> 1
    | _ -> let avg = (y/2) in 
          match compare avg (y-avg) with
            | Less -> x*(super_power (x*x) avg)
            | _ -> (super_power (x*x) avg) ;;
(*testing*)
check_expect (super_power 1 1) 1 ;;
check_expect (super_power 1 3) 1 ;;
check_expect (super_power 5 1) 5 ;;
check_expect (super_power 2 6) 64 ;;
check_expect (super_power 3 0) 1 ;;
check_expect (super_power 0 9) 0 ;;
check_expect (super_power (-3) 3) (-27) ;;
