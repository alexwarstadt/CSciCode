#use "/course/cs017/src/ocaml/CS17setup.ml" ;;

(* quad 
   I/P : an int, n
   O/P : a list containing all the unique subsets of the positive integers less than or equal to n
   such that each successive element is either the result of inserting or 
   removing an element from the previous element, but not both *)

let quad (n : int) : int list list =
  let rec _quad (num : int) (acc : int list list) : int list list =
    match num with
      | 0 -> acc
      | _ -> _quad (num-1) (acc @ (List.map (fun (x) -> num::x) (List.rev acc))) in
    _quad n [[]];;

(*TESTING *)
check_expect (quad 0) [[]];;
check_expect (quad 1) [[]; [1]];;
check_expect (quad 3) [[]; [3]; [2; 3]; [2]; [1; 2]; [1; 2; 3]; [1; 3]; [1]];;
check_expect (quad 6) [[]; [6]; [5; 6]; [5]; [4; 5]; [4; 5; 6]; [4; 6]; [4]; [3; 4]; [3; 4; 6];
                       [3; 4; 5; 6]; [3; 4; 5]; [3; 5]; [3; 5; 6]; [3; 6]; [3]; [2; 3];
                       [2; 3; 6]; [2; 3; 5; 6]; [2; 3; 5]; [2; 3; 4; 5]; [2; 3; 4; 5; 6];
                       [2; 3; 4; 6]; [2; 3; 4]; [2; 4]; [2; 4; 6]; [2; 4; 5; 6]; [2; 4; 5];
                       [2; 5]; [2; 5; 6]; [2; 6]; [2]; [1; 2]; [1; 2; 6]; [1; 2; 5; 6];
                       [1; 2; 5]; [1; 2; 4; 5]; [1; 2; 4; 5; 6]; [1; 2; 4; 6]; [1; 2; 4];
                       [1; 2; 3; 4]; [1; 2; 3; 4; 6]; [1; 2; 3; 4; 5; 6]; [1; 2; 3; 4; 5];
                       [1; 2; 3; 5]; [1; 2; 3; 5; 6]; [1; 2; 3; 6]; [1; 2; 3]; [1; 3];
                       [1; 3; 6]; [1; 3; 5; 6]; [1; 3; 5]; [1; 3; 4; 5]; [1; 3; 4; 5; 6];
                       [1; 3; 4; 6]; [1; 3; 4]; [1; 4]; [1; 4; 6]; [1; 4; 5; 6]; [1; 4; 5];
                       [1; 5]; [1; 5; 6]; [1; 6]; [1]];;
quad 16;;

