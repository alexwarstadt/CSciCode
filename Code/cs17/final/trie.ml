#use "/course/cs017/src/ocaml/CS17setup.ml" ;;
#use "/course/cs017/src/final/green_eggs_and_ham.ml" ;;
#use "/course/cs017/src/final/string_helpers.ml";;
#use "/course/cs017/src/final/trie_signature.ml";;


module TestTrie =

struct

  type trie = Trie of ((string * int * trie) list)

  let empty = Trie []

  (* tempty
     I/P : a trie, atrie
     O/P : true if atrie is the empty trie *)
  let tempty (atrie : trie) : bool = atrie = empty

  (* trie_of_string
     I/P : a string, s
     O/P : a trie that stores s *)
  let rec trie_of_string (s : string) : trie =
    match s with
      | "" -> empty
      | _ when sempty (srest s) -> Trie [(s, 1, Trie [])]
      | _ -> Trie [(sfirst s, 0, trie_of_string (srest s))]

  (* insert
     I/P : a string, s; a trie, atrie
     O/P : a trie containing s and all the data stored in atrie *)
  let rec insert (s : string) (atrie : trie) : trie = 
    if sempty s then failwith "you cannot insert an empty string" else
      match atrie with
        | Trie [] -> trie_of_string s
        | Trie ((str, num, tri)::tl) -> if (sfirst s) = str 
            then (match srest s with
                   | "" -> Trie ((str, num + 1, tri)::tl) 
                   | _ -> Trie ((str, num, (insert (srest s) tri))::tl))
            else (match insert s (Trie tl) with 
                   | Trie [] -> failwith "exhaustive match failure"
                   | (Trie t) -> Trie (t @ [(str, num, tri)]))

  (* trie_of_list
     I/P : a list of strings, alos
     O/P : a trie containing all the elements of alos *)
  let trie_of_list (alos : string list) : trie = 
    List.fold_right insert alos (Trie [])

  (* lookup
     I/P : a string, s; a trie, atrie
     O/P : an int option, either None if s is not stored in atrie, 
     or Some of the number of times s is stored in atrie *)
  let rec lookup (s : string) (atrie : trie) : int option =
    if sempty s then None else
      match atrie with
        | Trie [] -> None
        | Trie ((str, num, tri)::tl) -> if (sfirst s) = str 
            then (match srest s with
                   | "" -> (match tri with
                             | Trie [] -> Some num
                             | Trie _ -> if num = 0 then None else Some num)
                   | _ -> lookup (srest s) tri)
            else lookup s (Trie tl)

  (* list_of_trie
     I/P : a trie, atrie1
     O/P : a list of strings containing all the unique data stored in atrie1 
     (using an accumulator style helper) *)
  let list_of_trie (atrie1 : trie) : string list =
    let rec _list_of_trie (atrie : trie) (acc : string) =
      match atrie with
        | Trie [] -> [acc]
        | Trie [(str, num, tri)] -> (_list_of_trie tri (acc^str)) 
        | Trie ((str, num, tri)::tl) -> (if num = 0 || (tempty tri)
                                         then (_list_of_trie tri (acc^str)) 
                                              @ (_list_of_trie (Trie tl) acc) 
                                         else (acc^str)::(_list_of_trie tri (acc^str)) 
                                              @ (_list_of_trie (Trie tl) acc))
    in match atrie1 with
      | Trie [] -> []
      | Trie _ -> _list_of_trie atrie1 ""

  (* auto_complete
     I/P : a string, s1; a trie, atrie1
     O/P : a list of all the strings stored in atrie1 that have s1 as a prefix 
     (using an accumulator style helper) *)
  let auto_complete (s1 : string) (atrie1 : trie) : string list =
    let rec _auto_complete (s : string) (atrie : trie) (acc : string) : string list =
      match s, atrie with
        | "", Trie [] -> if sempty acc then [] else [acc]
        | "", Trie _ -> List.map (fun (x) -> acc^x) (list_of_trie atrie)
        | _, Trie [] -> []
        | _, Trie ((str, num, tri)::tl) -> if (sfirst s) = str
            then _auto_complete (srest s) tri (acc^str)
            else _auto_complete s (Trie tl) acc
    in _auto_complete s1 atrie1 ""

end;;

(*
A trie works well for a dictionary in which there is a great deal of overlap in the data because any number of data that share the same prefix only need to have the prefix stored once. This means that a large amount of data can be stored with relatively little memory. For example, in a dictionary containing 10,000 data beginning with "a", the prefix "a" only needs to be stored once, not 10,000 times. For inserts, only the information that is not already a prefix to another datum needs to be inserted. For example, if a trie stored 500 regular Latin infinitives and all 100 conjugated forms of each verb were to be added to the trie, only the 50000 suffixes would need to be added -- the 50000 repeated roots would not. 

For lookups, since the branching factor is indefinite, the depth of the trie at which a datum is stored is always the length of the datum. On the other hand, in a BST, the branching factor is always two, so the depth of the BST is a function of the size of the data set, and the datum, regardless of its length, may much deeper in a large BST than it would be in a trie. This advantage is especially salient when shorter data are looked up more often. For example, in a dictionary of 1,000,000,000 data, the datum "I" may be stored at a depth as large as 30 in a balanced BST, but will always be at a depth of just 1 in a trie.
*)

module Trie = (TestTrie : TRIE) ;;


open TestTrie;;




(*TESTING*)

(*data*)
Trie [] (*the empty trie*);;
Trie [("h", 0, 
       Trie [("e", 0, 
              Trie [("l", 0, 
                     Trie [("l", 0, 
                            Trie [("o", 1, Trie [])])])])])];; (*stores "hello" once*)
Trie [("h", 0, 
       Trie [("e", 0, 
              Trie [("l", 0, 
                     Trie [("l", 0, 
                            Trie [("o", 5, Trie [])])])])])];; (*stores "hello" five times*)
Trie
  [("c", 0, Trie [("o", 0, Trie [("r", 0, Trie [("d", 1, Trie [])])])]);
   ("b", 0, Trie [("e", 0, Trie [("e", 2, Trie []); ("t", 1, Trie [])])])];; (*stores "cord" once , "bee" twice; and "bet" once *)

(*trie_of_string*)
check_expect (trie_of_string "hello") 
  (Trie [("h", 0, 
          Trie [("e", 0, 
                 Trie [("l", 0, 
                        Trie [("l", 0, 
                               Trie [("o", 1, Trie [])])])])])]);;
check_expect (trie_of_string "ooo")
  (Trie [("o", 0, 
          Trie [("o", 0, 
                 Trie [("o", 1, Trie [])])])]);;
check_expect (trie_of_string "") (Trie []);;





(*insert*)

check_error (fun x -> (insert "" (trie_of_string "cat"))) "you cannot insert an empty string";;
check_expect (insert "c" (trie_of_string "c"))
  (Trie [("c", 2, Trie [])]);;

check_expect (insert "helicopter" (trie_of_string "hello"))
  (Trie [("h", 0, 
          Trie [("e", 0, 
                 Trie [("l", 0,
                        Trie 
                          [("i", 0, 
                            Trie [("c", 0,
                                   Trie[("o", 0,
                                         Trie [("p", 0,
                                                Trie [("t", 0, 
                                                       Trie [("e", 0, 
                                                              Trie [("r", 1, 
                                                                     Trie [])])])])])])]);
                           ("l", 0, 
                            Trie [("o", 1, 
                                   Trie [])])])])])]);;
check_expect (insert "bed" (trie_of_string "bed")) 
  (Trie [("b", 0, 
          Trie [("e", 0, 
                 Trie [("d", 2, Trie [])])])]);;

check_expect (insert "bee" (insert "bee" (trie_of_string "bet"))) 
  (Trie [("b", 0, Trie [("e", 0, Trie [("e", 2, Trie []); ("t", 1, Trie [])])])]);;

check_expect (insert "cord" (insert "bee" (insert "bee" (trie_of_string "bet")))) 
  (Trie
     [("c", 0, Trie [("o", 0, Trie [("r", 0, Trie [("d", 1, Trie [])])])]);
      ("b", 0, Trie [("e", 0, Trie [("e", 2, Trie []); ("t", 1, Trie [])])])]);;

check_expect (insert "big" (insert "cord" (insert "bee" (insert "bee" (trie_of_string "bet"))))) 
  (Trie
     [("b", 0,
       Trie
         [("i", 0, Trie [("g", 1, Trie [])]);
          ("e", 0, Trie [("e", 2, Trie []); ("t", 1, Trie [])])]);
      ("c", 0, Trie [("o", 0, Trie [("r", 0, Trie [("d", 1, Trie [])])])])]);;

check_expect (insert "cold" (insert "big" (insert "cord" (insert "bee" 
                                                            (insert "bee" (trie_of_string "bet")))))) 
  (Trie
     [("c", 0,
       Trie
         [("o", 0,
           Trie
             [("l", 0, Trie [("d", 1, Trie [])]);
              ("r", 0, Trie [("d", 1, Trie [])])])]);
      ("b", 0,
       Trie
         [("i", 0, Trie [("g", 1, Trie [])]);
          ("e", 0, Trie [("e", 2, Trie []); ("t", 1, Trie [])])])]);;

check_expect (insert "bet" (insert "cold" (insert "cord" (insert "bee" 
                                                            (insert "bee" (trie_of_string "big")))))) 
  (Trie
     [("b", 0,
       Trie
         [("e", 0, Trie [("t", 1, Trie []); ("e", 2, Trie [])]);
          ("i", 0, Trie [("g", 1, Trie [])])]);
      ("c", 0,
       Trie
         [("o", 0,
           Trie
             [("l", 0, Trie [("d", 1, Trie [])]);
              ("r", 0, Trie [("d", 1, Trie [])])])])]);;




(*trie_of_list*)

check_expect (trie_of_list ["helicopter"; "hello"])(insert "helicopter" (trie_of_string "hello")) ;;
check_expect (trie_of_list ["bed"; "bed"]) (insert "bed" (trie_of_string "bed")) ;;
check_expect (trie_of_list ["bee"; "bee"; "bet"]) (insert "bee" (insert "bee" (trie_of_string "bet"))) ;;
check_expect (trie_of_list ["cord"; "bee"; "bee"; "bet"])
  (insert "cord" (insert "bee" (insert "bee" (trie_of_string "bet")))) ;;
check_expect (trie_of_list ["big"; "cord"; "bee"; "bee"; "bet"])
  (insert "big" (insert "cord" (insert "bee" (insert "bee" (trie_of_string "bet"))))) ;;
check_expect (trie_of_list ["bet"; "cold"; "cord"; "bee"; "bee"; "big"]) 
  (insert "bet" (insert "cold" (insert "cord" (insert "bee" (insert "bee" (trie_of_string "big"))))));;
check_expect (trie_of_list ["cold"; "big"; "cord"; "bee"; "bee"; "bet"]) 
  (insert "cold" (insert "big" (insert "cord" (insert "bee" (insert "bee" (trie_of_string "bet"))))));;





(*lookup*)
check_expect (lookup "hi" (trie_of_list ["hi"; "hi"; "bye"; "bye"; "hi"])) (Some 3);;
check_expect (lookup "" (trie_of_list ["hi"; "hi"; "bye"; "bye"; "hi"])) None;;
check_expect (lookup "hi" (trie_of_list ["bye"; "bye"; "h"])) None;;
check_expect (lookup "hi" (trie_of_list ["bye"; "bye"; "hit"])) None;;





(*list_of_trie*)
check_expect (list_of_trie (trie_of_list ["hi"; "bye"; "bee"; "bet"])) 
  ["hi"; "bye"; "bee"; "bet"];;
check_expect (list_of_trie (trie_of_list ["hi"; "hi"; "bye"; "bee"; "bet"]))
  ["hi"; "bye"; "bee"; "bet"];;
check_expect (list_of_trie (trie_of_list ["bye"; "hi"; "hi"; "bye"; "bee"; "bet"]))
  ["bye"; "bee"; "bet"; "hi"];;
check_expect (list_of_trie (trie_of_list [])) [];;





(*auto_complete*)
check_expect (auto_complete "be" (trie_of_list ["ben"; "bed"])) ["ben"; "bed"];;
check_expect (auto_complete "be" (trie_of_list ["big"; "ben"; "bed"])) ["ben"; "bed"];;
check_expect (auto_complete "be" (trie_of_list ["goo"; "ben"; "bed"])) ["ben"; "bed"];;
check_expect (auto_complete "b" (trie_of_list ["cold"; "big"; "cord"; "bee"; "bee"; "bet"]))
  ["big"; "bee"; "bet"];;
check_expect (auto_complete "co" (trie_of_list ["cold"; "big"; "cord"; "bee"; "bee"; "bet"]))
  ["cold"; "cord"];;
check_expect (auto_complete "" (trie_of_list ["cold"; "big"; "cord"; "bee"; "bee"; "bet"]))
  ["cold"; "cord"; "big"; "bee"; "bet"];;
check_expect (auto_complete "b" (trie_of_list ["beanbag"; "cold"; "big"; "cord"; "bee"; "bee"; "bet"]))
  ["beanbag"; "bet"; "bee"; "big"];;
check_expect (auto_complete "" (Trie [])) [];;






(* frequent_words
   I/P : a string, s
   O/P : a list containing all the unique words in s in decreasing order by their frequency in s *)
let frequent_words (s : string) : (string list) =
  let tri = Trie.trie_of_list (trimmer s) in
    List.map (fun (_, word) -> word) 
      (List.sort (fun (n1, _) (n2, _) -> (match n1, n2 with
                                            | None, _ -> failwith "EMP"
                                            | _, None -> failwith "EMP" 
                                            | Some num1, Some num2 -> num2 - num1) )
          (List.map (fun word -> ((Trie.lookup word tri), word)) (Trie.auto_complete "" tri)));;
(*TESTING*)
check_expect (frequent_words "red red green orange orange orange orange orange blue blue purple purple")
  ["orange"; "red"; "purple"; "blue"; "green"];;
check_expect (frequent_words "") [];;
check_expect (frequent_words ":) !@#$%^&*()_| ........") [];;
frequent_words green_eggs_and_ham;;








