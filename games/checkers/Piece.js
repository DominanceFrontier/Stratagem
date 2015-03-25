
// value = string to represent the piece
var Piece = function(value)
{
  this.value = value; 
};

Piece.prototype.toString = function()
{
  return this.value;
};

