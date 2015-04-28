
require 'json'

class TicTacToeGame
  def make_move(state, move, piece)
    board = JSON.parse(state)
    move = JSON.parse(move)

    board[move[0]][move[1]] = piece

    board.to_json 
  end

  def is_valid_move?(state, move, piece)
    board = JSON.parse(state)
    move = JSON.parse(move)

    return (is_within_bounds?(board, move) and on_free_tile?(board, move))
  end

  # some helpers for is_valid_move?
  def is_within_bounds?(board, move)
    return move[0] >= 0 && move[0] <= 2 &&
           move[1] >= 0 && move[0] <= 2
  end

  def on_free_tile?(board, move)
    return board[move[0]][move[1]] == ' '
  end

  def check_for_winner(state, piece)
    board = JSON.parse(state)
    
    if check_rows_for_winner?(board, piece) or
       check_columns_for_winner?(board, piece) or 
       check_diagonals_for_winner?(board, piece)
        return piece
    elsif check_for_tie?(board)
        return "t"
    else
        return " "
    end
  end

  # some helpers for check_for_winner
  def check_columns_for_winner?(board, piece)
    return (board[0][0] == piece and board[1][0] == piece and board[2][0] == piece or
                board[0][1] == piece and board[1][1] == piece and board[2][1] == piece or
                board[0][2] == piece and board[1][2] == piece and board[2][2] == piece)
  end

  def check_diagonals_for_winner?(board, piece)
    return (board[0][0] == piece and board[1][1] == piece and board[2][2] == piece or
                board[0][2] == piece and board[1][1] == piece and board[2][0] == piece)
  end

  def check_rows_for_winner?(board, piece)
    return (board[0][0] == piece and board[0][1] == piece and board[0][2] == piece or
                board[1][0] == piece and board[1][1] == piece and board[1][2] == piece or
                board[2][0] == piece and board[2][1] == piece and board[2][2] == piece)
  end

  def check_for_tie?(board)
    for row in board
      for piece in row
        return false if piece == ' '
      end
    end
    return true;
  end
 
end

