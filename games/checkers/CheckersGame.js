
var CheckersGame = function()
{
    // Initialize the super class 
    Game.call(this);

    this.turn_values = ["b", "r"];
};

CheckersGame.prototype.other_turn_char = function(turn_char)
{
    var t_index = this.turn_values.indexOf(turn_char);

    if (t_index == 0) return this.turn_values[1];
    else return this.turn_values[0]; 
};

// 
// Check for Jump logic
CheckersGame.prototype.is_jump = function(board, r0, c0, r1, c1, turn)
{
    var tile0 = board.arr[r0][c0];
    var tile1 = board.arr[r1][c1];
    var is_jump = false; 
    var assocs = board.piece_tile_assocs;
    var a = assocs[r0.toString() + "," + c0.toString()];
    var a1 = assocs[r1.toString() + "," + c1.toString()];

    // No piece on source tile 
    if (!a.piece) return false;

    // Not a jump 
    if (Math.abs(r1 - r0) != 2)
        return false;

    // Check if piece is the one on the top of
    // the board. If so, the difference between 
    // r1 and r0 should be 2
    if (a.piece.value == this.turn_values[0])
    {
        var c = (c1 + c0) / 2, r = (r1 + r0) / 2;
        var middle_tile = board.arr[r][c];

        // no middle tile association existed 
        if (!assocs[rcstr(r, c)]) return false;

        var middle_val = assocs[rcstr(r, c)].piece.value;

        is_jump = (r1 - r0 == 2 || (r1 - r0 == -2 && a.piece.is_king)) &&
            (Math.abs(c1 - c0) == 2) && middle_val == this.other_turn_char(turn) && !a1;
    }
    else if (a.piece.value == this.turn_values[1])
    {
        var c = (c1 + c0) / 2, r = (r1 + r0) / 2;
        var middle_tile = board.arr[r][c];

        if (!assocs[rcstr(r, c)]) return false;

        var middle_val = assocs[rcstr(r, c)].piece.value;

        is_jump = (r1 - r0 == -2 || (r1 - r0 == 2 && a.piece.is_king)) &&
            (Math.abs(c1 - c0) == 2) && middle_val == this.other_turn_char(turn) && !a1;
    }

    return is_jump; 
};

CheckersGame.prototype.is_move = function(board, r0, c0, r1, c1, turn)
{
    var tile0 = board.arr[r0][c0];
    var tile1 = board.arr[r1][c1];
    var is_move = false;
    var assocs = board.piece_tile_assocs;
    var a = assocs[rcstr(r0, c0)];
    var a1 = assocs[rcstr(r1, c1)];

    // Check if piece is the one on the top of
    // the board. If so, the difference between 
    // r1 and r0 should be 1
    if (a.piece.value == this.turn_values[0])
    {
        is_move = (r1 - r0 == 1 || (r1 - r0 == -1 && a.piece.is_king)) && 
            (Math.abs(c1 - c0) == 1) && !a1;
    }
    else if (a.piece.value == this.turn_values[1])
    {
        is_move = (r1 - r0 == -1 || (r1 - r0 == 1 && a.piece.is_king)) && 
            (Math.abs(c1 - c0) == 1) && !a1;
    }

    return is_move; 
};

CheckersGame.prototype.possible_jumps = function(board, turn)
{
    var possible_moves = [];
    var assocs = board.piece_tile_assocs;

    for (key in assocs)
    {
        if (assocs.hasOwnProperty(key) && assocs[key].tile &&
            assocs[key].piece.value == turn)
        {
            var t = assocs[key].tile;
            var rdiff = (assocs[key].piece.value == this.turn_values[1]) ? -2 : 2;
            var r = t.row + rdiff;
            var c0 = t.col - 2;
            var c1 = t.col + 2;

            if (this.is_valid_move(board, t.row, t.col, r, c0, turn))
                possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c0}});

            if (this.is_valid_move(board, t.row, t.col, r, c1, turn))
                possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c1}});

            if (assocs[key].piece.is_king)
            {
                r = t.row - rdiff;

                if (this.is_valid_move(board, t.row, t.col, r, c0, turn))
                    possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c0}});

                if (this.is_valid_move(board, t.row, t.col, r, c1, turn))
                    possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c1}});                
            }
        }
    }

    return possible_moves;
};

CheckersGame.prototype.possible_forward_moves = function(board, turn)
{
    var possible_moves = [];
    var assocs = board.piece_tile_assocs;

    // Get moves that are not jumps
    for (key in assocs)
    {
        if (assocs.hasOwnProperty(key) && assocs[key].tile
            && assocs[key] !== null)
        {
            var t = assocs[key].tile;
            var rdiff = (assocs[key].piece.value == this.turn_values[1]) ? -1 : 1;
            var r = t.row + rdiff;
            var c0 = t.col - 1;
            var c1 = t.col + 1;

            if (this.is_valid_move(board, t.row, t.col, r, c0, turn))
                possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c0}});

            if (this.is_valid_move(board, t.row, t.col, r, c1, turn))
                possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c1}});

            if (assocs[key].piece.is_king)
            {
                r = t.row - rdiff;

                if (this.is_valid_move(board, t.row, t.col, r, c0, turn))
                    possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c0}});

                if (this.is_valid_move(board, t.row, t.col, r, c1, turn))
                    possible_moves.push({ src: {r: t.row, c: t.col}, dst: {r: r, c: c1}});                
            }
        }
    }

    return possible_moves;
};

CheckersGame.prototype.possible_moves = function(board, turn)
{
    var possible_moves = new Array();

    possible_moves = possible_moves.concat(this.possible_jumps(board, turn));
    
    if (possible_moves.length == 0)
        possible_moves = possible_moves.concat(this.possible_forward_moves(board, turn));

    return possible_moves;
};

CheckersGame.prototype.is_valid_move = function(board, r0, c0, r1, c1, turn)
{
    var assocs = board.piece_tile_assocs;

    // check if input is correct
    if (r0 < 0 || r0 >= board.rows)      return false;
    else if (c0 < 0 || c0 >= board.cols) return false;

    if (r1 < 0 || r1 >= board.rows)      return false;
    else if (c1 < 0 || c1 >= board.cols) return false;

    // copy board and associtions so the
    // match state is not changed here
    var tile0_pass = false;
    var tile1_pass = false;

    tile0_pass     = assocs[rcstr(r0, c0)].piece.value == turn;

    var is_move    = this.is_move(board, r0, c0, r1, c1, turn);
    var is_jump    = this.is_jump(board, r0, c0, r1, c1, turn);
    
    tile1_pass     = is_move || is_jump;

    return tile0_pass && tile1_pass;
};

// Write a wrapper isValidMove(board, move) where the "move" is actually a
// list of moves in the format
// [[origin_row, origin_col], [dest1_row, dest1_col], [dest2_row, dest2_col], ...]
// and verifies that the whole sequence is valid.

// It can probably just call the is_valid_move up there between each pair.
// Board will probably need to be copied and its make_move will probably need
// to be called which should update the board. Just clone the board and call
// make_move on the clone.

// Write a makeMove(board, move, turn) where the "move" is again a move sequence
// and turn is whosever turn it is to make the move ('r' or 'b'). It should return
// the state of the board after making the move as a json string. This too can use
// board's make_move but should be implemented as part of CheckersGame.

// Write a checkForWinner(board, piece) that returns if the board is in a final
// state where the piece has won or there's a tie. Piece should be 'r' or 'b'.
// Just return the piece if the game is over for that piece.
// If there's a tie, return 't'. Return " " otherwise.

// Move all the logic related code to one "game.js" file.

// Start all needed variables, with the name corresponding to their type in
// lowercase. Example: game for CheckersGame and match for Match.
