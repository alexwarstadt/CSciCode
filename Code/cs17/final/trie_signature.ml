module type TRIE = 
sig
  type trie

  (* an empty trie *)
  val empty : trie

  (* inserts a string into a trie *)
  val insert : string -> trie -> trie

  (* inserts every word in a list of words into a trie *)
  val trie_of_list : string list -> trie

  (* lookups the value of a key in the trie *)
  val lookup : string -> trie -> int option

  (* finds all words in the trie for which the given string is a prefix *)
  val auto_complete : string -> trie -> string list

end ;;
