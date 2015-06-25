# use "/course/cs017/src/hw11/ordered_set_signature.ml";;
#use "/course/cs017/src/ocaml/CS17setup.ml";;


module BSTOrderedSet : ORDERED_SET =
struct
  type 'a ordered_set =
      | Leaf
      | Node of 'a ordered_set * 'a * 'a ordered_set



  (* 
* I/P : an ordered set of type 'a, abst
* O/P : the minimum datum in abst 
*)
  let rec min (abst : 'a ordered_set) : 'a =
    match abst with
      | Leaf -> failwith "the empty set has no minimum"
      | Node (Leaf, d, _) -> d
      | Node (l, _, _) -> min l



(*
* I/P : an ordered set of type 'a, abst
* O/P : the maximum datum in abst
*)
  let rec max (abst : 'a ordered_set) : 'a =
    match abst with
      | Leaf -> failwith "the empty set has no maximum"
      | Node (_, d, Leaf) -> d
      | Node (_, _, r) -> max r




(*
* I/P : an ordered set of type 'a, abst1; a datum of type 'a, adatum
* O/P : an option, either Some of the largest datum in abst1 that is less than adatum or None
* if adatum is not contained in abst1 or if it is the smallest element of abst1
*)
  let pred (abst1 : 'a ordered_set) (adatum : 'a): 'a option =
    let rec pred_helper (abst : 'a ordered_set) (candidate : 'a) : 'a option =
      match abst with
        | Leaf -> None
        | Node (Leaf, n, r) -> if n = adatum && n != candidate then Some candidate else None
        | Node (l, n, r) -> if candidate < n && n < adatum then pred_helper r n else
            if adatum < n then pred_helper l candidate else Some (max l) 
    in match abst1 with
      | Leaf -> None
      | Node (Leaf, n, r) when n = (min abst1) && n != adatum  -> Some n
      | Node (l, n ,r) -> pred_helper abst1 (min abst1)




(*
* I/P : an ordered set of type 'a, abst1; a datum of type 'a, adatum
* O/P : an option, either Some of the smallest datum in abst1 that is greater than adatum 
* or None if adatum is not contained in abst1 or if it is the smallest element of abst1
*)
  let succ (abst1 : 'a ordered_set) (adatum : 'a): 'a option =
    let rec succ_helper (abst : 'a ordered_set) (candidate : 'a) : 'a option =
      match abst with
        | Leaf -> None
        | Node (l, n, Leaf) -> if n = adatum && n != candidate then Some candidate else None
        | Node (l, n, r) -> if adatum < n && n < candidate then succ_helper l n else
            if adatum > n then succ_helper r candidate else Some (min r)
    in match abst1 with
      | Leaf -> None
      | Node (l, n, Leaf) when n = (max abst1) && n != adatum -> Some n
      | Node (l, n ,r) -> succ_helper abst1 (max abst1)




(*
* I/P : an ordered set of type 'a, abst1; two data of type 'a, datum1 and datum2
* O/P : an ordered set containing all the elements of abst1 between datum1 and datum2, inclusive
*)
  let rec range (abst : 'a ordered_set) (datum1 : 'a) (datum2 : 'a): 'a ordered_set = 
    match abst with
      | Leaf -> Leaf
      | Node (l, n, r) -> if datum1 <= n && datum2 >= n then Node ((range l datum1 datum2), n, (range r datum1 datum2)) else
          if datum2 < n then (range l datum1 datum2) else (range r datum1 datum2)



(*
* I/P : a list of type 'a, alod
* O/P : a balanced BSTOrderedSet containing all the elements of alod without any duplicates
*)
  let rec set_of_list (alod : 'a list) : 'a ordered_set =
    let rec kth (k : int) (alon : 'a list) : 'a =
      match k, alon with
        | 0, [n] -> n
        | _, hd::tl -> let l1 = List.filter ((>) hd) tl in
              (let len1 = List.length l1 in
                 (if len1 = k then hd else 
                    (if len1 < k then kth (k-1-len1) (List.filter ((<=) hd) tl) 
                     else kth k l1)))
        | _, [] -> failwith "kth: k must be less than the length of alod" in
      match alod with
        | [] -> Leaf
        | _::_ -> let median = kth ((List.length alod)/2) alod in 
              Node ((set_of_list (List.filter (fun x -> x < median) alod)), 
                    median, 
                    (set_of_list (List.filter (fun x -> x > median) alod)))




(*
* I/P : an ordered set of type 'a, abst
* O/P : a list of type 'a containing all the elements of abst (in order)
*)
  let rec list_of_set (abst : 'a ordered_set) : 'a list =
    let rec ls_helper (atod1 : 'a ordered_set) (acc : 'a list) =
      match atod1 with
        | Leaf -> acc
        | Node (l, n, r) -> (ls_helper l (n::(ls_helper r acc))) in
      ls_helper abst []
      (*match abst with
        | Leaf -> []
        | Node (l, n, r) -> (list_of_set l) @ [n] @ (list_of_set r)*)

end;;


(*TESTING*)
let bstos1 = BSTOrderedSet.set_of_list [9; 2; 3; 10; 1; 4; 8];;
let leaf = BSTOrderedSet.set_of_list [];;
check_expect ((BSTOrderedSet.set_of_list [1; 1; 1; 1]) = (BSTOrderedSet.set_of_list [1])) true;;
check_expect (BSTOrderedSet.list_of_set bstos1) [1; 2; 3; 4; 8; 9; 10];;

(*min*)
check_error (fun x -> BSTOrderedSet.min leaf) "the empty set has no minimum";;
check_expect (BSTOrderedSet.min bstos1) 1;;

(*max*)
check_error (fun x -> BSTOrderedSet.max leaf) "the empty set has no maximum";;
check_expect (BSTOrderedSet.max bstos1) 10;;

(*pred*)
check_expect (BSTOrderedSet.pred leaf 9) None;;
check_expect (BSTOrderedSet.pred bstos1 9) (Some 8);;
check_expect (BSTOrderedSet.pred bstos1 7) None;;
check_expect (BSTOrderedSet.pred bstos1 8) (Some 4);;
check_expect (BSTOrderedSet.pred bstos1 1) None;;
check_expect (BSTOrderedSet.pred bstos1 2) (Some 1);;
check_expect (BSTOrderedSet.pred bstos1 3) (Some 2);;
check_expect (BSTOrderedSet.pred bstos1 4) (Some 3);;
check_expect (BSTOrderedSet.pred bstos1 10) (Some 9);;
check_expect (BSTOrderedSet.pred (BSTOrderedSet.set_of_list [1]) 1) (None);;
check_expect (BSTOrderedSet.pred (BSTOrderedSet.set_of_list [1; 2]) 2) (Some 1);;
check_expect (BSTOrderedSet.pred (BSTOrderedSet.set_of_list [1; 2]) 1) None;;

(*succ*)
check_expect (BSTOrderedSet.succ leaf 9) None;;
check_expect (BSTOrderedSet.succ bstos1 9) (Some 10);;
check_expect (BSTOrderedSet.succ bstos1 7) None;;
check_expect (BSTOrderedSet.succ bstos1 8) (Some 9);;
check_expect (BSTOrderedSet.succ bstos1 1) (Some 2);;
check_expect (BSTOrderedSet.succ bstos1 2) (Some 3);;
check_expect (BSTOrderedSet.succ bstos1 3) (Some 4);;
check_expect (BSTOrderedSet.succ bstos1 4) (Some 8);;
check_expect (BSTOrderedSet.succ bstos1 10) None;;
check_expect (BSTOrderedSet.succ (BSTOrderedSet.set_of_list [1]) 1) (None);;
check_expect (BSTOrderedSet.succ (BSTOrderedSet.set_of_list [1; 2]) 2) None;;
check_expect (BSTOrderedSet.succ (BSTOrderedSet.set_of_list [1; 2]) 1) (Some 2);;

(*range*)
check_expect (BSTOrderedSet.list_of_set (BSTOrderedSet.range bstos1 2 10)) 
  [2; 3; 4; 8; 9; 10];;
check_expect (BSTOrderedSet.list_of_set (BSTOrderedSet.range bstos1 3 3)) [3];;
check_expect (BSTOrderedSet.list_of_set (BSTOrderedSet.range bstos1 1 7)) 
  [1; 2; 3; 4];;
check_expect (BSTOrderedSet.list_of_set (BSTOrderedSet.range bstos1 7 7)) [];;
check_expect (BSTOrderedSet.list_of_set (BSTOrderedSet.range bstos1 15 18)) [];;







