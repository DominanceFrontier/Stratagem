
var Match = function(player1_ip, player2_ip)
{
	this.game  = new CheckersGame();
	this.board = new Board(BOARD_ROWS, BOARD_COLS, 
	                       this.game.turn_values, null);
	
	// Flag to store if the game is over
	this.game_over = false;
	
	// Represents who won, either player 0
	// or player 1
	this.winner = 0;

	// Characters which represent a turn
	var turn_chars = this.game.turn_values;

	// A list of the move sequences
	this.move_history = [];

	// A running sequence of moves for the 
	// current turn 
	this.move_sequence = [];

	// A list of possible moves for the current
	// move. Each item is an object of the form
	// { src: { r: int, c: int }, dst: { r: int, c: int } }
	// where src is the piece which can be moved, and
	// dst is the place that piece can be moved to
	this.possible_moves = [];

	// A collection of pieces for the match.
	// Includes each player's pieces
	this.pieces = [];

	// Initial state in 2-D array form 
	// for the purpose of loading the board
	this.simple_init_state = [
	  [' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0]],
	  [turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' '],
	  [' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0]],

	  [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
	  [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],

	  [turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' '],
	  [' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1]],
	  [turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' '],
	];

	// Test init state to show kinging
	// this.simple_init_state = [
	this.simple_init_state = [
	  [' ', turn_chars[0], ' ', ' ', ' ', turn_chars[0], ' ', turn_chars[0]],
	  [' ', ' ', turn_chars[1], ' ', turn_chars[0], ' ', turn_chars[0], ' '],
	  [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],

	  [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],
	  [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],

	  [turn_chars[1], ' ', ' ', ' ', ' ', ' ', ' ', ' '],
	  [' ', turn_chars[0], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1]],
	  [' ', ' ', ' ', ' ', turn_chars[1], ' ', turn_chars[1], ' '],
	];

	// Test state for showing that when no one has a move,
	// the winner goes to the other end
	// this.simple_init_state = [
	//   [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '],

	//   [turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' '],
	//   [' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0]],
	//   [turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' ', turn_chars[0], ' '],

	//   [' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1]],
	//   [turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' '],
	//   [' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1], ' ', turn_chars[1]],

	//   [' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ']
	// ];


	this.turn = 0;

	// The state of the game
	// 0 = no piece selected (needs user to click on one 
    // of their pieces to switch state to 1)
	// 1 = piece selected (needs user to click on an empty
	// square which is part of their possible moves to switch
	// the state back to 0)
	this.state = 0;

	// An object of the form
	// { r: int, c: int }
	// which represents the position of a user's piece
	// which they have selected
	this.pos0 = null;

	// An object of the form
	// { r: int, c: int }
	// which represents the position the user chose 
	// to move the piece at this.pos0 to 
	this.pos1 = null;

	this.board.init();
	this.init();
};

// Checks if there is a piece on the board at
// row r and column c. Used in the CheckersView
// to only send the position clicked to the Match
// if there's a piece on the square that the user clicked
// on. This is used when this.state = 0
Match.prototype.is_possible_src = function(r, c)
{
	var i = 0;
	for (i = 0; i < this.possible_moves.length; i++)
	{
		if (this.possible_moves[i].src.r == r &&
			this.possible_moves[i].src.c == c)
			return true;
	}
	return false;
};

// Create the pieces based on the
// description of the initial state
// and create the associations between 
// the piece and a tile on the board
Match.prototype.init = function()
{
	for (i = 0; i < this.board.rows; i++)
	{
		for (j = 0; j < this.board.cols; j++)
		{
			if (this.simple_init_state[i][j] != ' ')
			{
				var p = new CheckersPiece(this.simple_init_state[i][j]);
				var t = this.board.arr[i][j];
				this.pieces.push(p);
				this.board.add_piece(p, i, j);
			}
		}
	}

	// Get the possible moves for the current turn
	this.possible_moves = this.game.possible_moves(this.board, this.game.turn_values[this.turn]);

	if (this.possible_moves.length == 0)
	{
		this.game_over = true;
		this.winner = (this.turn == 0) ? this.game.turn_values[1] : this.game.turn_values[0];
	}
};

// Checks if the game is over. 
// Used after a piece is jumped
// in the Match.get_notification(pos) function.
// It just counts the number of pieces on the board with the value for 
// turn 0 and the number of pieces with the value for 
// turn 1. If both are 0, then the game is over
Match.prototype.is_over = function()
{
	var p1count = 0, p2count = 0;

	for (key in this.board.piece_tile_assocs)
	{
		if (this.board.piece_tile_assocs.hasOwnProperty(key))
		{
			if (this.board.piece_tile_assocs[key].piece.value == this.game.turn_values[0])
				p1count++;
			else if (this.board.piece_tile_assocs[key].piece.value == this.game.turn_values[1])
				p2count++;
		}
	}

	return p1count == 0 || p2count == 0;
};

// Switches the turn and stores
// this.move_sequence into this.move_history 
Match.prototype.switch_turn = function()
{
	this.turn = (this.turn == 0) ? 1 : 0;
	this.move_history.push(this.move_sequence);
	this.move_sequence = [];
	// console.log(this.move_history);
}

// A function that's called by the CheckersView
// when the user clicks on a valid tile (validity
// of the tile is based on the game state)
Match.prototype.get_notification = function(pos)
{
	// Don't check for a move if the game 
	// is over 
	if (this.game_over)
		return;

	// If no piece has been selected yet
	if (this.state == 0)
	{
		// Store the selected piece, change state
		// to 1 (the user now has to select an empty tile
		// that is contained in that piece's possible moves)
		this.pos0 = pos;
		this.state = 1;
		this.possible_moves = this.game.possible_moves(this.board, this.game.turn_values[this.turn]);
	}
	else if (this.state == 1)
	{
		if (this.board.piece_tile_assocs[rcstr(pos.r, pos.c)] !== undefined)
		{
			this.pos0 = pos;
			this.state = 1;
			this.possible_moves = this.game.possible_moves(this.board, this.game.turn_values[this.turn]);
			
			// console.log("found piece");
			return;
		}

		// Store the position of the empty tile
		// that the user clicked on
		this.pos1 = pos;

		// Check if moving from this.pos0 to this.pos1
		// is valid according to the game rules 
		var move = this.game.is_valid_move(this.board, this.pos0.r, this.pos0.c, this.pos1.r, this.pos1.c, 
				   					  	   this.game.turn_values[this.turn]);
		
		// If requested move is valid
		if (move)
		{
			// Tell board to make the move
			var m = this.board.make_move(this.pos0.r, this.pos0.c, this.pos1.r, this.pos1.c);

			// Record move in the running sequence for this turn
			this.move_sequence.push({ src: { r: this.pos0.r, c: this.pos0.c }, 
			  						  dst: { r: this.pos1.r, c: this.pos1.c } });
			// this.move_history.push({ src: { r: this.pos0.r, c: this.pos0.c }, 
			// 						 dst: { r: this.pos1.r, c: this.pos1.c } });

			// If the move was a jump (which was determined
			// in Board.make_move)
			if (m == "jump")
			{
				// Get the possible jumps that can be made 
				// after a move was made 
				var pjumps = this.game.possible_jumps(this.board, this.game.turn_values[this.turn]);

				// console.log("jump made");
				
				// Switch turn if there are no jumps that can be made
				if (pjumps.length == 0)
				{
					// console.log("switched turn");
					
					// Check if the game is over
					this.game_over = this.is_over();

					// If the game is over, store the winner so
					// the CheckersView can display it
					if (this.game_over)
						this.winner = this.game.turn_values[this.turn];

					// Switch the turn
					this.switch_turn();
				}

				// There are jumps that can be made
				else 
				{
					// Copy the list of jumps
					var filtered = pjumps;
					var i = 0;

					// Filter out any jumps that are not
					// for the piece that just moved
					for (i = 0; i < pjumps.length; i++)
					{
						if (pjumps[i].src.r != this.pos1.r && 
							pjumps[i].src.c != this.pos1.c)
						{
							//console.log("removing...");
							//console.log(pjumps[i].src);
							//console.log(this.pos1);
							filtered.remove(filtered[i]);
						}
					}

					// Store the filtered list in possible_moves
					this.possible_moves = filtered;

					// If there are no possible jumps for the piece
					// which was just moved, then switch the turn
					if (this.possible_moves.length == 0)
					{
						// this.turn = (this.turn == 1) ? 0 : 1; 
						this.switch_turn();
					}
				}
			}

			// The move was a forward/backward movement.
			// Switch the turn 
			else if (m == "move")
			{
				// switch the turn
				// this.turn = (this.turn == 1) ? 0 : 1;
				this.switch_turn();
			}
		}

		// Switch the state to 0. User can now
		// select a piece
		this.state = 0;
	}

	if (this.possible_moves.length == 0)
	{
		this.game_over = true;
		this.winner = (this.turn == 0) ? 1 : 0;
	}
}
