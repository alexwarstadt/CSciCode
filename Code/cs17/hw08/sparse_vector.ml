#use "/home/awarstad/course/cs017/homework/hw08/vector_signature.ml" ;;
#use "/course/cs017/src/ocaml/CS17setup.ml" ;;

module SparseVector =
struct
  type 'a vector = Vector of (((int * float) list) * int)

  let rec vector_of_float_list alof = 
    match alof with
      | [] -> (Vector ([], 0))
      | head :: tail -> (let Vector (l, n) = (vector_of_float_list tail)
      (* madd1 is a helper that maps (+) 1 across a list of (int * float) *)
                         in (let madd1 (s : (int * float) list) : (int * float) list = 
                              (List.map (fun tup -> (let x, y = tup in (1 + x, y))) s) in 
                               (if (head = 0.)
                                then  (Vector (madd1 l, n + 1))
                                else (Vector (((1, head) :: madd1 l), (n + 1))))))

  let scale a_float vector = 
    (let Vector (l, m) = vector in
       (* in the special case that the scale factor is 0., the list in the outputted Vector must be *)
       (* [], otherwise the lists in the input and output have the same length *)
       (if a_float = 0. then Vector ([], m) else
          (Vector 
             ((List.map (fun (tup: (int * float)) -> (let x, y = tup in (x, a_float *. y))) l), m))))

  let rec add vec1 vec2 = 
    (let Vector (a, b), Vector (c, d) = vec1, vec2 in 
       (if b = d 
       (* add_help takes two (int * float) lists, l1 and l2 *) 
       (*returns an (int * float) list such that the nth float in the list is equal to *)
       (* the nth float of l1 plus the nth float of l2 *)
        then Vector ((let rec add_help l1 l2 = 
                       (match l1, l2 with
                         | [], [] -> []
                         | _ :: _, [] -> l1
                         | [], _ :: _ -> l2
                         | hd1 :: tl1, hd2 :: tl2 -> 
                             (let (w, x), (y, z) = hd1, hd2 in
                                (if w < y 
                                 then (hd1 :: (add_help tl1 l2))
                                 else (if y < w then (hd2 :: (add_help l1 tl2))
                                 (* in the special case that the sum of two corresponding values is 0.*)
                                 (* then there should be no corresonding element in the output list *)
                                       else (if x = (-1. *. z)
                                             then (add_help tl1 tl2) 
                                             else ((w, (x +. z)) :: (add_help tl1 tl2))))))) in
                        (add_help a c)), b)
        else failwith "inputs must have the same dimension"))

  let rec dot vec1 vec2 = 
    (let Vector (a, b), Vector (c, d) = vec1, vec2 in 
       (if b = d 
        then (match a, c with
               | [], [] -> 0.
               | _ :: _, [] -> 0.
               | [], _ :: _ -> 0.
               | hd1 :: tl1, hd2 :: tl2 -> 
                   (let (w, x), (y, z) = hd1, hd2 in
                      (if w < y 
                       then (dot (Vector (tl1, b - 1)) (Vector (c, d - 1)))
                       else (if y < w 
                             then (dot (Vector (a, b - 1)) (Vector (tl2, d - 1)))
                             else (x *. z) +. (dot (Vector (tl1, b - 1)) (Vector (tl2, d - 1)))))))
        else failwith "inputs must have the same dimension"))

  let vector_of_ivpair_list aloivp d =
    Vector ((List.sort 
               (* anonymous comparison function takes two (int * float) tuples, a and b *)
               (* and returns the difference of the ints of a and b *)
               (fun (a: (int * float)) -> (fun (b: (int * float)) -> (let (w, x), (y, z) = a, b in (w - y)))
                 : (int * float) -> (int * float) -> int) 
               aloivp),
            d)

end;;

(* test cases*)

(* vector_of_float_list*)
check_expect (SparseVector.vector_of_float_list [3.; 2.; 1.])
  (SparseVector.Vector ([(1, 3.); (2, 2.); (3, 1.)], 3)) ;;
check_expect (SparseVector.vector_of_float_list [3.; 0.; 1.])
  (SparseVector.Vector ([(1, 3.); (3, 1.)], 3));;
check_expect (SparseVector.vector_of_float_list [0.; 0.; 0.])
  (SparseVector.Vector ([], 3));;
check_expect (SparseVector.vector_of_float_list [])
  (SparseVector.Vector ([], 0));;
check_expect (SparseVector.vector_of_float_list [4.; 0.; 3.; 1.; 0.])
  (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 5));;



(* scale *)
check_expect (SparseVector.scale 0. (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 5)))
  (SparseVector.Vector ([], 5));;
check_expect (SparseVector.scale 2. (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 5)))
  (SparseVector.Vector ([(1, 8.); (3, 6.); (4, 2.)], 5));;
check_expect (SparseVector.scale 0.5 (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 5)))
  (SparseVector.Vector ([(1, 2.); (3, 1.5); (4, 0.5)], 5));;




(* add *)
check_expect (SparseVector.add (SparseVector.Vector ([], 0)) (SparseVector.Vector ([], 0)))
  (SparseVector.Vector ([], 0)) ;;
check_expect (SparseVector.add (SparseVector.Vector ([], 4)) (SparseVector.Vector ([], 4)))
  (SparseVector.Vector ([], 4)) ;;
check_expect (SparseVector.add 
                (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4)) 
                (SparseVector.Vector ([], 4)))
  (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4)) ;;
check_expect (SparseVector.add 
                (SparseVector.Vector ([], 4))
                (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4)))
  (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4)) ;;
check_expect (SparseVector.add 
                (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 4))
                (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4)))
  (SparseVector.Vector ([(1, 12.); (3, 6.4); (4, 1.)], 4)) ;;
check_expect (SparseVector.add 
                (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 4))
                (SparseVector.Vector ([(1, -4.); (3, 3.4)], 4)))
  (SparseVector.Vector ([(3, 6.4); (4, 1.)], 4)) ;;
check_expect (SparseVector.add 
                (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 4))
                (SparseVector.Vector ([(1, -4.); (3, -3.); (4, -1.)], 4)))
  (SparseVector.Vector ([], 4)) ;;
check_error (fun x -> 
              (SparseVector.add 
                 (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 5))
                 (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4))))
  "inputs must have the same dimension" ;;

(* dot *)
check_expect (SparseVector.dot 
                (SparseVector.Vector ([(3, 4.); (9, 10.)], 13))
                (SparseVector.Vector ([(4, 4.); (9, 2.)], 13))) 
  20. ;;
check_expect (SparseVector.dot 
                (SparseVector.Vector ([(1, 4.); (2, 10.)], 2))
                (SparseVector.Vector ([(1, 3.); (2, 2.)], 2)))
  32. ;;
check_expect (SparseVector.dot 
                (SparseVector.Vector ([(3, 4.); (9, 10.)], 13))
                (SparseVector.Vector ([(4, 5.); (10, 9.)], 13)))
  0. ;;
check_expect (SparseVector.dot 
                (SparseVector.Vector ([(3, 4.); (9, 10.)], 13))
                (SparseVector.Vector ([(4, 4.); (9, -2.)], 13)))
  (-20.) ;;
check_expect (SparseVector.dot 
                (SparseVector.Vector ([], 13))
                (SparseVector.Vector ([], 13)))
  0. ;;
check_expect (SparseVector.dot 
                (SparseVector.Vector ([], 0))
                (SparseVector.Vector ([], 0)))
  0. ;;
check_error (fun x -> 
              (SparseVector.dot 
                 (SparseVector.Vector ([(1, 4.); (3, 3.); (4, 1.)], 5))
                 (SparseVector.Vector ([(1, 8.); (3, 3.4)], 4))))
  "inputs must have the same dimension" ;;


(* vector_of_ivpair_list *)
check_expect (SparseVector.vector_of_ivpair_list [(2, 3.); (4, 5.)] 9)
  (SparseVector.Vector ([(2, 3.); (4, 5.)], 9)) ;;
check_expect (SparseVector.vector_of_ivpair_list [(2, 3.); (4, 3.); (1, 5.)] 9)
  (SparseVector.Vector ([(1, 5.); (2, 3.); (4, 3.)], 9)) ;;
check_expect (SparseVector.vector_of_ivpair_list [(1, 3.); (2, 5.)] 2)
  (SparseVector.Vector ([(1, 3.); (2, 5.)], 2)) ;;
check_expect (SparseVector.vector_of_ivpair_list [] 9)
  (SparseVector.Vector ([], 9)) ;;
check_expect (SparseVector.vector_of_ivpair_list [] 0) 
  (SparseVector.Vector ([], 0));;


