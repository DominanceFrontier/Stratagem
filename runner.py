import sys

if __name__ == "__main__":
    sys.path.append(sys.argv[1])
    script = sys.argv[2]
    exec('import %s as script' % script)
    #reload(script)
    
    sys.stdout.write(script.get_move(sys.argv[3]))
