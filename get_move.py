
def get_move(state, time_left):
	import random 
	state = list(state)
        openings = [i for i in range(len(state)) if state[i] == ' ']
	choice = random.choice(openings)

	move_r = choice / 3 
	move_c = choice % 3

	return "%s, %s" % (move_r, move_c)
