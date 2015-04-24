
class CheckersGame

  # Returns: 
  # - A Ruby list of possible move 
  # sequences
  #   - ex. '[
  #            [ [[2, 3], [3, 4]], [[3, 4], [7, 4]] ]
  #          ]'
  def possible_moves(state)
    board = JSON.parse(state)
  end

  def is_valid_sequence?(state, sequence, turn)
    board = JSON.parse(state)
    valid = true  

    sequence.each do |move|
      valid = valid and self.is_valid_move(state, move)
    end

    return valid 
  end 

  # This function checks if a given move sequence
  # is valid given a board state
  # Parameters:
  # - state = JSON board state
  #  - ex.  '[[" ","b"," ","b"," ","b"," ","b"],
  #          ["b"," ","b"," ","b"," ","b"," "],
  #          [" ","b"," ","b"," ","b"," ","b"],
  #          [" "," "," "," "," "," "," "," "],
  #          [" "," "," "," "," "," "," "," "],
  #          ["r"," ","r"," ","r"," ","r"," "],
  #          [" ","r"," ","r"," ","r"," ","r"],
  #          ["r"," ","r"," ","r"," ","r"," "]]''
  # - move  = A JSON string containing sequence of moves
  #  - ex.    '[[[2,3], [3,4]],  [[3,4], [7,4]]]'
  #           Moves are in the format [[a, b], [b, c], [c, d]]
  # Returns:
  # - true   -> The move sequence is valid
  # - false  -> The move sequence is not valid  
  def is_valid_move?(state, move, turn)
    board = JSON.parse(state)

    move.each do |srcdst|
      src = srcdst[0]
      dst = srcdst[1]

      # Get the piece that is going to be
      # moved 
      srcpiece = board[src[0]][src[1]]

      # Make sure the src piece is the
      # same as the turn
      if srcpiece != turn
        return false 
      end
    end
  end

end 
