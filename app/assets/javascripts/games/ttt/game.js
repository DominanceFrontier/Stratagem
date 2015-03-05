// Constructor for Game
// Game describes logical rules for a game
// Currently specialized to Tic-Tac-Toe
// Only exposed interface: isValidMove, makeMove, checkForWinner
// Only for internal use: parseBoard, parseMove

function Game(){
}

Game.prototype.parseBoard = function(board){
  return JSON.parse(board);
}

Game.prototype.parseMove = function(move){
  return JSON.parse(move);
}

Game.prototype.makeMove = function(board, move, piece){
  board = this.parseBoard(board);
  move = this.parseMove(move);
  
  board[move[0]][move[1]] = piece;
  
  return JSON.stringify(board);
}

Game.prototype.isValidMove = function(board, move){
  board = this.parseBoard(board);
  move = this.parseMove(move);

  return isWithinBounds(board, move) && onFreeTile(board, move);

  function isWithinBounds(board, move){
    return move[0] >= 0 && move[0] <= 2 && move[1] >= 0 && move[0] <= 2;
  }

  function onFreeTile(board, move){
    return board[move[0]][move[1]] == ' ';
  }
} 

Game.prototype.checkForWinner = function(board){
  board = this.parseBoard(board);

  return checkRowsForWinner(board) || checkColumnsForWinner(board) || checkDiagonalsForWinner(board);

  function checkRowsForWinner(board){
    return (board[0][0] == board[0][1] && board[0][1] == board[0][2] ||
            board[1][0] == board[1][1] && board[1][1] == board[1][2] ||
            board[2][0] == board[2][1] && board[2][1] == board[2][2])
  }

  function checkColumnsForWinner(board){
    return (board[0][0] == board[1][0] && board[1][0] == board[2][0] ||
            board[0][1] == board[1][1] && board[1][1] == board[2][1] ||
            board[0][2] == board[1][2] && board[1][2] == board[2][2])
  }

  function checkDiagonalsForWinner(board){
    return (board[0][0] == board[1][1] && board[1][1] == board[2][2] ||
            board[0][2] == board[1][1] && board[1][1] == board[2][0])
  }
}

var ttt = new Game();
