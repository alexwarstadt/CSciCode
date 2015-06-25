(*#use "game_signature.ml";;*)
#use "/course/cs017/src/ocaml/CS17setup.ml" ;;
(*#use "player_signature.ml";;*)

module type GAME =
sig
  (* TYPES *)

  (* names the players of the game *)
  type player = 
      | P1 
      | P2

  (* expresses the states of the game,
   * i.e., what the board looks like and whose turn it is *)
  type state

  (* describes the game's moves *)
  type move

  (* INITIAL VALUES *)

  (* defines the state at the start of the game *)
  val initial_state : state

  (* TYPE CONVERSIONS *)

  (* returns the name of a player *)
  val string_of_player : player -> string

  (* describes a state in words *)
  val string_of_state : state -> string

  (* describes a move in words *)
  val string_of_move : move -> string

  (* describes the game status (is it over or not),
   * and if it is over, the final outcome *)
  val status_string: state -> string

  (* Tool for a human player. 
   * produces the move that a string represents *)
  val move_of_string : string -> move

  (* GAME LOGIC *)

  (* determines whether a given move is legal in a given state *)
  val is_legal_move : state -> move -> bool

  (* produces the list of allowable moves in a given state *)
  val legal_moves : state -> move list

  (* produces the current player in a given state *)
  val current_player : state -> player

  (* executes the given move and produces the new game state *)
  val next_state : state -> move -> state

  (* estimates value of a given state
   * Remember: positive values are better for P1
   *       and negative values are better for P2 *)
  val estimate_value : state -> float

  (* determines whether the game is over or not given a state *)
  val is_game_over : state -> bool
end ;;


(* We need to have an unbound module in order to test it
 * but the modules we created do fit their respective signatures
 * module Game = (Game : GAME);;
 * module AIPlayer = (AIPlayer : GAME_PLAYER);;*)

module Game =
struct

  (*Columns in Connect Four Game*)
  let board_size_column = 7

  (*Rows in Connect Four Game*)
  let board_size_row = 6

  (* Pieces that make up the board: E for empty; R for Red (P1); 
   * B for Black (P2)*)
  type piece = E | R | B

  (* A list of lists of pieces, each inner list is a column and the outer list
   * is a list of columns of the board
   * The columns are numbered 1 through board_size_column, starting from the left.
   * The rows are numbered 1 through board_size_row, starting from the top*)
  type board = Board of (piece list) list

  (* A player, either P1 (plays based on the minnie algorithm) or 
   * P2 (plays by the max algorithm) *)
  type player = 
      | P1
      | P2

  (* direction, used to describe the direction we are looking in for estimate_value*)
  type direction =
      | Right
      | RightDown
      | Down
      | LeftDown

  (* A State consisting of a board, and the player whose turn it is *)
  type state = State of (board*player)

  (* A move is a Drop of an int, that represents the column that is passed in with Drop *)
  type move = Drop of int

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
      State (Board (is_help board_size_row board_size_column), P1)

  (* pieces_of_player
   * Input: p, player
   * Output: a piece that correlates to p (R is for P1, B is for P2 *)
  let piece_of_player (p : player) : piece =
    match p with 
      | P1 -> R
      | P2 -> B

  (* string_of_player
   * Input: p, player
   * Output: a string that correlates to p *)
  let string_of_player (p : player) : string =
    match p with
      | P1 -> "P1"
      | P2 -> "P2"

  (* print_row
   * Input: pl, piece list list; row, int
   * Output: a string that prints out what each row looks like*)
  let rec print_row (pl : piece list list) (row : int) : string =
    match pl with
      | [] -> ""
      | hd::tl -> (match List.nth hd (row-1) with
                    | E -> "_ "
                    | R -> "X "
                    | B -> "O ") ^ (print_row tl row)

  (* string_of_state
   * Input: (State (Board b, p)), state 
   * Output: a string that prints out the board, and says whose turn it is *)
  let string_of_state (State (Board b, p) : state) : string =
    (* ss_help
     * Input: x, piece list list
     * position, int
     * Output: string that prints out x *)
    (let rec ss_help (x : piece list list) (position : int): string =
      match position with
        | n when n = board_size_column -> ""
        | n -> "Row "^(string_of_int position)^": "^
               (print_row x n)^"\n"^(ss_help x (position + 1)) in
       ("The board is: \n" ^(ss_help b 1)^ " and it's " ^ 
        (string_of_player p) ^ "'s turn."))

  (* string_of_move
   * Input: Drop n, move
   * Output: a string that correlates to Drop n *)
  let string_of_move (Drop n : move) : string =
    "drop in column " ^ string_of_int n

  (* is_off_board
   * Input: x, y - ints
   * Output: bool that indicates if the x,y position in the given board size
   * is not within the boundaries *)
  let is_off_board (x: int) (y : int) : bool =
    x <= 0 || x > board_size_column || y <= 0 || y > board_size_row


  (* value_at_xy
   * Input: Board (b), board positive ints, x and y
   * Output: piece at that position x, y in Board (b)*)
  let value_at_xy (Board (b) : board) (x : int) (y : int) : piece =
    if is_off_board x y 
    then failwith "value_at_xy: not in the board"
    else List.nth (List.nth b (x-1)) (y-1)

  (* run_length
   * Input: b, board; x, y - ints; d, direction; p, piece
   * Output: a float that reflects tells the length of a "run" (consecutive pieces p in a row)
   * starting at (x, y) in board b, in the direction d *)
  let rec run_length (b : board) (x : int) (y : int) (d : direction) (p : piece) : float =
    if is_off_board x y || value_at_xy b x y != p then 0.
    else 1. +. (match d with
                 | LeftDown -> run_length b (x-1) (y+1) d p
                 | Down -> run_length b (x) (y+1) d p
                 | RightDown -> run_length b (x+1) (y+1) d p
                 | Right -> run_length b (x+1) (y) d p)

  (* run_value
   * Input: b, board; x2, y2 - ints; d, direction
   * Output: the value of the "run" (consequetive pieces p in a row) starting 
   * at x2, y2 in the direction d, which takes into account runs that are
   * blocked by an opponents piece or are no longer in the board *)
  let run_value (b: board) (x2 : int) (y2 : int) (d : direction): float =
    (* is_blocked
     * Input: x, y - ints
     * Output: bool that returns true if the x,y position is off the board or 
     * is opponents piece (comparing to the run's start location (x2, y2))*)
    (let is_blocked (x : int) (y : int) : bool =
      is_off_board x y || value_at_xy b x y != E in

       (let length_f = run_length b x2 y2 d (value_at_xy b x2 y2) in
          (let length_i = int_of_float length_f in
             (if value_at_xy b x2 y2 = E 
              then 0.
              else
                (match value_at_xy b x2 y2 with
                  | R -> ( *.) (-1.)
                  | B -> ( *.) 1.
                  | E  -> failwith "we already matched against E")
                  (if length_i >= 4 then 10000. else
                     (match d with
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
                                 else 10. ** length_f)))))))
  (* ev_helper
   * Input: b, board
   * Output: a float list of all the values of the board that represent the
   * runs in board b *)
  let ev_helper (b: board) : float list =
    (* _ev_helper
     * Input: b, board; x, y - ints
     * Output: float list that represents all the run value estimations starting 
     * from x, y *)
    let rec _ev_helper (b : board) (x : int) (y : int): float list = 
      (match x, y with
        | c, r when c = board_size_column && r = board_size_row -> []
        | c, r when c = board_size_column -> _ev_helper b 1 (r+1)
        | c, r when r = board_size_row -> _ev_helper b (c+1) r
        | c, r ->  _ev_helper b (c+1) r) @ 
      (match value_at_xy b x y with
        | E -> []
        | _ -> (run_value b x y Right)::
               (run_value b x y LeftDown)::
               (run_value b x y Down)::
               (run_value b x y RightDown)::[]) in
      _ev_helper b 1 1

  (* estimate_value
   * Input: State (b, p), state
   * Output: a float the represents the value of the game at the passed in state *)
  let estimate_value (State (b, pl) : state) : float = 
    let l = List.filter (fun x -> not (x = 0.)) (ev_helper b) in
      (if List.mem (-10000.) l then -10000. else 
         (if List.mem 10000. l then 10000. else 
            (match List.length l with
              | 0 -> 0.0
              | n -> (List.fold_right (+.) l 0.0) /. (float_of_int n))))

  (* board_full
   * Input: b, board
   * Output: bool that indicates if the board b is full
   * with R and B pieces*)
  let board_full (b: board) : bool =
    (* _board_full
     * Input: b, board; x, y - ints
     * Output: bool that indicates if the board b is full
     * with R and B pieces starting at x y and traversing the rest of the y row*)
    let rec _board_full (b : board) (x : int) (y : int) : bool =
      (((value_at_xy b x y) != E) && (match x with
                                        | c when c = board_size_column -> true
                                        | c ->  _board_full b (c+1) y)) in
      _board_full b 1 1

  (* is_game_over
   * Input: s, state
   * Output: a bool that checks if at least 4 pieces of the same color are 
   * in a row, somewhere in the board *)
  let is_game_over (State(b, p) : state) : bool = 

    (estimate_value (State(b, p))) >= 10000.0 || (estimate_value (State(b, p))) <= (-10000.0) ||
    (board_full b)


  (* status_string
   * Input: s, state
   * Output: a string that indicates if the game is in progress or 
   * if the game is over, and whether there is a tie, or which player won *)
  let status_string (State (b, p) : state) : string =
    match estimate_value (State(b, p)) with 
      | ev when ev <= (-10000.) -> "P1 Won!"
      | ev when ev >= 10000. -> "P2 Won!"
      | _ -> if (board_full b) then "It's a tie!" else "Game in Progress"

  (* move_of_string
   * Input: s, string
   * Output: the move that correlates to s *)
  let move_of_string (s : string) : move = 
    Drop (int_of_string s)

  (* is_legal_move
   * Input: (State (Board b, p)), state; Drop n, move
   * Output: a bool, checks if Drop n is a move that can be made 
   * within the passed in state *)
  let is_legal_move (State (Board b, p) : state) (Drop n : move) : bool =
    if (n > board_size_column) || (n < 1) 
    then failwith "This column does not exist" 
    else (match (List.nth b (n-1)) with 
           | [] -> failwith "why do you have an empty board?"
           | hd::tl -> hd = E)

  (* legal_moves
   * Input:  s, state
   * Output: move list, a list of moves that can be made in the passed in state - s *)
  let legal_moves (s : state) : move list =
    (* lm_help
     * Input: col, int
     * Output: goes through every column of the state in the outer function, and 
     * finds all the columns that a piece can be droped into, and returns a list
     * of all the possible moves *)
    let rec lm_help (col : int) : move list = 
      match col with
        | 0 -> []
        | n -> if (is_legal_move s (Drop n))
            then (Drop n) :: lm_help (n-1)
            else lm_help (n-1) in
      (lm_help board_size_column)

  (* current_player
   * Input: State (b, p), state
   * Output: the player that is in the passed in state *)
  let current_player (State (b, p) : state) : player = p

  (* next_state
   * Input: State (Board b,p), state; Drop n, move
   * Output: the state after the passed in (Drop n) move is made on the board b *)
  let rec next_state (State (Board b, p) : state) (Drop n : move) : state =

    (* find_place
     * Input: col, piece list
     * Output: returns col, but with the (player p)'s piece - defined in the outer function -
     * on top of the existing pieces *)
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
                                             | P2 -> P1)))

end ;;

(*TESTING*)
open Game;;
(*
let b1 = Board [[E; E; E; E; E; R];
[E; E; E; B; R; R];
[E; R; R; B; R; B];
[E; R; B; R; B; R];
[E; E; E; E; B; B];
[E; R; B; B; R; B];
[E; E; R; B; R; B]];;

let b2 = Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]];;

(*initial_state*)
check_expect initial_state (State (b2, P1));;

(*piece_of_player*)
check_expect (piece_of_player P1) R;;
check_expect (piece_of_player P2) B;;

(*string_of_player*)
check_expect (string_of_player P1) "P1";;
check_expect (string_of_player P2) "P2";;

(*print_row*)
check_expect (print_row [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; B; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]] 1)
"E E E E E E E ";;
check_expect (print_row [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; B; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]] 5)
"E E B E E E E ";;
check_expect (print_row [[E; E; R; E; E; E];
[E; E; E; E; E; E];
[E; E; R; E; B; R];
[E; E; B; E; E; E];
[E; E; B; E; E; E];
[E; E; R; E; E; E];
[E; E; E; E; E; E]] 3)
"R E R B B R E ";;

(*string_of_state*)
check_expect (string_of_state (State (b2, P1)))
("The board is: " ^
"\nRow 1: E E E E E E E " ^
"\nRow 2: E E E E E E E " ^
"\nRow 3: E E E E E E E " ^
"\nRow 4: E E E E E E E " ^
"\nRow 5: E E E E E E E " ^
"\nRow 6: E E E E E E E " ^
"\n and it's P1's turn.");;

check_expect (string_of_state (State (b1, P2)))
("The board is: " ^
"\nRow 1: E E E E E E E " ^
"\nRow 2: E E R R E R E " ^
"\nRow 3: E E R B E B R " ^
"\nRow 4: E B B R E B B " ^
"\nRow 5: E R R B B R R " ^
"\nRow 6: R R B R B B B " ^
"\n and it's P2's turn.");;

(*string_of_move*)
check_expect (string_of_move (Drop 1)) "drop in column 1" ;;
check_expect (string_of_move (Drop 2)) "drop in column 2" ;;
check_expect (string_of_move (Drop 3)) "drop in column 3" ;;
check_expect (string_of_move (Drop 4)) "drop in column 4" ;;
check_expect (string_of_move (Drop 5)) "drop in column 5" ;;
check_expect (string_of_move (Drop 6)) "drop in column 6" ;;
check_expect (string_of_move (Drop 7)) "drop in column 7" ;;
check_expect (string_of_move (Drop 100)) "drop in column 100" ;;

(*is_off_board*)
check_expect (is_off_board 1 1) false ;;
check_expect (is_off_board 0 1) true ;;
check_expect (is_off_board 0 0) true ;;
check_expect (is_off_board 7 6) false ;;
check_expect (is_off_board 7 7) true ;;
check_expect (is_off_board 100 0) true ;;

(*value_at_xy*)
check_expect (value_at_xy b1 1 6) R ;;
check_expect (value_at_xy b1 1 1) E ;;
check_expect (value_at_xy b1 4 3) B ;;
check_error (fun x -> value_at_xy b1 1 0) "value_at_xy: not in the board" ;;

(*run_length*)
check_expect (run_length b1 3 4 RightDown B) 3.;;
check_expect (run_length b1 3 2 Down R) 2.;;
check_expect (run_length b1 3 2 Down B) 0.;;
check_expect (run_length b1 5 6 Down B) 1.;;
check_expect (run_length b1 3 4 LeftDown B) 1.;;
check_expect (run_length b1 6 5 Right R) 2.;;
check_expect (run_length (let State (b, s) = (next_state (State (b1, P2)) (Drop 2)) in b) 2 3 RightDown B) 4.;;

(*run_value*)
check_expect (run_value b1 3 4 RightDown) 500.;;
check_expect (run_value b1 3 2 Down) (-50.);;
check_expect (run_value b1 5 6 Down) 0.;;
check_expect (run_value b1 3 4 LeftDown) 0.;;
check_expect (run_value b1 6 5 Right) 0.;;
check_expect (run_value (let State (b, s) = (next_state (State (b1, P2)) (Drop 2)) in b) 2 3 RightDown) 10000.;;
check_expect (run_value (Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]) 4 6 Right) 10.;;
check_expect (run_value (Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]) 3 6 Right) (-100.);;
check_expect (run_value (Board [[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]) 1 6 Right) (-10000.);;

(* ev_helper*)
check_expect (ev_helper (Board [[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]])) 
[-5.; -5.; -5.; -5.; -50.; -5.; -5.; -5.; -500.; -5.; -5.; -5.; (-10000.); -5.; -5.; -5.; (-10000.); -5.; -5.; 0.];;
check_expect (ev_helper b2) [];;
check_expect (ev_helper (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; R; R; R];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]))
[5.; 5.; 5.; 0.; 0.; -5.; 0.; 0.; 5.; 0.; 0.; 5.; -5.; -5.; 0.; -5.; 5.; 5.; 50.; 5.; -10.; -5.; -500.; -10.];;

(* estimate_value *)
check_expect (estimate_value (State ((Board [[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P1))) (-10000.);;
check_expect (estimate_value (State ((Board [[R; B; R; B; R; R];
[E; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]]), P2))) (-10000.);;
check_expect (estimate_value (State (b1, P1))) (-2.70270270270270263);;
check_expect (estimate_value (State ((Board [[E; E; E; E; E; R];
[E; E; E; E; E; B];
[E; E; E; B; B; R];
[E; E; E; E; E; B];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; R]]), P2))) 7.04545454545454586;;
check_expect (estimate_value (State ((Board [[E; E; E; R; R; R];
[E; E; E; E; E; B];
[E; E; E; B; B; R];
[E; E; E; E; E; B];
[E; E; E; E; E; R];
[E; E; E; R; R; B];
[E; E; E; E; E; R]]), P2))) (-17.0967741935483879);;
check_expect (estimate_value (State ((Board [[E; E; E; B; B; R];
[E; E; E; B; R; B];
[E; E; E; R; R; B];
[E; E; E; R; B; B];
[E; E; E; E; R; R];
[E; E; E; R; R; B];
[E; E; E; E; E; R]]), P2))) (-35.);;
check_expect (estimate_value (State ((Board [[B; R; B; R; B; R];
[R; B; R; R; B; R];
[R; B; R; B; R; B];
[B; B; R; R; B; B];
[R; R; B; R; B; R];
[B; B; R; R; B; R];
[B; R; B; B; R; B]]), P1))) 0.;;

(* board_full *)
check_expect (board_full (Board [[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]])) false;;
check_expect (board_full (Board [[R; B; R; B; R; R];
[B; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]])) true;;
check_expect (board_full (Board [[R; B; R; B; R; R];
[E; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]])) false;;

(*is_game_over*)
check_expect (is_game_over (State (b1, P1))) false;;
check_expect (is_game_over (State ((Board [[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P2))) true;;
check_expect (is_game_over (State ((Board [[E; E; E; E; E; E];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P2))) true;;
check_expect (is_game_over (State ((Board [[R; B; R; B; R; R];
[B; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]]), P2))) true;;

(* status_string *)
check_expect (status_string (State (b1, P1))) "Game in Progress";;
check_expect (status_string (State ((Board [[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P2)))
"P1 Won!";;
estimate_value (State ((Board [[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P1));;
check_expect (status_string (State ((Board [[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P1))) 
"P2 Won!";;
check_expect (status_string (State ((Board [[B; R; B; R; B; R];
[R; B; R; R; B; R];
[R; B; R; B; R; B];
[B; B; R; R; B; B];
[R; R; B; R; B; R];
[B; B; R; R; B; R];
[B; R; B; B; R; B]]), P1))) 
"It's a tie!";;
check_expect (status_string (State ((Board [[E; E; R; B; B; B];
[E; R; B; R; R; B];
[E; B; R; B; R; R];
[E; R; B; B; R; R];
[E; R; E; B; B; R];
[E; E; E; R; E; R];
[E; E; E; E; B; R]]), P2))) 
"P1 Won!";;

(* move_of_string *)
check_expect (move_of_string "8") (Drop 8);;
check_expect (move_of_string "2") (Drop 2);;
check_expect (move_of_string "81") (Drop 81);;

(* is_legal_move *)
check_expect (is_legal_move (State ((Board [[E; B; R; B; R; R];
[B; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]]), P2)) (Drop 1)) true;;
check_expect (is_legal_move (State ((Board [[R; B; R; B; R; R];
[B; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]]), P2)) (Drop 2)) false;;
check_expect (is_legal_move (State ((Board [[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P1)) (Drop 6)) true;;
check_error (fun x -> is_legal_move (State ((Board [[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P1)) (Drop 8)) 
"This column does not exist";;
check_error (fun x -> is_legal_move (State ((Board [[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]]), P1)) (Drop 0)) 
"This column does not exist";;

(* legal_moves *)
check_expect (legal_moves (State ((Board [[R; B; R; B; R; R];
[B; R; B; B; R; B];
[R; B; R; B; R; R];
[R; R; B; B; R; B];
[R; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]]), P2))) [];;
check_expect (legal_moves (State ((Board [[E; B; R; B; R; R];
[B; R; B; B; R; B];
[E; B; R; B; R; R];
[R; R; B; B; R; B];
[E; R; B; B; B; R];
[B; R; B; R; B; R];
[B; B; B; R; B; R]]), P2))) 
[Drop 5; Drop 3; Drop 1];;
check_expect (legal_moves (State ((Board [[E; B; R; B; R; R];
[E; R; B; B; R; B];
[E; B; R; B; R; R];
[E; R; B; B; R; B];
[E; R; B; B; B; R];
[E; R; B; R; B; R];
[E; B; B; R; B; R]]), P2))) 
[Drop 7; Drop 6; Drop 5; Drop 4; Drop 3; Drop 2; Drop 1];;

(* current_player *)
check_expect (current_player (State (b1, P1))) P1;;
check_expect (current_player (State (b1, P2))) P2;;

(* next state *)
check_expect (next_state (State ((Board [[E; B; R; B; R; R];
[E; R; B; B; R; B];
[E; B; R; B; R; R];
[E; R; B; B; R; B];
[E; R; B; B; B; R];
[E; R; B; R; B; R];
[E; B; B; R; B; R]]), P2)) (Drop 3))
(State ((Board [[E; B; R; B; R; R];
[E; R; B; B; R; B];
[B; B; R; B; R; R];
[E; R; B; B; R; B];
[E; R; B; B; B; R];
[E; R; B; R; B; R];
[E; B; B; R; B; R]]), P1));;
check_expect (next_state (State ((Board [[E; E; E; E; R; R];
[E; R; B; B; R; B];
[E; B; R; B; R; R];
[E; R; B; B; R; B];
[E; R; B; B; B; R];
[E; R; B; R; B; R];
[E; B; B; R; B; R]]), P1)) (Drop 1))
(State ((Board [[E; E; E; R; R; R];
[E; R; B; B; R; B];
[E; B; R; B; R; R];
[E; R; B; B; R; B];
[E; R; B; B; B; R];
[E; R; B; R; B; R];
[E; B; B; R; B; R]]), P2));;*)




module type GAME_PLAYER =
sig
  open Game

  (* given a state, and decides which legal move to make *)
  val next_move : state -> move
end ;;

(* Fill in the code for your AI player here. *)
(* Note that your AI player simply needs to decide on its next move.
 * It does not have to worry about printing to the screen or any of
 * the other silliness in the HumanPlayers's chunk of code. *)


module AIPlayer =
struct
  open Game

  (* Difficulty of AI Player:
   * Number of levels you go down to estimate next move*)
  let difficulty = 5

  (* minnie_max
   * Input: level, int; s, state
   * Output: float that implementing the minnie_max algorithm, estimates the state
   * looking level down*)
  let rec minnie_max (level : int) (s : state) : float =
    match level with
      | 1 -> Game.estimate_value s
      | l -> let value1 = (List.map 
                             (fun x -> Game.next_state s x) 
                             (legal_moves s)) in
            match List.filter Game.is_game_over value1 with
              | [] -> let value2 = (List.map (fun x -> minnie_max (l-1) x) value1) in
                    (match Game.current_player s with 
                      | P1 -> List.fold_left min 10001. value2
                      | P2 -> List.fold_left max (-10001.) value2)
              | _::_ -> (match Game.current_player s with 
                          | P1 -> (-10000.)
                          | P2 -> 10000.)

  (* nm_helper
   * Input: s, state at which the game is NOT over
   * Output: move that implementing the minnie-max algorthim will be the best move for the
   * current_player of s*)
  let nm_helper (s : state) : move =
    let list_of_state : (Game.move * float) list = List.map 
                                                     (fun x -> (x, (minnie_max difficulty (next_state s x))))
                                                     (legal_moves s) in

      (let min_move ((n, m) : Game.move * float) ((i, j) : Game.move * float) : (Game.move * float) = 
        if (m <= j) then (n, m) else (i, j) in
         (let max_move ((n, m) : Game.move * float) ((i, j) : Game.move * float) : (Game.move * float) = 
           if (m >= j) then (n, m) else (i, j) in

            (let (a, b) = 
              (match Game.current_player s with
                | P1 -> List.fold_left min_move (move_of_string "1", 10001.) list_of_state
                | P2 -> List.fold_left max_move (move_of_string "1", (-10001.)) list_of_state) in a)))

  (* next_move
   * Input: s, state
   * Output: move that implementing the minnie-max algorithm for s, will bring the best outcome
   * for the current_player of s*)
  let next_move (s : state) : move = 
    match List.filter (fun x -> Game.is_game_over (Game.next_state s x)) (legal_moves s) with
      | [] -> nm_helper s
      | a::b -> a

end ;;

open AIPlayer;;
open Game;;(*
let s1 = State (Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P1);;
let s2 = State (Board [[E; E; E; E; E; R];
[E; E; E; B; R; R];
[E; R; R; B; R; B];
[E; R; B; R; B; R];
[E; E; E; E; B; B];
[E; R; B; B; R; B];
[E; E; R; B; R; B]], P2);;
let s3 = State (Board [[E; E; E; E; E; R];
[E; E; E; B; R; R];
[E; R; R; B; R; B];
[E; R; B; R; B; R];
[E; E; E; E; B; B];
[E; R; B; B; R; B];
[E; E; R; B; R; B]], P1);;
let s4 = State (Board [[E; E; E; E; E; E];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2);;

(* minnie_max cases *)
check_expect (minnie_max 1 s2) (Game.estimate_value s2);;
check_expect (minnie_max 2 s2) 10000.;;
check_expect (minnie_max 4 (State (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; R; B; R];
[E; E; E; B; R; R];
[E; E; E; R; B; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(10000.);;
check_expect (minnie_max 4 (State (Board [[E; E; E; E; R; R];
[E; E; E; E; E; R];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2))) (-9.33333333333333393);;
check_expect (minnie_max 1 s1) (Game.estimate_value (State (Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P1)));;

(* nm_helper *)
check_expect (nm_helper s1) (Drop 6);;
check_expect (nm_helper (State (Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; R; B];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; R]], P2)))
(Drop 2);; (*right*)
check_expect (nm_helper (State (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; E; R; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P1)))
(Drop 2);; (*down*)
check_expect (nm_helper (State (Board [[E; E; E; R; B; R];
[E; E; E; E; R; B];
[E; E; E; R; B; R];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(Drop 2);; (*downleft*)
check_expect (nm_helper (State (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; R; B; R];
[E; E; E; E; R; R];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(Drop 4);; (*downright*)


(* next_move cases *)
check_expect (next_move s1) (Drop 6);;
check_expect (next_move (State (Board [[E; E; E; E; E; R];
[E; E; E; B; R; R];
[E; R; R; B; R; B];
[E; R; B; R; B; R];
[E; E; E; E; B; B];
[E; R; B; B; R; B];
[E; E; R; B; R; B]], P2)))
(Drop 5);; (*will it make the move if they can win*)
check_expect (next_move (State (Board [[E; E; E; E; E; E];
[E; E; E; E; R; B];
[E; E; E; E; R; B];
[E; E; E; E; R; B];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(Drop 1);; (*right*)
check_expect (next_move (State (Board [[E; E; E; E; E; E];
[E; E; E; B; B; B];
[E; E; E; R; R; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P1)))
(Drop 3);; (*down*)
check_expect (next_move (State (Board [[E; E; E; R; B; R];
[E; E; E; B; R; B];
[E; E; E; R; B; R];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; R]], P2)))
(Drop 1);; (*downleft*)
check_expect (next_move (State (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; R; B; R];
[E; E; E; B; R; R];
[E; E; E; R; B; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(Drop 5);; (*downright*)
check_expect (next_move (State (Board [[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; B];
[E; E; E; E; R; B];
[E; E; E; E; E; R];
[E; E; E; E; E; E];
[E; E; E; E; E; R]], P2)))
(Drop 2);; (*right*)
check_expect (next_move (State (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; E; R; R];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P1)))
(Drop 2);; (*down*)
check_expect (next_move (State (Board [[E; E; E; R; B; R];
[E; E; E; E; R; B];
[E; E; E; R; B; R];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(Drop 2);; (*downleft*)
check_expect (next_move (State (Board [[E; E; E; E; E; E];
[E; E; E; E; B; B];
[E; E; E; R; B; R];
[E; E; E; E; R; R];
[E; E; E; E; E; B];
[E; E; E; E; E; E];
[E; E; E; E; E; E]], P2)))
(Drop 4);; (*downright*)*)


(* The HumanPlayer makes its moves based on user input.
 * We've written this player for you because it uses some imperative language constructs. *)
module HumanPlayer : GAME_PLAYER =
struct
  open Game

  let move_string state =
    (string_of_player (current_player state)) ^ ", please type your move: "

  let bad_move_string str =
    "Bad move for this state: " ^ str ^ "!\n"

  let rec next_move state =
    print_string (move_string state);
    flush stdout;

    try
      let str = (input_line stdin) in
      let new_move = move_of_string str in
        if (is_legal_move state new_move) then new_move
        else (print_string (bad_move_string str); next_move state)
    with 
      | End_of_file -> (print_endline "\nEnding game"; exit 1)
      | _ -> (print_endline "That move makes no sense!"; next_move state)
end ;;

(* The Referee coordinates the other modules. 
 * Invoke start_game to start playing a game. *)
module Referee =
struct
  open Game

  module Player1 = HumanPlayer
  module Player2 = AIPlayer

  let game_on_string player move =
    (string_of_player player) ^ " decides to make the move " ^ (string_of_move move) ^ "."

  let rec play state =
    print_endline (string_of_state state);
    if (is_game_over state) then (print_endline 
                                    ("Game over! Final result: " ^ (status_string state)); ())
    else let player = current_player state in
      let move = (match player with
                   | P1 -> Player1.next_move state
                   | P2 -> Player2.next_move state) in
        print_endline (game_on_string player move);
        play (next_state state move)

  let start_game () = play (initial_state)
end ;;

Referee.start_game () ;;
