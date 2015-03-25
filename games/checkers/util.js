
function getMousePos(canvas, evt) 
{
	var rect = canvas.getBoundingClientRect();
	return {
		x: evt.clientX - rect.left,
		y: evt.clientY - rect.top
	};
}

function replaceAll(str, find, replace) 
{
  	var i = str.indexOf(find);
  	if (i > -1)
  	{
    	str = str.replace(find, replace); 
    	i = i + replace.length;
    	var st2 = str.substring(i);
    	
    	if(st2.indexOf(find) > -1)
      		str = str.substring(0,i) + replaceAll(st2, find, replace);
  	}
	return str;
}

function rcstr(row, col)
{
  return row.toString() + "," + col.toString();
}

// recursive function to clone an object. If a non object parameter
// is passed in, that parameter is returned and no recursion occurs.
 
function cloneObject(o) 
{
   var out, v, key;
   out = Array.isArray(o) ? [] : {};
   for (key in o) {
       v = o[key];
       out[key] = (typeof v === "object") ? cloneObject(v) : v;
   }
   return out;
}

Array.prototype.remove = function() 
{
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) 
    {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) 
        {
            this.splice(ax, 1);
        }
    }
    return this;
};
