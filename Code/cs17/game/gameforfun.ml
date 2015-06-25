(*Columns in Connect Four Game*)
let board_size_column = 6;;

(*Rows in Connect Four Game*)
let board_size_row = 8;;

(* Pieces that make up the board: E for empty; R for Red (P1); 
 * B for Black (P2)*)
type piece = E | R | B;;

(* A list of lists of pieces, each inner list is a column and the outer list
 * is a list of columns of the board
 * The columns are numbered 1 through board_size_column, starting from the left.
 * The rows are numbered 1 through board_size_row, starting from the top*)
type board = Board of (piece list) list;;

(* A player, either P1 (plays based on the minnie algorithm) or 
 * P2 (plays by the max algorithm) *)
type player = 
    | P1
    | P2;;

(* direction, used to describe the direction we are looking in for estimate_value*)
type direction =
    | Right
    | RightDown
    | Down
    | LeftDown;;

(* A State consisting of a board, and the player whose turn it is *)
type state = State of (board*player);;

(* A move is a Drop of an int, that represents the column that is passed in wiht Drop *)
type move = Drop of int;;

(* initial_state
 * Input: no inputs
 * Output: a State consisting of a board with the dimensions 
 * predefined at the beginning of the module in board_size_column and 
 * board_size_row, filled with E pieces, representing that the board is
 * empty, and P1, as (s)he is the first one to start *)
let initial_state = 
  (* is_help
   * Input: r, int; c, int
   * Output: a piece list list, where there are c (piece list)s each with 
   * n pieces *)
  let rec is_help (r : int) (c : int) : piece list list =
    match c with
      | 0 -> []
      | _ -> 
          (* make_column
           * Input: m, int
           * Output: a piece list of only E pieces size m *)
          (let rec make_column (m : int) : piece list =
            match m with
              | 0 -> []
              | l -> E :: make_column (l-1) in 
             (make_column r)::(is_help r (c-1))) in 
    State (Board (is_help board_size_row board_size_column), P1);;

(* pieces_of_player
 * Input: p, player
 * Output: a piece that correlates to p (R is for P1, B is for P2 *)
let piece_of_player (p : player) : piece =
  match p with 
    | P1 -> R
    | P2 -> B;;

(* pieces_of_player
 * Input: p, player
 * Output: a string that correlates to p *)
let string_of_player (p : player) : string =
  match p with
    | P1 -> "P1"
    | P2 -> "P2";;

(* string_of_state
 * Input: (State (Board b, p)), state 
 * Output: a string that prints out the board, and says whose turn it is *)
let string_of_state (State (Board b, p) : state) : string =
  (* print_column
   * Input: col, int
   * Output: a string that prints out what each col looks like*)
  let rec print_column (col : piece list) : string =
    match col with
      | [] -> ""
      | hd::tl -> (match hd with
                    | E -> "E "
                    | R -> "R "
                    | B -> "B ") ^ (print_column tl) in
    (* ss_help
     * Input: x, piece list list
     * position, int
     * Output: string that prints out x *)
    (let rec ss_help (x : piece list list) (position : int): string =
      match x with
        | [] -> ""
        | hd::tl -> "Column "^(string_of_int position)^": "^
                    (print_column hd)^(ss_help tl (position + 1)) in
       ("The board is: " ^(ss_help b 1)^ ", and it's " ^ 
        (string_of_player p) ^ "'s turn."));;

(* string_of_move
 * Input: Drop n, move
 * Output: a string that correlates to Drop n *)
let string_of_move (Drop n : move) : string =
  "drop in column " ^ string_of_int n;;

let is_off_board (x: int) (y : int) : bool =
  x <= 0 || x > board_size_column || y <= 0 || y > board_size_row;;

is_off_board 6 9;;


(* value_at_xy
 * Input: Board (b), board positive ints, x and y
 * Output: piece at that position x, y in Board (b)*)
let value_at_xy (Board (b) : board) (x : int) (y : int) : piece =
  if is_off_board x y 
  then failwith "value_at_xy: not in the board"
  else List.nth (List.nth b (x-1)) (y-1);;

(* estimate_value
 * Input: State (b, p), state
 * Output: a float the represents the value of the game at passed in state *)
let estimate_value (State (b, pl) : state) : float = 

  let rec run_length (x : int) (y : int) (d : direction) (p : piece) : float =
    if is_off_board x y || value_at_xy b x y != p then 0.
    else 1. +. (match d with
                 | LeftDown -> run_length (x-1) (y+1) d p
                 | Down -> run_length (x) (y+1) d p
                 | RightDown -> run_length (x+1) (y+1) d p
                 | Right -> run_length (x+1) (y) d p) in


    (let run_value (x2 : int) (y2 : int) (d2 : direction): float =

      (let is_blocked (x1 : int) (y1 : int) : bool =
        is_off_board x1 y1 || (value_at_xy b x1 y1 != E) in

         (let length_f = run_length x2 y2 d2 (value_at_xy b x2 y2) in

            (let length_i = int_of_float length_f in

               (match value_at_xy b x2 y2 with
                 | E -> 0.
                 | m ->
                     (match value_at_xy b x2 y2 with
                       | R -> ( *.) (-1.)
                       | B -> ( *.) 1.
                       | E  -> failwith "we already matched against E")
                       (if length_i = 4 then 10000. else
                          (match d2 with
                            | LeftDown -> if is_blocked (x2+1) (y2-1) && is_blocked (x2-length_i) (y2+length_i)
                                then 0.
                                else (if is_blocked (x2+1) (y2-1) || is_blocked (x2-length_i) (y2+length_i) 
                                      then 10. ** length_f /. 2.
                                      else 10. ** length_f)
                            | Down -> if is_blocked x2 (y2-1) && is_blocked x2 (y2+length_i)
                                then 0.
                                else (if is_blocked x2 (y2-1) || is_blocked x2 (y2+length_i) 
                                      then 10. ** length_f /. 2.
                                      else 10. ** length_f)
                            | RightDown -> if is_blocked (x2-1) (y2-1) && is_blocked (x2+length_i) (y2+length_i)
                                then 0.
                                else (if is_blocked (x2-1) (y2-1) || is_blocked (x2+length_i) (y2+length_i) 
                                      then 10. ** length_f /. 2.
                                      else 10. ** length_f)
                            | Right -> if is_blocked (x2-1) (y2) && is_blocked (x2+length_i) (y2)
                                then 0.
                                else (if is_blocked (x2-1) (y2) || is_blocked (x2+length_i) (y2) 
                                      then 10. ** length_f /. 2.
                                      else 10. ** length_f))))))) in

       (* ev_helper
        * Input: Board (b1), board
        * Output: a float list of all the values of the runs in Board (b1) *)

       (let rec ev_helper (x : int) (y : int): float list = 
         (match x, y with
           | c, r when c = board_size_column && r = board_size_row -> []
           | c, r when c = board_size_column -> ev_helper 1 (r+1)
           | c, r when r = board_size_row -> ev_helper (c+1) r
           | c, r ->  ev_helper (c+1) r)@
         (match value_at_xy b x y with
           | E -> []
           | _ -> (run_value x y Right)::
                  (run_value x y LeftDown)::
                  (run_value x y Down)::
                  (run_value x y RightDown)::[]) in
          (let l = List.filter (fun x -> not (x = 0.)) (ev_helper 1 1) in
             (if List.mem (-10000.) l then -10000. else 
                (if List.mem 10000. l then 10000. else 
                   (match List.length l with
                     | 0 -> 0.0
                     | n -> (List.fold_right (+.) l 0.0) /. (float_of_int n)))))));;


(* is_game_over
 * Input: s, state
 * Output: a bool that checks if 4 pieces of the same color are 
 * in a row, somewhere in the board *)
let is_game_over (State (Board b, p) : state) : bool = 
  let rec board_full (x : int) (y : int) : bool =
    ((value_at_xy (Board b) x y) != E) && (match x, y with
                                            | c, r when c = board_size_column -> true
                                            | c, r ->  board_full (c+1) r) in 
    (estimate_value (State (Board b, p))) = 10000.0 || (estimate_value (State (Board b, p))) = (-10000.0) ||
    (board_full 1 1) ;;

(* status_string
 * Input: s, state
 * Output: a string that indicates if the game is in progress or 
 * is the game over *)
let status_string (State (Board b, p) : state) : string =
  if (is_game_over (State (Board b, p)))
  then "Game Over " ^ string_of_player p ^ " Won!"
  else "Game in Progress";;

(* move_of_string
 * Input:  s, string
 * OutputL the move that correlates to s *)
let move_of_string (s : string) : move = 
  Drop (int_of_string (String.make 1 (String.get s 5)));;

(* is_legal_move
 * Input: (State (Board b, p)), state; Drop n, move
 * Output: a bool, checks if Drop n is a move that can be made 
 * within the passed in state *)
let is_legal_move (State (Board b, p) : state) (Drop n : move) : bool =
  if (n > board_size_column) || (n < 1) 
  then failwith "This column does not exist" 
  else (match (List.nth b (n-1)) with 
         | [] -> failwith "why do you have an empty board?"
         | hd::tl -> hd = E);;

(* legal_moves
 * Input:  s, state
 * Output: move list, a list of moves that can be made in the passed in state - s *)
let legal_moves (s : state) : move list =
  (* lm_help
   * Input: col, int
   * Output: goes through every column of the state in the outer function, and 
   * finds all the columns that a piece can be droped into, and reutrns a list
   * of all the possible moves *)
  let rec lm_help (col : int) : move list = 
    match col with
      | 0 -> []
      | n -> if (is_legal_move s (Drop n))
          then (Drop n) :: lm_help (n-1)
          else lm_help (n-1) in
    (lm_help board_size_column);;

(* current_player
 * Input: State (b, p), state
 * Output: the player that is in the passed in state *)
let current_player (State (b, p) : state) : player = p;;

(* next_state
 * Input: State (Board b,p), state; Drop n, move
 * Output: the state after the passed in Drop n is made on the board b *)
let rec next_state (State (Board b, p) : state) (Drop n : move) : state =

  (* find_place
   * Input: col, piece list
   * Output: returns col, but with the (player p)'s - defined in the outer function -
   * piece at the top of the column *)
  let rec find_place (col : piece list) : piece list = 
    match col with
      | [] -> failwith "why is your board empty?"
      | [_] -> [(piece_of_player p)]
      | h1::h2::tl -> 
          if h2 = E 
          then h1::(find_place (h2::tl)) 
          else (piece_of_player p)::h2::tl in 
    (* ns_helper
     * Inptu: pl, piece list list; m, int
     * Output: piece list list, places the piece of the player (defined in the outer function)
     * into the top most Empty spot in column m in pl *)
    (let rec ns_helper (pl : piece list list) (m : int) : piece list list =
      match pl, m with
        | [], 0 -> failwith "you can't replace an empty column"
        | [], _ -> []
        | hd::tl, 0 -> (find_place hd)::tl
        | hd::tl, n -> hd:: (ns_helper tl (n-1)) in 
       State (Board (ns_helper b (n-1)), (match p with 
                                           | P1 -> P2
                                           | P2 -> P1)));;

let s = (State (Board [[E; B; R]; [B; R; R]; [E; E; B]; [R; R; R]], P1));;
let b = Board [[E; B; R]; [B; R; R]; [E; E; B]; [R; R; R]];;
let b1 = Board [[E;E;E;B;R;B;B;B]; [E;E;E;E;E;R;B;R]; [E;E;E;E;R;B;B;R]; [E;E;E;B;R;B;R;B]; [E;R;R;R;B;B;B;R]; [E;E;B;R;R;R;B;R]];;
let s1 = (State (b1, P1));;

next_state s1 (Drop 3);;



(*estimate_value s1;;*)


estimate_value s1;;

initial_state;;

let s2 = State
           (Board
              [[E; E; E; E; E; E; E; B]; 
               [E; E; E; E; R; R; R; R];
               [E; E; E; E; E; E; B; B]; 
               [E; E; E; E; E; E; R; E];
               [E; E; E; E; E; E; B; R]; 
               [E; E; E; E; E; E; R; R]],
            P1);;

estimate_value s2;;
