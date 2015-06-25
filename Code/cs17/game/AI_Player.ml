#use "player_signature.ml" ;;
#use "~/course/cs017/projects/game/game.ml" ;;

(* Fill in the code for your AI player here. *)
(* Note that your AI player simply needs to decide on its next move.
 * It does not have to worry about printing to the screen or any of
 * the other silliness in the HumanPlayers's chunk of code. *)

open Game ;;

type state = Game.state ;;

module AIPlayer : GAME_PLAYER =
struct

  (* Difficulty of AI Player:
   * Number of levels you go down to estimate next move*)
  let difficulty = 3

  let next_move (s : state) = 
    let rec minnie_max (level : int) (State (b, pl1) : state) : float =
      match level with
        | 0 -> Game.estimate_value (State (b, pl1))

        | l -> let value = (List.map 
                              (fun x -> minnie_max (l-1) x) 
                              (List.map 
                                 (fun x -> Game.next_state (State (b, pl1)) x) 
                                 (legal_moves (State (b, pl1))))) in
              (match pl1 with 
                | P1 -> List.fold_left min value 10000.
                | P2 -> List.fold_left max value (-10000.)) in 
      (let list_of_state = List.map 
                             (fun x -> (x, (minnie_max difficulty (Game.next_state (State (b, pl)) x)))) 
                             (legal_moves (State (b, pl))) in

         (let min_move ((n, m) : Game.move * float) ((i, j) : Game.move * float) : (Game.move * float) = 
           if (m =< j) then (n, m) else (i, j) in

            (let max_move ((n, m) : Game.move * float) ((i, j) : Game.move * float) : (Game.move * float) = 
              if (m >= j) then (n, m) else (i, j) in

               (let (a, b) = 
                 (match pl with
                   | P1 -> List.fold_left min_move (1, 10000.) list_of_state
                   | P2 -> List.fold_left max_move (1, (-10000.)) list_of_state) in a))))
end ;;
