
# c = CheckersGame()

# state = '''[[" ","b"," ","b"," ","b"," ","b"],["b"," ","b"," ","b"," ","b"," "],[" ","b"," ","b"," ","b"," ","b"],[" "," "," "," "," "," "," "," "],[" "," "," "," "," "," "," "," "],["r"," ","r"," ","r"," ","r"," "],[" ","r"," ","r"," ","r"," ","r"],["r"," ","r"," ","r"," ","r"," "]]'''

# print c.possible_sequences(state, 'b')
# print c.valid_sequence(state, [[[2, 1], [3, 0]]], 'b')

import random

import copy 
import json

class CheckersGame(object):
    def __init__(self):
        pass 
 
    def make_move(state, move, piece):
        if isinstance(board, str):
            board = json.loads(state)
        if isinstance(move, str):
            move = json.loads(move)

        board = JSON.parse(state)
        sequence = [JSON.parse(sequence)]
    
        for move in sequence:
            src, dst = move

            # if the move is a jump
            if abs(src[0] - dst[0]) == 2 and abs(src[1] - dst[1]) == 2:
                r = (src[0] + dst[0]) / 2
                c = (src[1] + dst[1]) / 2

                # remove middle piece 
                board[r][c] = ' '

            # move piece 
            board[src[0]][src[1]],
            board[dst[0]][dst[1]] = board[dst[0]][dst[1]], board[src[0]][src[1]]

            # King a piece 
            if turn == 'b' and dst[0] == len(board) - 1:
                board[dst[0]][dst[1]] = 'B'
            elif turn == 'r' and dst[0] == 0:
                board[dst[0]][dst[1]] = 'R'

        return json.dumps(board)

    def check_for_winner(state, turn):
        bcount, rcount = 0, 0 
        board = JSON.parse(state)
    
        for row in board:
            for piece in row:
                if piece.lower() == 'b':
                    bcount += 1
                elif piece.lower() == 'r':
                    rcount += 1

        # If the other player cannot make a move
        # because they no longer have pieces
        if turn == 'b' and rcount == 0:
            return 'b'

        # print "bcount:", bcount
    
        if turn == 'r' and bcount == 0:
            return 'r'

        other_player_can_move = False
        player_can_move = True
    
        # The other player has pieces, so check
        # if those pieces can make a move
        for i, row in enumerate(board):
            for j, piece in enumerate(row):
                if piece != ' ' and piece != turn:
                    moves = self.move_sequences_for_piece(board, [i, j])

                    if len(moves) > 0:
                        other_player_can_move = True
                        break 

        # If none of the other player's pieces
        # can move, then they lost
        if not other_player_can_move:
            return turn 

        return ' '
        
    # Checks if a given move sequence is valid
    # for a turn and given a specific state 
    def valid_sequence(self, state, sequence, turn):
        if isinstance(sequence, str):
            sequence = json.loads(sequence)

        if self.is_valid_sequence(state, sequence, turn):
            possible_sequences = self.possible_sequences(state, turn)
          
            for ps in possible_sequences:
                if ps == sequence:
                    return True 

        return False 
    
    # Returns: 
    # - A Ruby list of possible move sequences 
    # sequences
    #   - ex. '[
    #            [ [[2, 3], [3, 4]], [[3, 4], [7, 4]] ]
    #          ]'
    def possible_sequences(self, state, turn):
        board = json.loads(state)
        sequences = []
        
        for i, row in enumerate(board):
            for j, col in enumerate(board[i]):
                if col.lower() == turn:
                    sequences += self.move_sequences_for_piece(board, [i, j])

        jump_found = False 

        for sequence in sequences:
            # print "looking at", sequence
            if len(sequence) > 1:
                jump_found = True
                break 
            elif len(sequence) == 1:
                src, dst = sequence[0][0], sequence[0][1]

                if abs(src[0] - dst[0]) == 2 and abs(src[1] - dst[1]) == 2:
                    jump_found = True 
                    break 

        if jump_found:
            sequences_copy = copy.deepcopy(sequences)
            
            for sequence_c in sequences_copy:
                if len(sequence_c) == 1:
                    src, dst = sequence_c[0][0], sequence_c[0][1]

                    if abs(src[0] - dst[0]) == 1 and abs(src[1] - dst[1]) == 1:
                        # print "removing", sequence_c, "..."
                        sequences.remove(sequence_c)
                        
        return sequences 

    def move_sequences_for_piece(self, board, src, depth = 0):
        new_board = copy.deepcopy(board)
        srcpiece = new_board[src[0]][src[1]]

        if srcpiece == ' ':
            return []

        if depth == 0:
            check_forward = True 
        else:
            check_forward = False 
          
        moves = self.moves_for_piece(board, src, check_forward)
        # print "moves for", src ,":", moves 

        if len(moves) == 0:
            return []
          
        sequence = []
        sequences = [] 
      
        for move in moves:
            sequence = []
            sequence.append(move)
            was_jump = False 
            kinged = False 

            src, dst = move 
          
            # if the move is a jump
            if abs(src[0] - dst[0]) == 2 and abs(src[1] - dst[1]) == 2:
                r = (src[0] + dst[0]) / 2
                c = (src[1] + dst[1]) / 2

                # remove middle piece 
                new_board[r][c] = ' '

                # move jumping piece 
                new_board[src[0]][src[1]], new_board[dst[0]][dst[1]] = new_board[dst[0]][dst[1]], new_board[src[0]][src[1]]
                was_jump = True 
            else:
                # move piece 
                new_board[src[0]][src[1]], new_board[dst[0]][dst[1]] = new_board[dst[0]][dst[1]], new_board[src[0]][src[1]]

            new_piece = new_board[dst[0]][dst[1]]
            
            if new_piece == 'b' and dst[0] == len(new_board) - 1 or \
               new_piece == 'r' and dst[0] == 0:
                kinged = True 

            # Check if more jumps are available
            if was_jump and not kinged:
                new_sequence = self.move_sequences_for_piece(new_board, dst, depth + 1)
                if len(new_sequence) > 0:
                    sequence += new_sequence[0]
              
            sequences.append(sequence) 

        return sequences 
    
    # Gets the moves that a piece can go to
    # moves are of the form [[a, b], [b, c]]
    def moves_for_piece(self, board, src, check_forward=True):
        srcpiece = board[src[0]][src[1]]
        moves = []

        # print 'srcpiece:', srcpiece 

        if srcpiece == 'b' or srcpiece == 'B':
            # check for down left jump
            # print "src:", src
            if src[1] - 2 >= 0 and src[0] + 2 < len(board) and src[1] - 2 >= 0:
                r = src[0] + 2
                c = src[1] - 2

                if board[r][c] == ' ' and board[r - 1][c + 1].lower() == 'r':
                    # print "adding:", [src, [r, c]]
                    moves.append([src, [r, c]])

            # check for down right jump
            if src[1] + 2 < len(board[0]) and src[0] + 2 < len(board) and src[1] + 2 < len(board):
                r = src[0] + 2
                c = src[1] + 2

                if board[r][c] == ' ' and board[r - 1][c - 1].lower() == 'r':
                    moves.append([src, [r, c]])

            # If the piece is a king
            if srcpiece == 'B':
                # check up left
                if src[1] - 2 >= 0 and src[0] - 2 >= 0 and src[1] - 2 >= 0:
                    r = src[0] - 2
                    c = src[1] - 2

                    if board[r][c] == ' ' and board[r + 1][c + 1].lower() == 'r':
                        moves.append([src, [r, c]])

                # check up right
                if src[1] + 2 <= len(board[0]) and src[0] - 2 >= 0 and src[1] + 2 < len(board):
                    r = src[0] - 2
                    c = src[1] + 2

                    if board[r][c] == ' ' and board[r + 1][c - 1].lower() == 'r':
                        moves.append([src, [r, c]])

        elif srcpiece == 'r' or srcpiece == 'R':
            # check for up left jump
            if src[1] - 2 >= 0 and src[0] - 2 >= 0 and src[1] - 2 >= 0:
                r = src[0] - 2
                c = src[1] - 2

                if board[r][c] == ' ' and board[r + 1][c + 1].lower() == 'b':
                    moves.append([src, [r, c]])

            # check for up right jump
            if src[1] + 2 < len(board[0])  and src[0] - 2 >= 0 and src[1] + 2 < len(board):
                r = src[0] - 2
                c = src[1] + 2

                if board[r][c] == ' ' and board[r + 1][c - 1].lower() == 'b':
                    moves.append([src, [r, c]])

            # If the piece is a king
            if srcpiece == 'R':
                # check down left
                if src[1] - 2 >= 0 and src[0] + 2 < len(board) and src[1] - 2 >= 0:
                    r = src[0] + 2
                    c = src[1] - 2

                    if board[r][c] == ' ' and board[r - 1][c + 1].lower() == 'b':
                        moves.append([src, [r, c]])

                # check down right
                if src[1] + 2 <= len(board[0]) and src[0] + 2 < len(board) and src[1] + 2 < len(board):
                    r = src[0] + 2
                    c = src[1] + 2

                    if board[r][c] == ' ' and board[r - 1][c - 1].lower() == 'b':
                        moves.append([src, [r, c]])

        # check for forward moves 
        if len(moves) == 0 and check_forward:
            if srcpiece == 'b' or srcpiece == 'B':
                # check for down left jump
                if src[1] - 1 >= 0 and src[0] + 1 < len(board) and src[1] - 1 >= 0:
                    r = src[0] + 1
                    c = src[1] - 1

                    if board[r][c] == ' ':
                        moves.append([src, [r, c]])

                # check for down right jump
                if src[1] + 1 < len(board[0])  and src[0] + 1 < len(board) and src[1] + 1 < len(board):
                    r = src[0] + 1
                    c = src[1] + 1

                    if board[r][c] == ' ':
                        moves.append([src, [r, c]])

                # If the piece is a king
                if srcpiece == 'B':
                    # check up left
                    if src[1] - 1 >= 0 and src[0] - 1 >= 0 and src[1] - 1 >= 0:
                        r = src[0] - 1
                        c = src[1] - 1

                        if board[r][c] == ' ':
                            moves.append([src, [r, c]])

                    # check up right
                    if src[1] + 1 <= len(board[0]) and src[0] - 1 >= 0 and src[1] + 1 < len(board):
                        r = src[0] - 1
                        c = src[1] + 1

                        if board[r][c] == ' ':
                            moves.append([src, [r, c]])

            elif srcpiece == 'r' or srcpiece == 'R':
                # check for up left jump
                if src[1] - 1 >= 0 and src[0] - 1 >= 0 and src[1] - 1 >= 0:
                    r = src[0] - 1
                    c = src[1] - 1

                    if board[r][c] == ' ':
                        moves.append([src, [r, c]])

                # check for up right jump
                if src[1] + 1 < len(board[0])  and src[0] - 1 >= 0 and src[1] + 1 < len(board):
                    r = src[0] - 1
                    c = src[1] + 1

                    if board[r][c] == ' ':
                        moves.append([src, [r, c]])

                # If the piece is a king
                if srcpiece == 'R':
                    # check down left
                    if src[1] - 1 >= 0 and src[0] + 1 < len(board) and src[1] - 1 >= 0:
                        r = src[0] + 1
                        c = src[1] - 1

                        if board[r][c] == ' ':
                            moves.append([src, [r, c]])

                    # check down right
                    if src[1] + 1 < len(board[0]) and src[0] + 1 < len(board) and src[1] + 1 < len(board):
                        r = src[0] + 1
                        c = src[1] + 1

                        if board[r][c] == ' ':
                            moves.append([src, [r, c]])
                        
        return moves 

    # Makes sure the sequence can be done.
    # Does NOT enforce jumps, etc.
    # Parameters:
    # - state = A board state (2-D array, example can be found
    #                          elsewhere in documentation)
    # - sequence = a sequence of moves of the form
    #              [[[a, b], [b, c]], [[c, d], [d, e]]]
    # - turn = 'b' or 'r' represent Black/Red's turn
    def is_valid_sequence(self, state, sequence, turn):
        board = json.loads(state)
        valid = True  

        for move in sequence:
            valid = valid and self.is_valid_move(state, move, turn)

            if not valid:
                return False

                # Get the move 
                src, dst = move

                # Make the move 
                board[src[0]][src[1]],
                board[dst[0]][dst[1]] = ' ', board[src[0]][src[1]]

                if abs(src[0] - dst[0]) == 2 and abs(src[1] - dst[1]) == 2:
                    r = (src[0] + dst[0]) / 2
                    c = (src[1] + dst[1]) / 2

                    board[r][c] = ' ' 

        return True  

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
    def is_valid_move(self, state, move, turn):
        board = json.loads(state)

        src, dst = move
      
        # Get the piece that is going to be
        # moved 
        srcpiece = board[src[0]][src[1]]
        dstpiece = board[dst[0]][dst[1]]
      
        # Make sure the src piece is the
        # same as the turn and the destination
        # is an empty space
        if srcpiece.lower() != turn or dstpiece != ' ':
            return False 
        
        return True 




class CheckersAI(object):
    def __init__(self):
        pass 

    def get_move_random(self, state, turn):
        c = CheckersGame()
        sequences = c.possible_sequences(state, turn)

        print sequences 

        x = random.choice(sequences)
        return x

def get_move(state, time_left, turn):
    ai = CheckersAI()

    return json.dumps(ai.get_move_random(state, turn))

