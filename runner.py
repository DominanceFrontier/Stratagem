import sys

if __name__ == "__main__":
    sys.path.append(sys.argv[1])
    script = sys.argv[2]
    exec('import %s as script' % script)
    #reload(script)
    state = sys.argv[3]
    time_left = int(sys.argv[4])
    player = sys.argv[5]
    sys.stdout.write(script.get_move(state, time_left, player))
