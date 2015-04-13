# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Game.create(name: 'Tic-Tac-Toe', path: "#{Rails.root.to_s}/games/ttt/game.js",
            p1_symbol: 'x', p2_symbol: 'o',
            initial_state: "[[\" \",\" \",\" \"],[\" \",\" \",\" \"],[\" \",\" \",\" \"]]")
Game.create(name: 'Checkers', path: "#{Rails.root.to_s}/games/checkers/game.js",
            p1_symbol: 'r', p2_symbol: 'b',
            initial_state: '[[" ","b"," ","b"," ","b"," ","b"],["b"," ","b"," ","b"," ","b"," "],[" ","b"," ","b"," ","b"," ","b"],[" "," "," "," "," "," "," "," "],[" "," "," "," "," "," "," "," "],["r"," ","r"," ","r"," ","r"," "],[" ","r"," ","r"," ","r"," ","r"],["r"," ","r"," ","r"," ","r"," "]]')
