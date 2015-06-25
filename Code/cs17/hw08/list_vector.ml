#use "/home/awarstad/course/cs017/homework/hw08/vector_signature.ml" ;;

#use "/course/cs017/src/ocaml/CS17setup.ml" ;;

module ListVector =

struct

  type 'a vector = Vector of float list

  let vector_of_float_list alof = (Vector alof)

  let scale a_float vector = 
    (let (Vector l) = vector in (Vector (List.map (( *.) a_float) l)))

  let add vec1 vec2 = 
    (let (Vector l), (Vector m) = vec1, vec2 in 
       (if (List.length l) = (List.length m)
        then (Vector (List.map2 (+.) l m))
        else (failwith "Vectors must be of same length")))

  let dot vec1 vec2 = 
    (let (Vector l), (Vector m) = vec1, vec2 in
       (if (List.length l) = (List.length m)
        then (List.fold_right (+.) (List.map2 ( *.) l m) 0.)
        else (failwith "Vectors must be of same length")))

  let vector_of_ivpair_list aloivp d =
    (Vector (List.fold_right 
               (* anonymous function takes an (int * float) and a float list and cons-es the float of the tuple to the list *)
               ((fun (x: (int * float)) -> (fun (l: (float list)) -> (let (a, b) = x in (b :: l))))
                : (int * float) -> float list -> float list)
               (* add_zero takes an (int * float) list with all elements in ascending order by int, alot and two ints, n and d1 *)
               (* returns an (int * float) list such that there are (d1 - n + 1) elements all in ascending order by their ints *)
               (* and each int between n and d1 represented, and containt all elemetns of alot and all other elements (some int * 0.) *)
               (let rec add_zero (alot: (int * float) list) (n: int) (d1: int): (int * float) list =
                 (match alot, d1 with
                   | [], 0 -> []
                   | [], m -> (n, 0.) :: (add_zero alot (n + 1) (d1 - 1))
                   | hd :: tl, _ -> (let (a, b) = hd in ((if a = n 
                                                          then hd :: (add_zero tl (n + 1) (d1 -1))
                                                          else (n, 0.) :: (add_zero alot (n + 1) (d1 -1)))))) 
                in (add_zero (List.sort 
                                (* anonymous comparison function takes two (int * float) tuples, a and b *)
                                (* and returns the difference of the ints of a and b *)
                                (fun (a: (int * float)) -> (fun (b: (int * float)) -> (let (w, x), (y, z) = a, b in (w - y)))
                                  : (int * float) -> (int * float) -> int)
                                aloivp) 1 d))
               []))

end;;

(* test cases *)

let vec1 = (ListVector.Vector [1.; 2.; 3.; 4.; 5.]);;
let vec2 = (ListVector.Vector [9.; 8.; 7.; 6.; 5.]);;
let vec3 = (ListVector.Vector [1.; 1.; 1.; 1.; 1.]);;



(* vector_of_float_list *)
check_expect (ListVector.vector_of_float_list [1.; 2.; 3.; 4.; 5.]) vec1;;
check_expect (ListVector.vector_of_float_list []) 
  (ListVector.Vector []);;


(* scale *)
check_expect (ListVector.scale 2. vec1) 
  (ListVector.Vector [2.; 4.; 6.; 8.; 10.]);;
check_expect (ListVector.scale 1. vec1) vec1;;
check_expect (ListVector.scale 8. (ListVector.Vector [])) (ListVector.Vector []) ;;


(* add *)
check_expect (ListVector.add vec1 vec2) (ListVector.Vector [10.; 10.; 10.; 10.; 10.]);;
check_expect (ListVector.add (ListVector.Vector []) (ListVector.Vector [])) (ListVector.Vector []) ;;
check_error (fun (x) -> (ListVector.add (ListVector.Vector []) (ListVector.Vector [1.])))
  "Vectors must be of same length" ;;


(* dot *)
check_expect (ListVector.dot vec1 vec3) 15. ;;
check_expect (ListVector.dot (ListVector.Vector []) (ListVector.Vector [])) 0. ;;
check_error (fun (x) -> (ListVector.add (ListVector.Vector []) (ListVector.Vector [1.])))
  "Vectors must be of same length" ;;


(* vector_of_ivpair_list *)
check_expect (ListVector.vector_of_ivpair_list [(2, 3.); (4, 5.)] 9)
  (ListVector.Vector [0.; 3.; 0.; 5.; 0.; 0.; 0.; 0.; 0.]) ;;
check_expect (ListVector.vector_of_ivpair_list [(1, 3.); (2, 5.)] 2)
  (ListVector.Vector [3.; 5.]) ;;
check_expect (ListVector.vector_of_ivpair_list [] 9)
  (ListVector.Vector [0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.; 0.]) ;;
check_expect (ListVector.vector_of_ivpair_list [] 0) (ListVector.Vector []);;
check_expect (ListVector.vector_of_ivpair_list [(2, 3.); (4, 3.); (1, 5.)] 9)
  (ListVector.Vector [5.; 3.; 0.; 3.; 0.; 0.; 0.; 0.; 0.]) ;;


