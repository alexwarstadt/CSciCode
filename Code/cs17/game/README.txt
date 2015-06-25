To interact with game, a user would run our game.ml file in terminal. It always tells the user who's turn it is and what the move and state at each preceding turn was. The board is printed at each turn and indicates the number of every column. The user makes a move by typing "n", where n is the number of the column she wishes to drop her piece in. P1 is represented on the board by R, P2 by B, and an empty slot by E. The game informs the user at each turn whether the game is in progress, whether a certain player has won, or whether there is a tie. The board is represented with rows horizontally and the columns numbered from left to right.

The user can open game.ml in a text editor to take advantage of some changeable features. In the TestGame module (we set this module equal to Game later in the file), the user can change the size of the board by altering the values board_size_row for the number of rows and board_size_column for the number of columns. She can also alter the nature of the players in the Referee module by setting both Player1 and Player 2 to either HumanPlayer, for a human player, or AIPlayer, for a computer player. Finally, the user can alter the difficulty of the computer player in the AIPlayer module by changing the value of difficulty. This feature changes the number of moves into the future that the AIPlayer can "look". The user should be warned that difficulty 3 is quite easy, and difficulty 6 runs quite slowly with a standard 7 x 6 board. Boards with more columns also cause the AIPlayer to run more slowly.

Our Game module contains the number of columns and rows in the board, as discussed above. Next it defines a type piece that is either E for an empty slot, R for P1's pieces, and B for P2's pieces. It defines a Board as a list of lists of pieces, where each list of pieces is a row. The rows are numbered from the top down and columns from left to right. It defines the players as P1 and P2. It defines four directions on the board: Right, RightDown, Down, and LeftDown which describe the possible directions in which there can be a "run" of pieces. "Run" is not a type that we define, but it is loosely some number of the same piece that are adjacent horizontally, vertically, or diagonally in some direction starting from a coordinate on the board. We define a state as a tuple of a board a player who's turn it is. We define a move with the constructor Drop and an int corresponding the column in which the player is dropping a piece.

Our initial state is a board with the board_size_column number of columns and board_size_row number of rows in which each piece is E and P1. It uses the helper make_column which constructs a list of E pieces of length board_size_row and the helper is_help which makes a list of lists of pieces by calling make_column board_size_column number of times.

piece_of_player returns a string, "P1" or "P2" given a player.

string_of_state "prints" the state as a string. It names the player who's turn it is and creates a string representation of the board in which each column is numbered column 1, column 2, etc and position on the board is either "E" if it is empty, or "B" or "R" depending on which piece is in the position. The columns are represented vertically with column 1 at the left and top row at the top. The helper print_column creates a string out of each column and the helper ss_help calls print_column recursively to create a larger string containing every column with its number.

string_of_move "prints" a move as a string "drop in column n" where n is the int in the Drop constructor.

is_off_board takes an x and a y coordinate and returns true if the position indicated is not a position on the board by comparing the values to board_size_column and board_size_row, respectively.

value_at_xy takes a board and a x and y coordinates as ints and returns the piece in the xth column and the yth row. If the position is not on the board (which it checks by calling is_off_board), it returns an error.

run_length is a helper for estimate_value. Starting at an x y coordinate in a certain board and given a direction and a piece, it returns a float equal to the length of the run of that piece in the given direction.

run_value is a helper for estimate_value. Starting at an x y coordinate in a certain board and given a direction, it assigns a float value to the run from that position. If the value at that position is E, it just returns 0. Otherwise it first calls run_length to determine the length of the run. If the run is of length 4 or greater, it assigns the value 10000. Otherwise, it uses the helper is_blocked which given x and y coordinates checks to see if that position is off the board or contains a piece other than empty, and thus is not a potential slot to drop a piece into. With this helper, run_value checks to see if both ends of the run are "blocked" in which case it assigns the value 0. If only one side is blocked, it raises 10 to the power of the length of the run and divides by 2, and if both sides are not blocked it returns 10 to the power of the length of the run. Finally, if the run is of piece R it multiples the value by -1.

ev_helper is a helper to estimate_value. It recurrs through the board calling run_value in each direction at each position on the board and constructs a list of all the values of each run. It does not call run_value on empty positions.

estimate_value calls ev_helper on a state, and then filters that list for all non-zero values. Then, it calculates the average of the filtered list to return a single float value for the board that indicates who is winning. A negative value indicates that P1 is winning and a positive value that P2 is winning.

board_full is a helper for is_game_over. It checks the top row of the board for any empty slots and returns true if there are no empty slots.

is_game_over returns true if either estimate_value returns a value of 10000. or -10000, or if the board is full.

status_string calls is_game_over. If not, it returns "game in progress," if it is, if the estimate_value value of the state is 10000 or -10000 it returns a string saying which player one, otherwise it says "it's a tie!".

move_of_string takes a string containing the number of the column in which the player is dropping her piece and turns it into a move containing that number.

is_legal_move takes a state and a move and returns true if the move is possible, i.e. if the column is not full.

legal_moves uses the helper lm_help which tests if Drop of every number from 1 to some number is a legal move, and if so adds that move to a list of moves. legal_moves calls lm_help on board_size_column to test.

current_player takes a state and returns the player who's turn it is.

next_state uses the helper find_place, which given a piece list corresponding to a column traverses the list until it finds the last empty slot in the column, then replaces E with the piece corresonding to the current player. ns_helper then recurs through the columns of the board until it finds the column that the piece is being dropped into, and then replaces that column with the new column formed by calling find_place on that column. Finally, next_state makes a state out of the ns_helper called on the list of list of pieces in the state and the player who is not the current player.
      
In our AIPlayer module, we define a difficulty as in int that corresponds to the depth of the minimax tree, or the number of moves into the future the AI "sees".

minnie_max takes an int level equal to the number of levels into the future to see and a state and returns a float equal to the the value of the minimax algorithm at that state looking level moves into the future.

nm_helper constructs a list of tuples containing a move and the minnie_max value of the next state if that move is taken. It then uses the helpers min_move or max_move depending on whose turn it is to find the best move in the list and return that move.

next_move first checks if there is an immediate move that will result in a win, and then makes that move. If not, it calls nm_helper on the state.

We collaborated only with each other, and did not discuss the project with anyone else, or access any resources not provided by the course.

We don't know of any bugs in our program.

Extra features we implemented include that the user can change the size of the board. Also, the user can change the difficulty of the AIPlayer.
