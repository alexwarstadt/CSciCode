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





(* I/P : an int k, a natural number; a list of ints alon
   O/P : the kth smallest element of alon such that *)
let rec kth (k : int) (alon : int list) : int =
  match k, alon with
    | 0, [n] -> n
    | _, hd::tl -> let l1 = List.filter ((>) hd) tl in 
          (let len1 = List.length l1 in
             (if len1 = k then hd else 
                (if len1 < k then kth (k-1-len1) (List.filter ((<=) hd) tl) 
                 else kth k l1)))
    | _, [] -> failwith "k must be less than the length of alon";;
(*testing*)
check_expect (kth 0 [1]) 1;;
check_expect (kth 3 [1; 4; 2; 0]) 4;;
check_expect (kth 1 [1; 4; 2; 0]) 1;;
check_expect (kth 3 [1; 1; 1; 1]) 1;;
check_expect (kth 3 [1; 1; 2; 1]) 2;;
check_expect (kth 2 [2; 1; 1; 1]) 1;;
check_error (fun x -> (kth 9 [1; 4; 2; 0])) "k must be less than the length of alon";;



