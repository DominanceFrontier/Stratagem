import collections, copy, json, sys

def get_possible_moveseqs(board, player):
    moveseqs = collections.defaultdict(list)
    board_size = len(board)
    opponent = 'r'
    player_king = 'B'
    opponent_king = 'R'
    unit_forward = 1
    
    if player == 'r':
        opponent = 'b'
        player_king = 'R'
        opponent_king = 'B'
        unit_forward = -1

    jumps_exist = False
    board_master = copy.deepcopy(board)
    for row_num, row in enumerate(board):
        for col_num, col_char in enumerate(row):
            if col_char == player:
                active_sequences = [[0, [(row_num, col_num)], copy.deepcopy(board)]]                
                while active_sequences:
                    split_sequences = []
                    for seq_index, seq in enumerate(active_sequences):
                        current_path = seq[1]
                        current_board = seq[-1]
                        current_pos = current_path[-1]
                        current_row_num = current_pos[0]
                        current_col_num = current_pos[1]
                        next_row_num = current_row_num + unit_forward
                        jump_dest_row_num = next_row_num + unit_forward
                        row_within_bounds = jump_dest_row_num >= 0 and jump_dest_row_num <= board_size - 1
                        seq_modified = False

                        if row_within_bounds and current_col_num > 1:
                            next_lcol_num = current_col_num - 1
                            next_lcol_char = current_board[next_row_num][next_lcol_num]
                            
                            if next_lcol_char == opponent or next_lcol_char == opponent_king:
                                jump_dest_col_num = next_lcol_num - 1
                                jump_dest_char = current_board[jump_dest_row_num][jump_dest_col_num]
                                
                                if jump_dest_char == ' ' :
                                    unmodified_board = copy.deepcopy(current_board)
                                    unmodified_path = copy.deepcopy(current_path)
                                    current_board[current_row_num][current_col_num] = ' '
                                    current_board[next_row_num][next_lcol_num] = ' '
                                    current_board[jump_dest_row_num][jump_dest_col_num] = col_char
                                    jumps_exist = True
                                    seq_modified = True
                                    seq[0] += 1
                                    current_path.append((jump_dest_row_num, jump_dest_col_num))
                                    current_board = unmodified_board
                                    current_path = unmodified_path
                                    
                        if row_within_bounds and current_col_num < board_size - 2:
                            next_rcol_num = current_col_num + 1
                            next_rcol_char = current_board[next_row_num][next_rcol_num]

                            if next_rcol_char == opponent or next_rcol_char == opponent_king:
                                jump_dest_col_num = next_rcol_num + 1
                                jump_dest_char = current_board[jump_dest_row_num][jump_dest_col_num]
                                
                                if jump_dest_char == ' ' :
                                    current_board[current_row_num][current_col_num] = ' '
                                    current_board[next_row_num][next_rcol_num] = ' '
                                    current_board[jump_dest_row_num][jump_dest_col_num] = col_char
                                    current_path.append((jump_dest_row_num, jump_dest_col_num))
                                    jumps_exist = True
                                    
                                    if seq_modified:
                                        split_sequences.append([seq[0], current_path, current_board])
                                    else:
                                        seq[0] += 1
                                        
                                    seq_modified = True

                        if not seq_modified :
                            if seq[0] > 0:
                                moveseqs[seq[0]].append(seq[1:])
                            seq = active_sequences.pop(seq_index)
                            
                    if split_sequences:
                        active_sequences.extend(split_sequences)                    

                if not jumps_exist:
                    current_path = seq[1]
                    current_board = seq[-1]
                    current_pos = current_path[-1]
                    current_row_num = current_pos[0]
                    current_col_num = current_pos[1]
                    next_row_num = current_row_num + unit_forward
                    row_within_bounds = next_row_num >= 0 and next_row_num <= board_size - 1
                    
                    if row_within_bounds and current_col_num > 0:
                        next_lcol_num = current_col_num - 1
                        next_lcol_char = current_board[next_row_num][next_lcol_num]
                                                        
                        if next_lcol_char == ' ':
                            unmodified_board = copy.deepcopy(current_board)
                            unmodified_path = copy.deepcopy(current_path)
                            current_board[current_row_num][current_col_num] = ' '
                            current_board[next_row_num][next_lcol_num] = col_char
                            current_path.append((next_row_num, next_lcol_num))
                            current_board = unmodified_board
                            current_path = unmodified_path
                            moveseqs[0].append(seq[1:])

                    if row_within_bounds and current_col_num < board_size - 1:
                        next_rcol_num = current_col_num + 1
                        next_rcol_char = current_board[next_row_num][next_rcol_num]
                                                        
                        if next_rcol_char == ' ':
                            current_board[current_row_num][current_col_num] = ' '
                            current_board[next_row_num][next_rcol_num] = col_char
                            current_path.append((next_row_num, next_rcol_num))
                            
                            moveseqs[0].append([current_path, current_board])

            if col_char == player_king:
                active_sequences = [[0, [(row_num, col_num)], copy.deepcopy(board)]]
                
                while active_sequences:
                    split_sequences = []
                    for seq_index, seq in enumerate(active_sequences):
                        current_path = seq[1]
                        current_board = seq[-1]
                        current_pos = current_path[-1]
                        
                        current_row_num = current_pos[0]
                        fnext_row_num = current_row_num + unit_forward
                        fjump_dest_row_num = fnext_row_num + unit_forward
                        frow_within_bounds = fjump_dest_row_num >= 0 and fjump_dest_row_num <= board_size - 1
                        bnext_row_num = current_row_num - unit_forward
                        bjump_dest_row_num = bnext_row_num - unit_forward
                        brow_within_bounds = bjump_dest_row_num >= 0 and bjump_dest_row_num <= board_size - 1

                        current_col_num = current_pos[1]
                        next_lcol_num = current_col_num - 1
                        ljump_dest_col_num = next_lcol_num - 1
                        lcol_within_bounds = ljump_dest_col_num >= 0 and ljump_dest_col_num <= board_size - 1
                        next_rcol_num = current_col_num + 1
                        rjump_dest_col_num = next_rcol_num + 1
                        rcol_within_bounds = rjump_dest_col_num >= 0 and rjump_dest_col_num <= board_size - 1

                        seq_modified = False

                        if frow_within_bounds and lcol_within_bounds:
                            fnext_lcol_char = current_board[fnext_row_num][next_lcol_num]
                            
                            if fnext_lcol_char == opponent or fnext_lcol_char == opponent_king:
                                fljump_dest_char = current_board[fjump_dest_row_num][ljump_dest_col_num]
                                
                                if fljump_dest_char == ' ' :
                                    unmodified_board = copy.deepcopy(current_board)
                                    unmodified_path = copy.deepcopy(current_path)
                                    current_board[current_row_num][current_col_num] = ' '
                                    current_board[fnext_row_num][next_lcol_num] = ' '
                                    current_board[fjump_dest_row_num][ljump_dest_col_num] = col_char
                                    current_path.append((fjump_dest_row_num, ljump_dest_col_num))

                                    seq[0] -= 1
                                    seq_modified = True
                                    
                                    jumps_exist = True

                                    current_board = unmodified_board
                                    current_path = unmodified_path
                                    
                        if frow_within_bounds and rcol_within_bounds:
                            fnext_rcol_char = current_board[fnext_row_num][next_rcol_num]
                            if fnext_rcol_char == opponent or fnext_rcol_char == opponent_king:
                                frjump_dest_char = current_board[fjump_dest_row_num][rjump_dest_col_num]
                                if frjump_dest_char == ' ' :
                                    unmodified_board = copy.deepcopy(current_board)
                                    unmodified_path = copy.deepcopy(current_path)
                                    current_board[current_row_num][current_col_num] = ' '
                                    current_board[fnext_row_num][next_rcol_num] = ' '
                                    current_board[fjump_dest_row_num][rjump_dest_col_num] = col_char
                                    current_path.append((fjump_dest_row_num, rjump_dest_col_num))
                                                                        
                                    if seq_modified:
                                        split_sequences.append([seq[0], current_path, current_board])
                                    else:
                                        seq[0] -= 1                                        
                                    seq_modified = True
                                    jumps_exist = True
                                    current_board = unmodified_board
                                    current_path = unmodified_path

                        if brow_within_bounds and lcol_within_bounds:
                            bnext_lcol_char = current_board[bnext_row_num][next_lcol_num]

                            if bnext_lcol_char == opponent or bnext_lcol_char == opponent_king:
                                bljump_dest_char = current_board[bjump_dest_row_num][ljump_dest_col_num]
                                
                                if bljump_dest_char == ' ' :
                                    unmodified_board = copy.deepcopy(current_board)
                                    unmodified_path = copy.deepcopy(current_path)
                                    current_board[current_row_num][current_col_num] = ' '
                                    current_board[bnext_row_num][next_lcol_num] = ' '
                                    current_board[bjump_dest_row_num][ljump_dest_col_num] = col_char
                                    current_path.append((bjump_dest_row_num, ljump_dest_col_num))
                                                                        
                                    if seq_modified:
                                        split_sequences.append([seq[0], current_path, current_board])
                                    else:
                                        seq[0] -= 1                                        
                                    seq_modified = True
                                    
                                    jumps_exist = True

                                    current_board = unmodified_board
                                    current_path = unmodified_path

                        if brow_within_bounds and rcol_within_bounds:
                            bnext_rcol_char = current_board[bnext_row_num][next_rcol_num]

                            if bnext_rcol_char == opponent or bnext_rcol_char == opponent_king:
                                brjump_dest_char = current_board[bjump_dest_row_num][rjump_dest_col_num]
                                
                                if brjump_dest_char == ' ' :
                                    current_board[current_row_num][current_col_num] = ' '
                                    current_board[bnext_row_num][next_rcol_num] = ' '
                                    current_board[bjump_dest_row_num][rjump_dest_col_num] = col_char
                                    current_path.append((bjump_dest_row_num, rjump_dest_col_num))
                                                                        
                                    if seq_modified:
                                        split_sequences.append([seq[0], current_path, current_board])
                                    else:
                                        seq[0] -= 1                                        
                                    seq_modified = True
                                    jumps_exist = True
                                    
                        if not seq_modified :
                            if seq[0] < 0:
                                moveseqs[seq[0]].append(seq[1:])
                            seq = active_sequences.pop(seq_index)
                            
                    if split_sequences:
                        active_sequences.extend(split_sequences)                    

                if not jumps_exist:
                    current_path = seq[1]
                    current_board = seq[-1]
                    current_pos = current_path[-1]

                    current_row_num = current_pos[0]
                    fnext_row_num = current_row_num + unit_forward
                    frow_within_bounds = fnext_row_num >= 0 and fnext_row_num <= board_size - 1
                    bnext_row_num = current_row_num - unit_forward
                    brow_within_bounds = bnext_row_num >= 0 and bnext_row_num <= board_size - 1

                    current_col_num = current_pos[1]
                    next_lcol_num = current_col_num - 1
                    lcol_within_bounds = next_lcol_num >= 0 and next_lcol_num <= board_size - 1
                    next_rcol_num = current_col_num + 1
                    rcol_within_bounds = next_rcol_num >= 0 and next_rcol_num <= board_size - 1

                    split_necessary = False
                    
                    if frow_within_bounds and lcol_within_bounds:
                        fnext_lcol_char = current_board[fnext_row_num][next_lcol_num]
                                                        
                        if fnext_lcol_char == ' ':
                            unmodified_board = copy.deepcopy(current_board)
                            unmodified_path = copy.deepcopy(current_path)
                            current_board[current_row_num][current_col_num] = ' '
                            current_board[fnext_row_num][next_lcol_num] = col_char
                            current_path.append((fnext_row_num, next_lcol_num))
                            moveseqs[-99].append([current_path, current_board])
                            current_board = unmodified_board
                            current_path = unmodified_path

                    if frow_within_bounds and rcol_within_bounds:
                        fnext_rcol_char = current_board[fnext_row_num][next_rcol_num]
                                                        
                        if fnext_rcol_char == ' ':
                            unmodified_board = copy.deepcopy(current_board)
                            unmodified_path = copy.deepcopy(current_path)
                            current_board[current_row_num][current_col_num] = ' '
                            current_board[fnext_row_num][next_rcol_num] = col_char
                            current_path.append((fnext_row_num, next_rcol_num))
                            moveseqs[-99].append([current_path, current_board])
                            current_board = unmodified_board
                            current_path = unmodified_path

                    if brow_within_bounds and lcol_within_bounds:
                        bnext_lcol_char = current_board[bnext_row_num][next_lcol_num]
                                                        
                        if bnext_lcol_char == ' ':
                            unmodified_board = copy.deepcopy(current_board)
                            unmodified_path = copy.deepcopy(current_path)
                            current_board[current_row_num][current_col_num] = ' '
                            current_board[bnext_row_num][next_lcol_num] = col_char
                            current_path.append((bnext_row_num, next_lcol_num))
                            moveseqs[-99].append([current_path, current_board])
                            current_board = unmodified_board
                            current_path = unmodified_path

                    if brow_within_bounds and rcol_within_bounds:
                        bnext_rcol_char = current_board[bnext_row_num][next_rcol_num]
                                                        
                        if bnext_rcol_char == ' ':
                            current_board[current_row_num][current_col_num] = ' '
                            current_board[bnext_row_num][next_rcol_num] = col_char
                            current_path.append((bnext_row_num, next_rcol_num))                            
                            moveseqs[-99].append([current_path, current_board])
                            
    return moveseqs

def adapter(ms):
    i = 0
    new_ms = []
    while True:
        try:
            new_ms.append([list(ms[i]), list(ms[i+1])])
            i += 1
        except IndexError:
            break
    return new_ms

def is_valid_move(board, move, player):
    board = json.loads(board)
    move = json.loads(move)
    player = player
    moveseqs = get_possible_moveseqs(board, player)

    for mss in moveseqs.values():
        for ms in mss:
            adapted_ms = adapter(ms[0])
            if move == adapted_ms:
                return True
    return False

def opponent_has_move(board, player):
    board = json.loads(board)
    opponent = 'r'
    if player == 'r':
        opponent = 'b'
    ms = get_possible_moveseqs(board, opponent)
    return True if ms else False

if __name__ == "__main__":
    function = sys.argv[1]
    board = sys.argv[2]
    player = sys.argv[3]
    if function == "is_valid_move?":
        move = sys.argv[4]
        print is_valid_move(board, move, player)
    else:
        print opponent_has_move(board, player)
