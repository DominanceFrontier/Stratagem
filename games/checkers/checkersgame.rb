
require 'json'

class CheckersGame

  def check_for_winner(state, turn)
    bcount, rcount = 0, 0 
    board = JSON.parse(state)
    
    for row in board
      for piece in row
        if piece.downcase == 'b'
          bcount += 1
        elsif piece.downcase == 'r'
          rcount += 1 
        end
      end
    end

    # If the other player cannot make a move
    # because they no longer have pieces
    return 'b' if turn == 'b' and rcount == 0

    p ["bcount:", bcount]
    
    return 'r' if turn == 'r' and bcount == 0

    other_player_can_move = false
    player_can_move = true
    
    # The other player has pieces, so check
    # if those pieces can make a move
    board.each_with_index do |row, i|
      row.each_with_index do |piece, j|
        if piece != ' ' and piece != turn
          moves = self.move_sequences_for_piece(board, [i, j])

          if moves.length > 0
            other_player_can_move = true
            break 
          end
        end
      end
    end

    # If none of the other player's pieces
    # can move, then they lost
    if not other_player_can_move
      return turn 
    end

    return ' '
  end
  
  # Checks if a given move sequence is valid
  # for a turn and given a specific state 
  def is_valid_move?(state, sequence, turn)
    sequence = JSON.parse(sequence)
    
    if self.is_valid_sequence?(state, sequence, turn)
      possible_sequences = self.possible_sequences(state, turn)
 
      p ["Sequences:", possible_sequences]
      
      for ps in possible_sequences
        p ["comparing:", ps, sequence]
        if ps == sequence
          return true 
        end
      end
    end

    return false 
  end

  def make_move(state, sequence, turn)
    board = JSON.parse(state)
    sequence = JSON.parse(sequence)
    
    for move in sequence
      src, dst = move

       # if the move is a jump
      if (src[0] - dst[0]).abs == 2 and (src[1] - dst[1]).abs == 2
        r = (src[0] + dst[0]) / 2
        c = (src[1] + dst[1]) / 2

        # remove middle piece 
        board[r][c] = ' '
      end

      # move piece 
      board[src[0]][src[1]],
      board[dst[0]][dst[1]] = board[dst[0]][dst[1]], board[src[0]][src[1]]

      # King a piece 
      if turn == 'b' and dst[0] == board.length - 1
        board[dst[0]][dst[1]] = 'B'
      elsif turn == 'r' and dst[0] == 0
        board[dst[0]][dst[1]] = 'R'
      end
    end

    board.to_json 
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

    # remove single sequences if there are bigger
    # ones available
    sequences_copy = Marshal.load(Marshal.dump(sequences))
    jump_found = false
    
    sequences_copy.each_with_index do |sequence, i|
      if sequence[0].length > 1
        jump_found = true
        break 
      end
    end

    if jump_found
      sequences_copy.each_with_index do |sequence, i|
        if sequence[0].length == 1
          sequences.delete(sequence)
        end
      end
    end

    return sequences 
  end

  # [
  #   [
  #     [[3, 0], [5, 2]], 
  #     [[[5, 2], [7, 0]]]
  #   ]
  # ]

  # [
  #   [
  #     [[3, 0], [5, 2]], [[5, 2], [7, 0]]
  #   ]
  # ] 

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
      kinged = false 
      
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

      # check if piece became a king
      new_piece = new_board[dst[0]][dst[1]]

      if (new_piece == 'b' and dst[0] == new_board.length - 1) or
         (new_piece == 'r' and dst[0] == 0)
        kinged = true 
      end
      
      # Check if more jumps are available
      # if the piece was not kinged
      if was_jump and not kinged 
        new_sequence = move_sequences_for_piece(new_board, dst, depth + 1)
        if new_sequence.length > 0
          sequence.concat new_sequence[0]
        end
      end
      
      sequences << sequence
      new_board = Marshal.load(Marshal.dump(board))
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
      if src[1] - 2 >= 0 and src[0] + 2 < board.length and src[1] - 2 >= 0
        r = src[0] + 2
        c = src[1] - 2

        if board[r][c] == ' ' and board[r - 1][c + 1].downcase == 'r'
          moves << [src, [r, c]]
        end
      end

      # check for down right jump
      if src[1] + 2 < board[0].length and src[0] + 2 < board.length and src[1] + 2 < board.length
        r = src[0] + 2
        c = src[1] + 2

        if board[r][c] == ' ' and board[r - 1][c - 1].downcase == 'r'
          moves << [src, [r, c]]
        end
      end

      # If the piece is a king
      if srcpiece == 'B'
        # check up left
        if src[1] - 2 >= 0 and src[0] - 2 >= 0 and src[1] - 2 >= 0
          r = src[0] - 2
          c = src[1] - 2

          if board[r][c] == ' ' and board[r + 1][c + 1].downcase == 'r'
            moves << [src, [r, c]]
          end
        end

        # check up right
        if src[1] + 2 <= board[0].length and src[0] - 2 >= 0 and src[1] + 2 < board.length
          r = src[0] - 2
          c = src[1] + 2

          if board[r][c] == ' ' and board[r + 1][c - 1].downcase == 'r'
            moves << [src, [r, c]]
          end
        end
      end

    elsif srcpiece == 'r' or srcpiece == 'R'
      # check for up left jump
      if src[1] - 2 >= 0 and src[0] - 2 >= 0 and src[1] - 2 >= 0
        r = src[0] - 2
        c = src[1] - 2

        if board[r][c] == ' ' and board[r + 1][c + 1].downcase == 'b'
          moves << [src, [r, c]]
        end
      end

      # check for up right jump
      if src[1] + 2 < board[0].length  and src[0] - 2 >= 0 and src[1] + 2 < board.length
        r = src[0] - 2
        c = src[1] + 2

        if board[r][c] == ' ' and board[r + 1][c - 1].downcase == 'b'
          moves << [src, [r, c]]
        end
      end

      # If the piece is a king
      if srcpiece == 'R'
        # check down left
        if src[1] - 2 >= 0 and src[0] + 2 < board.length and src[1] - 2 >= 0
          r = src[0] + 2
          c = src[1] - 2

          if board[r][c] == ' ' and board[r - 1][c + 1].downcase == 'b'
            moves << [src, [r, c]]
          end
        end

        # check down right
        if src[1] + 2 <= board[0].length and src[0] + 2 < board.length and src[1] + 2 < board.length 
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
        if src[1] - 1 >= 0 and src[0] + 1 < board.length and src[1] - 1 >= 0
          r = src[0] + 1
          c = src[1] - 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # check for down right jump
        if src[1] + 1 < board[0].length  and src[0] + 1 < board.length and src[1] + 1 < board.length
          r = src[0] + 1
          c = src[1] + 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # If the piece is a king
        if srcpiece == 'B'
          # check up left
          if src[1] - 1 >= 0 and src[0] - 1 >= 0 and src[1] - 1 >= 0
            r = src[0] - 1
            c = src[1] - 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end

          # check up right
          if src[1] + 1 <= board[0].length and src[0] - 1 >= 0 and src[1] + 1 < board.length
            r = src[0] - 1
            c = src[1] + 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end
        end

      elsif srcpiece == 'r' or srcpiece == 'R'
        # check for up left jump
        if src[1] - 1 >= 0 and src[0] - 1 >= 0 and src[1] - 1 >= 0
          r = src[0] - 1
          c = src[1] - 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # check for up right jump
        if src[1] + 1 < board[0].length  and src[0] - 1 >= 0 and src[1] + 1 < board.length
          r = src[0] - 1
          c = src[1] + 1

          if board[r][c] == ' '
            moves << [src, [r, c]]
          end
        end

        # If the piece is a king
        if srcpiece == 'R'
          # check down left
          if src[1] - 1 >= 0 and src[0] + 1 < board.length and src[1] - 1 >= 0
            r = src[0] + 1
            c = src[1] - 1

            if board[r][c] == ' '
              moves << [src, [r, c]]
            end
          end

          # check down right
          if src[1] + 1 < board[0].length and src[0] + 1 < board.length and src[1] + 1 < board.length 
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

    sequence = sequence[0]

    sequence.each do |move|
      valid = valid and self.is_valid_space?(state, move, turn)

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
  def is_valid_space?(state, move, turn)
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
