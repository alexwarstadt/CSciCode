#load "str.cma" ;;

(* sfirst : string -> string
 * Input  : a string, s
 * Output : a string consisting of the first character of s *)
let sfirst s = String.sub s 0 1 ;;

(* srest  : string -> string
 * Input  : a string, s 
 * Output : a string consisting of all but the first character of s *)
let srest s = String.sub s 1 ((String.length s) - 1) ;;

(* sempty : string -> integer
 * Input  : a string, s
 * Output : a boolean, true if the string is the empty string *)
let sempty s = (s = "") ;;

(* trimmer : string -> string list
 * Input   : a string s
 * Output  : a string list consisting of all the words in s in lowercase
     with whitespace and any non-alphabetical character stripped out *)
let trimmer s =
  List.filter (fun x -> String.length x > 0)
    (Str.split (Str.regexp "[^a-z]") (String.lowercase s)) ;;
