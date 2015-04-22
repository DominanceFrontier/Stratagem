import random, json, time

def get_move(state, time_left=None, player=None):
    for i in xrange(100000000):
        pass
    state = json.loads(state)
    openings = [tile for row in state for tile in row]
    openings = [i for i in range(len(openings)) if openings[i] == ' ']
    choice = random.choice(openings)
    
    move_r = choice / 3 
    move_c = choice % 3
    
    return json.dumps((move_r, move_c))
