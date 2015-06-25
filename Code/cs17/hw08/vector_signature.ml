#use "/course/cs017/src/ocaml/CS17setup.ml" ;;

module type VECTOR =

sig
  type 'a vector

  (* I/P: a list of floats, alof *)
  (* O/P: a vector such that the ith value in the vector is the ith element of alof*)
  val vector_of_float_list : float list -> 'a vector 

  (* I/P: a float, a_float; a vector, vector *)
  (* O/P:  vector scaled by a_float*)
  val scale : float -> 'a vector -> 'a vector 

  (* I/P: two vectors, vec1 and vec2 *)
  (* O/P: a vector such that the ith value of the output is equal to the sum of the ith values of the inputs *)
  val add : 'a vector  -> 'a vector  -> 'a vector 

  (* I/P: two vectors, vec1 and vec2 *)
  (* O/P: a float, the dot product of vec1 and vec2 *)
  val dot : 'a vector -> 'a vector -> float

  (* I/P: a list of iv pairs (i.e. tuples of (int * float)), aloivp; an int equal to the dimension, d *)
  (* O/P: a vector containing all the elemets of of aloivp and d*)
  val vector_of_ivpair_list : (int * float) list -> int -> 'a vector

end;;
