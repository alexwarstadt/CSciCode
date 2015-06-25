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




(* I/P : an int, num, a natural number
   O/P : the greatest integer less than or equal to the square root of num *)
let rec square_root (num : int) : int = 
  (* srhelp takes two ints, a lower bound lb and an upper bound ub and 
     recursively reduces the range bounded by lb and ub until the square 
     of their average or their average+1 is equal to or bounds num by recurring
     on a smaller bound using the average and one of the original bounds *)
  (let rec srhelp (lb : int) (ub : int) : int =
    let avg = (ub+lb)/2 in 
      (match (compare (avg*avg) num), (compare ((avg+1)*(avg+1)) num) with
        | Less, Less -> srhelp avg ub
        | Equal, _ -> avg
        | _, Equal -> avg+1
        | Greater, Greater -> srhelp lb avg
        | _, _ -> avg)
   in (srhelp 0 num));;
(*testing*)
check_expect (square_root 0) 0;;
check_expect (square_root 1) 1;;
check_expect (square_root 4) 2;;
check_expect (square_root 10000) 100;;
check_expect (square_root 10001) 100;;
check_expect (square_root 9999) 99;;



