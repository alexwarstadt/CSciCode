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
RUNTIME

The runtime of slow_traverse is an element of O(nlog(n)), where n is the number of nodes in the BST.

At each recursive call, slow_traverse performs two appends, one of which is constant and therefore trivial and the other being linear in n/2, the length of one of the input lists.

There are two recursive calls made at each step, so the number of nodes on each level is 2^(l-1), where l is the level number in the recurrence relation. The input size at each level is n/(2^l-1). Thus the total work at each level is n/2.

Assuming that n is a power of 2, the number of levels is log_2(n). The last level is just the base cases, at which only constant work c is performed. Thus the total cost of slow_traverse is (n/2)(log_2(n)-1)+c(n/2), which is an element of O(nlog(n)).
*)


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

(*
RUNTIME

The runtime of fast_traverse is an element of O(n), where n is the number of nodes in the BST.

At each recursive call, slow_traverse performs only constant work. Let this total amoun of work be a constant k.

There are two recursive calls made at each step, so the number of nodes on each level is 2^(l-1), where l is the level number in the recurrence relation. k(2^(l-1))

Assuming that n is a power of 2, the number of levels is log_2(n). The last level is just the base cases, at which only constant work c is performed. Thus the total cost of slow_traverse is the sum of k(2^(l-1)) from l=1 to log_2(n)-1 plus c(n/2). This is equal to (k/2)(n-1)+c(n/2), which is an element of O(n).
*)
