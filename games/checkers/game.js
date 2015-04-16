
// ============================================================================
// deepcopy.js code 
// ============================================================================

/* This file is part of OWL JavaScript Utilities.

   OWL JavaScript Utilities is free software: you can redistribute it and/or 
   modify it under the terms of the GNU Lesser General Public License
   as published by the Free Software Foundation, either version 3 of
   the License, or (at your option) any later version.

   OWL JavaScript Utilities is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public 
   License along with OWL JavaScript Utilities.  If not, see 
   <http://www.gnu.org/licenses/>.
*/

owl = (function() {

    // the re-usable constructor function used by clone().
    function Clone() {}

    // clone objects, skip other types.
    function clone(target) {
        if ( typeof target == 'object' ) {
            Clone.prototype = target;
            return new Clone();
        } else {
            return target;
        }
    }


    // Shallow Copy 
    function copy(target) {
        if (typeof target !== 'object' ) {
            return target;  // non-object have value sematics, so target is already a copy.
        } else {
            var value = target.valueOf();
            if (target != value) { 
                // the object is a standard object wrapper for a native type, say String.
                // we can make a copy by instantiating a new object around the value.
                return new target.constructor(value);
            } else {
                // ok, we have a normal object. If possible, we'll clone the original's prototype 
                // (not the original) to get an empty object with the same prototype chain as
                // the original.  If just copy the instance properties.  Otherwise, we have to 
                // copy the whole thing, property-by-property.
                if ( target instanceof target.constructor && target.constructor !== Object ) { 
                    var c = clone(target.constructor.prototype);
                    
                    // give the copy all the instance properties of target.  It has the same
                    // prototype as target, so inherited properties are already there.
                    for ( var property in target) { 
                        if (target.hasOwnProperty(property)) {
                            c[property] = target[property];
                        } 
                    }
                } else {
                    var c = {};
                    for ( var property in target ) c[property] = target[property];
                }
                
                return c;
            }
        }
    }

    // Deep Copy
    var deepCopiers = [];

    function DeepCopier(config) {
        for ( var key in config ) this[key] = config[key];
    }
    DeepCopier.prototype = {
        constructor: DeepCopier,

        // determines if this DeepCopier can handle the given object.
        canCopy: function(source) { return false; },

        // starts the deep copying process by creating the copy object.  You
        // can initialize any properties you want, but you can't call recursively
        // into the DeeopCopyAlgorithm.
        create: function(source) { },

        // Completes the deep copy of the source object by populating any properties
        // that need to be recursively deep copied.  You can do this by using the
        // provided deepCopyAlgorithm instance's deepCopy() method.  This will handle
        // cyclic references for objects already deepCopied, including the source object
        // itself.  The "result" passed in is the object returned from create().
        populate: function(deepCopyAlgorithm, source, result) {}
    };

    function DeepCopyAlgorithm() {
        // copiedObjects keeps track of objects already copied by this
        // deepCopy operation, so we can correctly handle cyclic references.
        this.copiedObjects = [];
        thisPass = this;
        this.recursiveDeepCopy = function(source) {
            return thisPass.deepCopy(source);
        }
        this.depth = 0;
    }
    DeepCopyAlgorithm.prototype = {
        constructor: DeepCopyAlgorithm,

        maxDepth: 256,
        
        // add an object to the cache.  No attempt is made to filter duplicates;
        // we always check getCachedResult() before calling it.
        cacheResult: function(source, result) {
            this.copiedObjects.push([source, result]);
        },

        // Returns the cached copy of a given object, or undefined if it's an
        // object we haven't seen before.
        getCachedResult: function(source) {
            var copiedObjects = this.copiedObjects;
            var length = copiedObjects.length;
            for ( var i=0; i<length; i++ ) {
                if ( copiedObjects[i][0] === source ) {
                    return copiedObjects[i][1];
                }
            }
            return undefined;
        },
        
        // deepCopy handles the simple cases itself: non-objects and object's we've seen before.
        // For complex cases, it first identifies an appropriate DeepCopier, then calls
        // applyDeepCopier() to delegate the details of copying the object to that DeepCopier.
        deepCopy: function(source) {
            // null is a special case: it's the only value of type 'object' without properties.
            if ( source === null ) return null;

            // All non-objects use value semantics and don't need explict copying.
            if ( typeof source !== 'object' ) return source;

            var cachedResult = this.getCachedResult(source);

            // we've already seen this object during this deep copy operation
            // so can immediately return the result.  This preserves the cyclic
            // reference structure and protects us from infinite recursion.
            if ( cachedResult ) return cachedResult;

            // objects may need special handling depending on their class.  There is
            // a class of handlers call "DeepCopiers"  that know how to copy certain
            // objects.  There is also a final, generic deep copier that can handle any object.
            for ( var i=0; i<deepCopiers.length; i++ ) {
                var deepCopier = deepCopiers[i];
                if ( deepCopier.canCopy(source) ) {
                    return this.applyDeepCopier(deepCopier, source);
                }
            }
            // the generic copier can handle anything, so we should never reach this line.
            throw new Error("no DeepCopier is able to copy " + source);
        },

        // once we've identified which DeepCopier to use, we need to call it in a very
        // particular order: create, cache, populate.  This is the key to detecting cycles.
        // We also keep track of recursion depth when calling the potentially recursive
        // populate(): this is a fail-fast to prevent an infinite loop from consuming all
        // available memory and crashing or slowing down the browser.
        applyDeepCopier: function(deepCopier, source) {
            // Start by creating a stub object that represents the copy.
            var result = deepCopier.create(source);

            // we now know the deep copy of source should always be result, so if we encounter
            // source again during this deep copy we can immediately use result instead of
            // descending into it recursively.  
            this.cacheResult(source, result);

            // only DeepCopier::populate() can recursively deep copy.  So, to keep track
            // of recursion depth, we increment this shared counter before calling it,
            // and decrement it afterwards.
            this.depth++;
            if ( this.depth > this.maxDepth ) {
                throw new Error("Exceeded max recursion depth in deep copy.");
            }

            // It's now safe to let the deepCopier recursively deep copy its properties.
            deepCopier.populate(this.recursiveDeepCopy, source, result);

            this.depth--;

            return result;
        }
    };

    // entry point for deep copy.
    //   source is the object to be deep copied.
    //   maxDepth is an optional recursion limit. Defaults to 256.
    function deepCopy(source, maxDepth) {
        var deepCopyAlgorithm = new DeepCopyAlgorithm();
        if ( maxDepth ) deepCopyAlgorithm.maxDepth = maxDepth;
        return deepCopyAlgorithm.deepCopy(source);
    }

    // publicly expose the DeepCopier class.
    deepCopy.DeepCopier = DeepCopier;

    // publicly expose the list of deepCopiers.
    deepCopy.deepCopiers = deepCopiers;

    // make deepCopy() extensible by allowing others to 
    // register their own custom DeepCopiers.
    deepCopy.register = function(deepCopier) {
        if ( !(deepCopier instanceof DeepCopier) ) {
            deepCopier = new DeepCopier(deepCopier);
        }
        deepCopiers.unshift(deepCopier);
    }

    // Generic Object copier
    // the ultimate fallback DeepCopier, which tries to handle the generic case.  This
    // should work for base Objects and many user-defined classes.
    deepCopy.register({
        canCopy: function(source) { return true; },

        create: function(source) {
            if ( source instanceof source.constructor ) {
                return clone(source.constructor.prototype);
            } else {
                return {};
            }
        },

        populate: function(deepCopy, source, result) {
            for ( var key in source ) {
                if ( source.hasOwnProperty(key) ) {
                    result[key] = deepCopy(source[key]);
                }
            }
            return result;
        }
    });

    // Array copier
    deepCopy.register({
        canCopy: function(source) {
            return ( source instanceof Array );
        },

        create: function(source) {
            return new source.constructor();
        },

        populate: function(deepCopy, source, result) {
            for ( var i=0; i<source.length; i++) {
                result.push( deepCopy(source[i]) );
            }
            return result;
        }
    });

    // Date copier
    deepCopy.register({
        canCopy: function(source) {
            return ( source instanceof Date );
        },

        create: function(source) {
            return new Date(source);
        }
    });

    // HTML DOM Node

    // utility function to detect Nodes.  In particular, we're looking
    // for the cloneNode method.  The global document is also defined to
    // be a Node, but is a special case in many ways.
    function isNode(source) {
        // if ( this.Node ) {
        //  return source instanceof Node;
        // } else {
        //  // the document is a special Node and doesn't have many of
        //  // the common properties so we use an identity check instead.
        //  if ( source === document ) return true;
        //  return (
        //      typeof source.nodeType === 'number' &&
        //      source.attributes &&
        //      source.childNodes &&
        //      source.cloneNode
        //  );
        // }
    }

    // Node copier
    deepCopy.register({
        canCopy: function(source) { return isNode(source); },

        create: function(source) {
            // there can only be one (document).
            if ( source === document ) return document;

            // start with a shallow copy.  We'll handle the deep copy of
            // its children ourselves.
            return source.cloneNode(false);
        },

        populate: function(deepCopy, source, result) {
            // we're not copying the global document, so don't have to populate it either.
            if ( source === document ) return document;

            // if this Node has children, deep copy them one-by-one.
            if ( source.childNodes && source.childNodes.length ) {
                for ( var i=0; i<source.childNodes.length; i++ ) {
                    var childCopy = deepCopy(source.childNodes[i]);
                    result.appendChild(childCopy);
                }
            }
        }
    });

    return {
        DeepCopyAlgorithm: DeepCopyAlgorithm,
        copy: copy,
        clone: clone,
        deepCopy: deepCopy
    };
})();

// ============================================================================

// ============================================================================
// util.js code 
// ============================================================================

// function getMousePos(canvas, evt) 
// {
//     var rect = canvas.getBoundingClientRect();
//     return {
//         x: evt.clientX - rect.left,
//         y: evt.clientY - rect.top
//     };
// }

function replaceAll(str, find, replace) 
{
    var i = str.indexOf(find);
    if (i > -1)
    {
        str = str.replace(find, replace); 
        i = i + replace.length;
        var st2 = str.substring(i);
        
        if(st2.indexOf(find) > -1)
            str = str.substring(0,i) + replaceAll(st2, find, replace);
    }
    return str;
}

function rcstr(row, col)
{
    return row.toString() + "," + col.toString();
}

// ============================================================================

// ============================================================================
// Piece.js code 
// ============================================================================

// value = string to represent the piece
var Piece = function(value)
{
    this.value = value; 
};

Piece.prototype.toString = function()
{
    return this.value;
};

// ============================================================================

// ============================================================================
// CheckersPiece.js code 
// ============================================================================

var CheckersPiece = function(value)
{
    Piece.call(this, value);

    this.is_king = false;
};

CheckersPiece.prototype.king = function()
{
    this.is_king = true; 
};

// ============================================================================

// ============================================================================
// Tile.js code 
// ============================================================================

var Tile = function(row, col)
{
    this.row = row;
    this.col = col; 
};

// ============================================================================

// ============================================================================
// PieceTileAssociation.js code
// ============================================================================

var PieceTileAssociation = function(piece, tile)
{
    this.piece = piece;
    this.tile = tile; 
};

// ============================================================================

// ============================================================================
// Board.js code 
// ============================================================================

// row = int 
// col = int 
// turn_chars = Array(chars)
var Board = function(rows, cols, turn_chars)
{
    this.rows = rows;
    this.cols = cols;
    this.arr = [];
    this.turn_index = 0;
    this.turn_chars = turn_chars;
    this.piece_tile_assocs = {};
};

Board.prototype.toString = function()
{
    var board_rows = [];

    for (var i = 0; i < this.rows; i++)
    {
        var board_row = [];

        for (var j = 0; j < this.cols; j++)
        {
            var a = this.piece_tile_assocs[rcstr(i, j)];
            if (a)
            {
                if (a.piece.is_king)
                    board_row.push(a.piece.value.toUpperCase());
                else
                    board_row.push(a.piece.value);
            }
            else 
                board_row.push(' ');
        }

        board_rows.push(board_row);
    }

    return JSON.stringify(board_rows);
};

Board.prototype.make_move = function(r0, c0, r1, c1)
{
    var type = "";
    var a0 = this.piece_tile_assocs[rcstr(r0, c0)];
    a0.tile = this.arr[r1][c1];

    delete this.piece_tile_assocs[rcstr(r0, c0)];
    this.piece_tile_assocs[rcstr(r1, c1)] = a0;

    // move was a jump
    if (Math.abs(r1 - r0) == 2 && Math.abs(c1 - c0) == 2)
    {
        var mr = (r1 + r0) / 2, mc = (c1 + c0) / 2;
        delete this.piece_tile_assocs[rcstr(mr, mc)];
        type = "jump";
    }
    else    
        type = "move";

    // king a piece
    if ((this.piece_tile_assocs[rcstr(r1, c1)].piece.value == this.turn_chars[0] && 
         this.piece_tile_assocs[rcstr(r1, c1)].tile.row == this.rows - 1) ||
        (this.piece_tile_assocs[rcstr(r1, c1)].piece.value == this.turn_chars[1] && 
         this.piece_tile_assocs[rcstr(r1, c1)].tile.row == 0))
    {
        this.piece_tile_assocs[rcstr(r1, c1)].piece.king();
    }

    return type;
};

Board.prototype.add_piece = function(piece, i, j)
{
    this.piece_tile_assocs[rcstr(i, j)] = { piece: piece, tile: this.arr[i][j] };
}

Board.prototype.init = function()
{
    var rows = [];
    for (i = 0; i < this.rows; i++)
    {
        var row = [];
        for (j = 0; j < this.cols; j++)
        {
            var t = new Tile(i, j);
            
            row.push(t);
        }
        rows.push(row);
    }
    
    this.arr = rows;
};

Board.prototype.load = function(state)
{
    for (i = 0; i < this.rows; i++)
    {
        for (j = 0; j < this.cols; j++)
        {
            if (state[i][j] != ' ')
            {
                var p = new CheckersPiece(state[i][j]);
                this.add_piece(p, i, j);
            }
        }
    }
}

// ============================================================================

// ============================================================================
// CheckersGame.js code 
// ============================================================================

var CheckersGame = function()
{
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
CheckersGame.prototype.isValidMove = function(board, move)
{
    state = JSON.parse(board);
    move = JSON.parse(move);
    board = new Board(8, 8, this.turn_values);
    board.init();
    board.load(state);
    
    var boardc = owl.deepCopy(board)
    var valid = true;
    var assoc = board.piece_tile_assocs[rcstr(move[0][0], move[0][1])];

    if (assoc === undefined)
        return false; 

    var turn = assoc.piece.value; 

    for (var i = 0; i < move.length - 1; i++)
    {
        var src = move[i];
        var dst = move[i + 1];

        valid = valid && this.is_valid_move(boardc, src[0], src[1], dst[0], dst[1], turn);

        if (valid)
        {
            // make the move 
            boardc.make_move(src[0], src[1], dst[0], dst[1]);
        }
        else 
            return false; 
    }

    return true; 
};

// Write a makeMove(board, move, turn) where the "move" is again a move sequence
// and turn is whosever turn it is to make the move ('r' or 'b'). It should return
// the state of the board after making the move as a json string. This too can use
// board's make_move but should be implemented as part of CheckersGame.
CheckersGame.prototype.makeMove = function(board, move, turn)
{
    state = JSON.parse(board);
    move = JSON.parse(move);
    board = new Board(8, 8, this.turn_values);
    board.init();
    board.load(state);
    
    for (var i = 0; i < move.length - 1; i++)
    {
        var src = move[i];
        var dst = move[i + 1];

        board.make_move(src[0], src[1], dst[0], dst[1]);
    }

    return board.toString();
};

// Write a checkForWinner(board, piece) that returns if the board is in a final
// state where the piece has won or there's a tie. Piece should be 'r' or 'b'.
// Just return the piece if the game is over for that piece.
// If there's a tie, return 't'. Return " " otherwise.
CheckersGame.prototype.checkForWinner = function(board, turn)
{
    state = JSON.parse(board);
    board = new Board(8, 8, this.turn_values);
    board.init();
    board.load(state);
    
    var p1count = 0, p2count = 0;

    for (key in board.piece_tile_assocs)
    {
        if (board.piece_tile_assocs.hasOwnProperty(key))
        {
            var a = board.piece_tile_assocs[key];
            
            if (a.piece.value == turn)
                p1count++;
            else
                p2count++; 
        }
    }

    if (p1count > 0 && p2count == 0)
        return turn;

    return " ";
};

// ============================================================================

// ============================================================================
// Match.js code 
// ============================================================================
var Match = function()
{
    this.game  = new CheckersGame();
    this.board = new Board(8, 8, this.game.turn_values, null);
    
    // Flag to store if the game is over
    this.game_over = false;
    
    // Represents who won, either player 0
    // or player 1
    this.winner = 0;

    // Characters which represent a turn
    var turn_chars = this.game.turn_values;

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


    this.turn = 0;

    this.board.init();
    this.init();
};

Match.prototype.load = function(state)
{
    this.pieces = [];
    this.board = new Board(8, 8, this.game.turn_values);
    this.board.init();

    for (i = 0; i < this.board.rows; i++)
    {
        for (j = 0; j < this.board.cols; j++)
        {
            if (state[i][j] != ' ')
            {
                var p = new CheckersPiece(state[i][j]);
                var t = this.board.arr[i][j];
                this.pieces.push(p);
                this.board.add_piece(p, i, j);
            }
        }
    }
};

// Create the pieces based on the
// description of the initial state
// and create the associations between 
// the piece and a tile on the board
Match.prototype.init = function()
{
    this.load(this.simple_init_state);
};

// ============================================================================

// Move all the logic related code to one "game.js" file.

// Start all needed variables, with the name corresponding to their type in
// lowercase. Example: game for CheckersGame and match for Match.

var game = new CheckersGame();
var match = new Match();

