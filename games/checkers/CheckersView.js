
var CheckersView = function(parent, x, y, w, h, canvas_element)
{
	// Stores a reference to a Match object
	this.parent = parent;

	// The bounding rectangle for the view
	this.rect = new Rect(x, y, w, h);

	// The DOM element for te canvas
	this.canvas_element = canvas_element;

	// The canvas' context (i.e. the thing that draws stuff)
	this.context = canvas_element.getContext("2d");

	// Characters that represent a turn
	this.turn_chars = parent.game.turn_values;

	// Colors for each turn (element 0 applies to turn_chars[0] etc)
	this.turn_colors = ["black", "#B8022C"];

	// Stores the rectangles for the tiles
	// 2D-Array
	this.tile_rects = [];

	// Initialize an image element for the 
	// "Kinged" image
	this.king_image = new Image();
	this.king_image.src = "images/crown-small.png";

	this.king_img_loaded = false;

	// Row and column for a piece that the user
	// selects
	this.selected_piece_r = -1;
	this.selected_piece_c = -1;

	// The color to highlight tiles for possible 
	// moves (when match state = 1)
	this.selected_tile_color = "#76A2F5";

	// A container for possible moves
	this.possible_moves = null;

	this.init();
	this.wire_events();
};

CheckersView.prototype.wire_events = function()
{
	this.canvas_element.addEventListener('click', this.handle_input.bind(this));
}

// Update the display of move history with the 
// match's new history 
CheckersView.prototype.update_move_history = function()
{
	var moves = this.parent.move_history;
	var move_display = document.getElementById("move_history");
	var html = "";

	for (var i = 0; i < moves.length; i++)
	{
		html += "<li>"
		for (var j = 0; j < moves[i].length; j++)
		{
			html += "(" + rcstr(moves[i][j].src.r, moves[i][j].src.c) + ")";
			html += " -> "
			html += "(" + rcstr(moves[i][j].dst.r, moves[i][j].dst.c) + ")";

			if (j != moves[i].length - 1)
				html += ", "
		}

		html += "</li>"
	}

	move_display.innerHTML = html;
}

// Create tile rectangles 
CheckersView.prototype.init = function()
{
	var board = this.parent.board;
	var drawx = this.rect.x, drawy = this.rect.y;

	for (i = 0; i < board.rows; i++)
	{
		var row = [];
		drawx = this.rect.x; 
		for (j = 0; j < board.cols; j++)
		{
			var x = drawx, y = drawy;
			var w = TILE_WIDTH, h = TILE_HEIGHT;

			row.push(new Rect(x, y, w, h));
			drawx += TILE_WIDTH;
		}
		drawy += TILE_HEIGHT;
		this.tile_rects.push(row);
	}
}

// Check for user click input 
CheckersView.prototype.handle_input = function(event)
{
	var r = -1, c = -1;
	var board = this.parent.board;
	var mouse_pos = getMousePos(this.canvas_element, event);
	var rects = this.tile_rects;
	var i = 0, j = 0;

	var assocs = this.parent.board.piece_tile_assocs;

	for (i = 0; i < board.rows; i++)
	{
	    for (j = 0; j < board.cols; j++)
	    {
    		var a = assocs[rcstr(i, j)];

    		// space selected, clear selection
    		if (rects[i][j].collide_point(mouse_pos.x, mouse_pos.y)
    			&& !a)
    		{
    		    r = i;
    		    c = j;
    		    this.selected_piece_r = -1;
    		    this.selected_piece_c = -1;
    		    break;
    		}

    		// if the clicked tile has a piece
    		// and the piece is the same as the turn
	        if (rects[i][j].collide_point(mouse_pos.x, mouse_pos.y) &&
	        	a.piece.value == this.parent.game.turn_values[this.parent.turn])
	        {
	            r = i;
	            c = j;

	            this.selected_piece_r = i;
	            this.selected_piece_c = j;
	            break;
	        }
	    }
	}

	// The user clicked on a valid tile 
	if (r != -1 && c != -1)
	{
		// Tell the match about the move
		this.parent.get_notification({r: r, c: c});

		if (this.parent.is_possible_src(r, c) && this.parent.state == 1)
		{
			this.possible_moves = this.parent.possible_moves;
		}
		else if (this.parent.state == 0)
		{
			this.possible_moves = [];
		}

		// Re-draw the match history 
		this.update_move_history();
		this.draw();
	}
};

CheckersView.prototype.draw = function()
{
	var board = this.parent.board;
	var color_counter = 1;
	this.context.font = '40pt Verdana';
	var game = this.parent.game;
	var turn = game.turn_values[this.parent.turn];
	var print_v = turn;

	// Set fill color
	this.context.clearRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);

	// Draw text to indicate who's turn it is	
	if (!this.parent.game_over)
	{
		this.context.fillStyle = "black";
		this.context.fillText(print_v + "'s turn", 10, 40);
	}
	else
	{
		this.context.fillStyle = "black";
		this.context.fillText(this.parent.winner + " won!", 10, 40);	
	}

	// Draw the tile rects
	for (i = 0; i < board.rows; i++)
	{
		for (j = 0; j < board.cols; j++)
		{
			var rect = this.tile_rects[i][j];
			var color = this.turn_colors[color_counter % this.turn_colors.length];

			draw_rectangle(this.context, {x: rect.x, y: rect.y}, rect.w, rect.h, color);
			color_counter++;
		}
		color_counter++;
	}

	var assocs = this.parent.board.piece_tile_assocs;
	var possible = null;

	if (this.selected_piece_r != -1 && this.selected_piece_c != -1)
	{
		possible = this.possible_moves;

		if (possible)
		{
			var k = 0;
			for (k = 0; k < possible.length; k++)
			{
				var move = possible[k];

				if (move.src.r == this.selected_piece_r && 
					move.src.c == this.selected_piece_c)
				{
					var rect = this.tile_rects[move.dst.r][move.dst.c];
					var color = this.selected_tile_color;
					draw_rectangle(this.context, {x: rect.x, y: rect.y}, rect.w, rect.h, color);
				}
			}
		}
	}

	// for (i = 0; i < assocs.length; i++)
	for (key in assocs)
	{
		if (assocs.hasOwnProperty(key))
		{
			var a = assocs[key];
			var cx = this.rect.x + a.tile.col * TILE_WIDTH + TILE_WIDTH / 2;
			var cy = this.rect.y + a.tile.row * TILE_HEIGHT + TILE_HEIGHT / 2;
			var color = (a.piece.value == this.parent.game.turn_values[0]) ? this.turn_colors[0] : this.turn_colors[1];

			draw_filled_circle(this.context, {x: cx, y: cy}, 
							   (TILE_WIDTH - 10) / 2, color, 1, "#ffff66");

			if (a.piece.is_king)
			{
				var x = this.rect.x + a.tile.col * TILE_WIDTH + this.king_image.width / 2;
				var y = this.rect.y + a.tile.row * TILE_HEIGHT + this.king_image.height / 2;
				this.context.drawImage(this.king_image, x, y);
			}
		}
	}
	
};
