
var CANVAS_WIDTH = 640;
var CANVAS_HEIGHT = 700;
var BOARD_ROWS = 8;
var BOARD_COLS = 8;
var TILE_WIDTH = 80;
var TILE_HEIGHT = 80;
var FPS = 30;


var Rect = function(x, y, w, h)
{
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
};

Rect.prototype.right = function()
{
    return this.x + this.w; 
};

Rect.prototype.bottom = function()
{
    return this.y + this.h;
};

Rect.prototype.collide_point = function(x, y)
{
    return ((x >= this.x && x <= this.right()) &&
      (y >= this.y && y <= this.bottom()));
};

var CheckersView = function(parent, x, y, w, h, canvas_element)
{
    // The bounding rectangle for the view
    this.rect = new Rect(x, y, w, h);

    // The DOM element for te canvas
    this.canvas_element = canvas_element;

    // The canvas' context (i.e. the thing that draws stuff)
    this.context = canvas_element.getContext("2d");

    // Characters that represent a turn
    this.turn_chars = ["b", "r"];

    // Colors for each turn (element 0 applies to turn_chars[0] etc)
    this.turn_colors = ["black", "#B8022C"];

    // Stores the rectangles for the tiles
    // 2D-Array
    this.tile_rects = [];

    // Initialize an image element for the 
    // "Kinged" image
    this.king_image = new Image();
    this.king_image.src = "/assets/crown-small.png";

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

    this.board = [];

    this.init();
    this.wire_events();
};

CheckersView.prototype.wire_events = function()
{
    this.canvas_element.addEventListener('click', this.handle_input.bind(this));
}

// Create tile rectangles 
CheckersView.prototype.init = function()
{
    var drawx = this.rect.x, drawy = this.rect.y;

    for (i = 0; i < BOARD_ROWS; i++)
    {
    	var row = [];
    	drawx = this.rect.x; 
    	for (j = 0; j < BOARD_COLS; j++)
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
    
};

CheckersView.prototype.update = function(state)
{
    this.board = state; 
};  

CheckersView.prototype.draw = function()
{
    var color_counter = 1;
    this.context.font = '40pt Verdana';
    
    // TODO: Update display for turn and
    // winner (probably use HTML element
    // instead of canvas)

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

    for (var i = 0; i < this.board.length; i++)
    {
        for (var j = 0; j < this.board[i].length)
        {
            var cx = this.rect.x + j * TILE_WIDTH + TILE_WIDTH / 2;
            var cy = this.rect.y + i * TILE_HEIGHT + TILE_HEIGHT / 2;
            var color = (this.board[i][j] == this.parent.game.turn_values[0]) ? this.turn_colors[0] : this.turn_colors[1];

            draw_filled_circle(this.context, {x: cx, y: cy}, 
                       (TILE_WIDTH - 10) / 2, color, 1, "#ffff66");

            if (a.piece.is_king)
            {
                var x = this.rect.x + j * TILE_WIDTH + this.king_image.width / 2;
                var y = this.rect.y + i * TILE_HEIGHT + this.king_image.height / 2;
                this.context.drawImage(this.king_image, x, y);
            }
        }
    }
    
};
