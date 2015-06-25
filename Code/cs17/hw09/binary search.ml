let rec guess (num : int) (lb : int) (ub : int) : int = 
  if num = lb then 1 else 1 + (guess num (lb + 1) ub) ;;

guess 3 1 10 ;;

guess 8 4 34;;


type answer =
    | Less
    | Equal
    | Greater;;

let compare n1 n2 =
  if n1 < n2 then Less else (if n1 = n2 then Equal else Greater);;


let rec guess2 (num : int) (lb : int) (ub : int) : int = 
  let avg = (lb + ub) / 2 in 
    (1 +
     match (compare num avg) with
       | Equal -> 0
       | Less -> guess2 num lb avg
       | Greater -> guess2 num avg ub) ;;

guess2 4 1 13;;

guess2 0 0 100;;

(* runtime = ceil(log_2(ub-lb))*)

