
function draw_image(context, imgpath, location)
{
	var img = new Image();
	img.src = imgpath;
	img.onload = function()
	{
		context.drawImage(img, location.x, location.y);
	};
}

function draw_rectangle(context, location, w, h, color)
{
	context.beginPath();
	context.rect(location.x, location.y, w, h);
	context.fillStyle = color;
	context.fill();
}

function draw_filled_circle(context, center, r, color, stroke_w, stroke_c)
{
	context.beginPath();
	context.arc(center.x, center.y, r, 2 * Math.PI, false);
	context.fillStyle = color;
	context.fill();
	context.strokeStyle = stroke_c;
	context.lineWidth = stroke_w;
	context.stroke();
}

function draw_outlined_circle(context, location, r, color, stroke_w)
{
	context.beginPath();
	context.arc(location.x, location.y, r, 2 * Math.PI, false);
	context.strokeStyle = color;
	context.lineWidth = stroke_w;
	context.stroke();
}

function draw_line(context, x1, x2, y1, y2, color, stroke_w)
{
	context.beginPath();
	context.moveTo(x1, y1);
	context.lineWidth = stroke_w;
	context.lineTo(x2, y2);
	context.strokeStyle = color;
	context.stroke();
	context.closePath();
}

// Draws an 'X' shape
function draw_x(context, center, w, h, color, stroke_w)
{
	var x1, x2, y1, y2;
	x1 = center.x - w;
	x2 = center.x + w;
	y1 = center.y - h;
	y2 = center.y + h;

	// draw diagonal down left-to-right
	// line
	draw_line(context, x1, x2, y1, y2, color, stroke_w);

	// draw diagonal down right-to-left
	// line
	draw_line(context, x2, x1, y1, y2, color, stroke_w);
}
