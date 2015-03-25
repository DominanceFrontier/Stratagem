
var CheckersPiece = function(value)
{
  Piece.call(this, value);

  this.is_king = false;
};

CheckersPiece.prototype.king = function()
{
  this.is_king = true; 
};

