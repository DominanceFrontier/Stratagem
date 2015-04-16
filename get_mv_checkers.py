import random, json, time

def get_move(state, time_left=None, player=None):
    for i in xrange(100000000):
        pass
    state = json.loads(state)

    rows_with_player = [row for row in enumerate(state) if player in row[1]]
    if player == 'b':
        direction = 1
        chosen_row = rows_with_player[-1]
    else:
        direction = -1
        chosen_row = rows_with_player[0]
    origin_r = chosen_row[0]
    cols_with_player = [col for col in enumerate(chosen_row[1]) if col[1] == player]
    origin_c = random.choice(cols_with_player)[0]
    move_r = origin_r + direction
    move_c = origin_c + 2
    
    return json.dumps([(origin_r, origin_c), (move_r, move_c)])
