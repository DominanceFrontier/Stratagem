
require 'json'

class CheckersGame

  def check_for_winner(state)
    bcount, rcount = 0, 0

    for row in state
      for piece in row
        if piece.downcase == 'b'
          bcount += 1
        elsif piece.downcase == 'r'
          rcount += 1 
        end
      end
    end

    if bcount > 0 and rcount > 0
      return ' '
    elsif bcount > 0 and rcount == 0
      return 'b'
    elsif rcount > 0 and bcount == 0
      return 'r'
    end
  end
  
  # Checks if a given move sequence is valid
  # for a turn and given a specific state 
  def validate_sequence(state, sequence, turn)
    
    if self.is_valid_sequence?(state, sequence, turn)
      possible_sequences = self.possible_sequences(state, turn)
      
      for ps in possible_sequences
        if ps == sequence
          return true 
        end
      end
    end

    return false 
  end
  
  # Returns: 
  # - A Ruby list of possible move sequences 
  # sequences
  #   - ex. '[
  #            [ [[2, 3], [3, 4]], [[3, 4], [7, 4]] ]
  #          ]'
  def possible_sequences(state, turn)
    board = JSON.parse(state)
    sequences = []

    board.each_with_index do |row, i|
      board[i].each_with_index do |col, j|
        if board[i][j].downcase == turn
          sequences.concat self.move_sequences_for_piece(board, [i, j])
        end
      end
    end

    return sequences 
  end

  def move_sequences_for_piece(board, src, depth = 0)
    new_board = Marshal.load(Marshal.dump(board))
    srcpiece = new_board[src[0]][src[1]]

    if srcpiece == ' '
      return []
    end

    check_forward = (depth == 0) ? true : false 
    
    moves = self.moves_for_piece(board, src, check_forward)
    
    if moves.length == 0
      return []
    end

    sequence = []
    sequences = [] 
    
    for move in moves
      sequence = []
      sequence << move
      was_jump = false 
      
      src, dst = move 
      
      # if the move is a jump
      if (src[0] - dst[0]).abs == 2 and (src[1] - dst[1]).abs == 2
        r = (src[0] + dst[0]) / 2
        c = (src[1] + dst[1]) / 2

        # remove middle piece 
        new_board[r][c] = ' '

        # move jumping piece 
        new_board[src[0]][src[1]],
        new_board[dst[0]][dst[1]] = new_board[dst[0]][dst[1]], new_board[src[0]][src[1]]
        was_jump = true 
      else
        # move piece 
        new_board[src[0]][src[1]],
        new_board[dst[0]][dst[1]] = new_board[dst[0]][dst[1]], new_board[src[0]][src[1]]
      end

      # Check if more jumps are available
      if was_jump
        sequence.concat move_sequences_for_piece(new_board, dst, depth + 1)
      end
        
      sequences << sequence 
    end

    return sequences 
  end
  
  # Gets the moves that a piece can go to
  # moves are of the form [[a, b], [b, c]]
  def moves_for_piece(board, src, check_forward=true)
    srcpiece = board[src[0]][src[1]]
    moves = []

    if srcpiece == 'b' or srcpiece == 'B'
      # check for down left jump
      if src[1] - 2 >= 0 and src[0] + 2 < board.length
        r = src[0] + 2
        c = src[1] - 2

        if board[r][c] == ' ' and board[r - 1][c + 1].downcase == 'r'
          moves << [src, [r, c]]
        end
      end

      # check for down right jump
      if src[1] + 2 < board[0].length  and src[0] + 2 < board.length
        r = src[0] + 2
        c = src[1] + 2

        if board[r][c] == ' ' and board[r - 1][c - 1].downcase == 'r'
          moves << [src, [r, c]]
        end
      end

      # If the piece is a king
      if srcpiece == 'B'
        # check up left
        if src[1] - 2 >= 0 and src[0] - 2 >= 0
          r = src[0] - 2
          c = src[1] - 2

          if board[r][c] == ' ' and board[r + 1][c + 1].downcase == 'r'
            moves << [src, [r, c]]
          end
        end

        # check up right
        if src[1] + 2 <= board[0].length and src[0] - 2 >= 0
          r = src[0] - 2
          c = src[1] + 2

          if board[r][c] == ' ' and board[r + 1][c - 1].downcase == 'r'
            moves << [src, [r, c]]
          end
        end
      end

    elsif srcpiece == 'r' or srcpiece == 'R'
      # check for up left jump
      if src[1] - 2 >= 0 and src[0] - 2 >= 0
        r = src[0] - 2
        c = src[1] - 2

        if board[r][c] == ' ' and board[r + 1][c + 1].downcase == 'b'
          moves << [src, [r, c]]
        end
      end

      # check for up right jump
      if src[1] + 2 < board[0].length  and src[0] - 2 >= 0
        r = src[0] - 2
        c = src[1] + 2

        if board[r][c] == ' ' and board[r + 1][c - 1].downcase == 'b'
          moves << [src, [r, c]]
        end
      end

      # If the piece is a king
      if srcpiece == 'R'
        # check down left
        if src[1] - 2 >= 0 and src[0] + 2 < board.length 
          r = src[0] + 2
          c = src[1] - 2

          if board[r][c] == ' ' and board[r - 1][c + 1].downcase == 'b'
            moves << [src, [r, c]]
          end
        end

        # check down right
        if src[1] + 2 <= board[0].length and src[0] + 2 < board.length 
          r = src[0] + 2
          c = src[1] + 2

          if board[r][c] == ' ' and board[r - 1][c - 1].downcase == 'b'
            moves << [src, [r, c]]
          end
        end
      end
    end
    
    # check for forward moves 
    if moves.length == 0 and check_forward
      if srcpiece == 'b' or srcpiece == 'B'
        # check for down left jump
        if src[1] - 1 >= 0 and src[0] + 1 < board.length
          r = src[0] + 1
          c = src[1] - 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # check for down right jump
        if src[1] + 1 < board[0].length  and src[0] + 1 < board.length
          r = src[0] + 1
          c = src[1] + 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # If the piece is a king
        if srcpiece == 'B'
          # check up left
          if src[1] - 1 >= 0 and src[0] - 1 >= 0
            r = src[0] - 1
            c = src[1] - 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end

          # check up right
          if src[1] + 1 <= board[0].length and src[0] - 1 >= 0
            r = src[0] - 1
            c = src[1] + 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end
        end

      elsif srcpiece == 'r' or srcpiece == 'R'
        # check for up left jump
        if src[1] - 1 >= 0 and src[0] - 1 >= 0
          r = src[0] - 1
          c = src[1] - 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # check for up right jump
        if src[1] + 1 < board[0].length  and src[0] - 1 >= 0
          r = src[0] - 1
          c = src[1] + 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # If the piece is a king
        if srcpiece == 'R'
          # check down left
          if src[1] - 1 >= 0 and src[0] + 1 < board.length 
            r = src[0] + 1
            c = src[1] - 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end

          # check down right
          if src[1] + 1 < board[0].length and src[0] + 1 < board.length 
            r = src[0] + 1
            c = src[1] + 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end
        end
      end
    end
    
    return moves 
  end

  # Makes sure the sequence can be done.
  # Does NOT enforce jumps, etc.
  # Parameters:
  # - state = A board state (2-D array, example can be found
  #                          elsewhere in documentation)
  # - sequence = a sequence of moves of the form
  #              [[[a, b], [b, c]], [[c, d], [d, e]]]
  # - turn = 'b' or 'r' represent Black/Red's turn
  def is_valid_sequence?(state, sequence, turn)
    board = JSON.parse(state)
    valid = true  

    sequence.each do |move|
      valid = valid and self.is_valid_move?(state, move, turn)

      if not valid
        return false
      end

      # Get the move 
      src, dst = move

      # Make the move 
      board[src[0]][src[1]],
      board[dst[0]][dst[1]] = ' ', board[src[0]][src[1]]

      # if the move was a jump
      if (src[0] - dst[0]).abs == 2 and (src[1] - dst[1]).abs == 2
        r = (src[0] + dst[0]) / 2
        c = (src[1] + dst[1]) / 2

        board[r][c] = ' '
      end
    end

    return true  
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
  # - move  = A JSON string containing single piece movement
  #  - ex.    '[[2,3], [3,4]]'
  # Returns:
  # - true   -> The move is valid
  # - false  -> The move is not valid  
  def is_valid_move?(state, move, turn)
    board = JSON.parse(state)
    src, dst = move 
    
    # Get the piece that is going to be
    # moved 
    srcpiece = board[src[0]][src[1]]
    dstpiece = board[dst[0]][dst[1]]
    
    # Make sure the src piece is the
    # same as the turn and the destination
    # is an empty space
    if srcpiece.downcase != turn or dstpiece != ' '
      return false 
    end

    return true 
  end

end 
