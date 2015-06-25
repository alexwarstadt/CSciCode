#use "/course/cs017/src/ocaml/CS17setup.ml"

type 'a btree =
    | Leaf
    | Node of 'a btree * 'a * 'a btree ;;

let bst1 = Node 
             (Node 
                (Node (Leaf, 1, Leaf), 3, Node (Leaf, 4, Leaf)), 5, 
              Node (Node (Leaf, 6, Leaf), 7, Node (Leaf, 11, Leaf)));;
let bst2 = Node (Node (Leaf, 1, Leaf), 3, 
                 Node (Leaf, 4, Node (Node (Leaf, 5, Leaf), 6, 
                                      Node (Node (Leaf, 7, Leaf), 11, Leaf))));;

(*
slow_traverse
I/P : an 'a btree, atod
O/P : a list containing first the left subtree of a given node followed by the node followed by the right subtree
*)
let rec slow_traverse (atod : 'a btree) : 'a list =
  match atod with
    | Leaf -> []
    | Node (l, n, r) -> (slow_traverse l) @ [n] @ (slow_traverse r);;

check_expect (slow_traverse bst1) [1; 3; 4; 5; 6; 7; 11];;
check_expect (slow_traverse bst2) [1; 3; 4; 5; 6; 7; 11];;
check_expect (slow_traverse Leaf) [];;




(*
fast_traverse
I/P : an 'a btree, atod
O/P : a list containing first the left subtree of a given node followed by the node followed by the right subtree
*)
let fast_traverse (atod : 'a btree) : 'a list =
  let rec ft_helper (atod1 : 'a btree) (acc : 'a list) =
    match atod1 with
      | Leaf -> acc
      | Node (l, n, r) -> (ft_helper l (n::(ft_helper r acc))) in
    ft_helper atod [];;

check_expect (fast_traverse bst1) [1; 3; 4; 5; 6; 7; 11];;
check_expect (fast_traverse bst2) [1; 3; 4; 5; 6; 7; 11];;
check_expect (fast_traverse Leaf) [];;
