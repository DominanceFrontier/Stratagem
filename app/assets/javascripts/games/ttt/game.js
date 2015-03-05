// Constructor for Game
// Game describes logical rules for a game
// Currently specialized to Tic-Tac-Toe
// Only exposed interface: isValidMove, makeMove, checkForWinner
// Only for internal use: parseBoard, parseMove

function Game(){
}

Game.prototype.makeMove = function(board, move, piece){
  board = this.parseBoard(board);
  move = this.parseMove(move);
  
  board[move[0]][move[1]] = piece;
  
  return JSON.stringify(board);
}

Game.prototype.parseBoard = function(board){
  return JSON.parse(board);
}

Game.prototype.parseMove = function(move){
  return JSON.parse(move);
}

Game.prototype.isValidMove = function(board, move){
  board = this.parseBoard(board);
  move = this.parseMove(move);

  return isWithinBounds(board, move) && onFreeTile(board, move);

  function isWithinBounds(board, move){
    return move[0] >= 0 && move[0] <= 3 && move[1] >= 0 && move[0] <= 3;
  }

  function onFreeTile(board, move){
    return board[move[0]][move[1]] == ' ';
  }
} 

Game.prototype.checkWinner(board){
  return this.checkColumnsForWinner() || this.checkRowsForWinner() || this.checkDiagonalsForWinner();
}

Game.prototype.
