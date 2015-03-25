
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

