package util.ui;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;

/**
 * Base UI Class for quick UI scripting
 * @author aeveis
 */
enum UIPlacement
{
	Left;
	Right;
	Center;
	CenterY;
	Top;
	Bottom;
	TopLeft;
	BottomLeft;
	TopRight;
	BottomRight;
	Justified;
	JustifiedY;
	CenterXTop;
	CenterXBottom;
	CenterYLeft;
	CenterYRight;
	JustifiedXTop;
	JustifiedXBottom;
	JustifiedYLeft;
	JustifiedYRight;
	Inherit;
	Percent(e_x:Float, e_y:Float);
	Pos(e_x:Float, e_y:Float);
	Grid(e_x:Float, e_y:Float);
}

enum UISize
{
	Fill;
	XFill(e_h:Float);
	YFill(e_w:Float);
	Percent(e_w:Float, e_h:Float);
	XPercent_YSize(e_w:Float, e_h:Float);
	XSize_YPercent(e_w:Float, e_h:Float);
	XFill_YPercent(e_h:Float);
	XPercent_YFill(e_w:Float);
	Size(e_w:Float, e_h:Float);
	XShrink(e_h:Float);
	YShrink(e_w:Float);
	Grid(e_w:Float, e_h:Float);
}

enum UIParent
{
	Game;
	Container(e_parent:UIContainer);
	Camera(e_parent:FlxCamera);
}

typedef Box =
{
	left:Float,
	right:Float,
	top:Float,
	bottom:Float
};

typedef Rect =
{
	x:Float,
	y:Float,
	width:Float,
	height:Float,
	padding:Box,
	margin:Box
};

class UIContainer extends FlxGroup
{
	private var _null:Null<Float> = null;

	public var x(default, set):Float = 0;

	function set_x(p_x:Float):Float
	{
		var offset:Float = p_x - x;
		for (obj in members)
		{
			if (Std.isOfType(obj, FlxObject))
			{
				var flxObj:FlxObject = cast obj;
				flxObj.x += offset;
			}
			else if (Std.isOfType(obj, UIContainer))
			{
				var uiContain:UIContainer = cast obj;
				uiContain.x += offset;
			}
		}
		return x = p_x;
	}

	public var y(default, set):Float = 0;

	function set_y(p_y:Float):Float
	{
		var offset:Float = p_y - y;
		for (obj in members)
		{
			if (Std.isOfType(obj, FlxObject))
			{
				var flxObj:FlxObject = cast obj;
				flxObj.y += offset;
			}
			else if (Std.isOfType(obj, UIContainer))
			{
				var uiContain:UIContainer = cast obj;
				uiContain.y += offset;
			}
		}
		return y = p_y;
	}

	public var width(default, null):Float = 0;
	public var height(default, null):Float = 0;
	public var gridX(default, null):Float = 1;
	public var gridY(default, null):Float = 1;

	public var scrollFactor:FlxCallbackPoint;
	public var opened:Bool = true;
	public var justOpened:Bool = true;
	public var justOpenedDelay:Int = 0;

	public var padding(default, null):Box;
	public var margin(default, null):Box;
	public var size(default, null):UISize;
	public var placement(default, null):UIPlacement;
	public var childPlacement(default, null):UIPlacement;
	public var parent(default, null):UIParent;
	public var parentX(get, null):Float;

	function get_parentX():Float
	{
		switch (parent)
		{
			case UIParent.Game:
				return 0;
			case UIParent.Container(e_parent):
				return e_parent.x;
			case UIParent.Camera(e_parent):
				return e_parent.x;
		}
	}

	public var parentY(get, null):Float;

	function get_parentY():Float
	{
		switch (parent)
		{
			case UIParent.Game:
				return 0;
			case UIParent.Container(e_parent):
				return e_parent.y;
			case UIParent.Camera(e_parent):
				return e_parent.y;
		}
	}

	public var parentWidth(get, null):Float;

	function get_parentWidth():Float
	{
		switch (parent)
		{
			case UIParent.Game:
				return FlxG.width;
			case UIParent.Container(e_parent):
				return e_parent.width;
			case UIParent.Camera(e_parent):
				return e_parent.width;
		}
	}

	public var parentHeight(get, null):Float;

	function get_parentHeight():Float
	{
		switch (parent)
		{
			case UIParent.Game:
				return FlxG.height;
			case UIParent.Container(e_parent):
				return e_parent.height;
			case UIParent.Camera(e_parent):
				return e_parent.height;
		}
	}

	public var parentRect(get, null):Rect;

	function get_parentRect():Rect
	{
		switch (parent)
		{
			case UIParent.Game:
				return {
					x: 0,
					y: 0,
					width: FlxG.width,
					height: FlxG.height,
					padding: UILayout.zeroBox,
					margin: UILayout.zeroBox
				};
			case UIParent.Container(e_parent):
				return {
					x: e_parent.x,
					y: e_parent.y,
					width: e_parent.width,
					height: e_parent.height,
					padding: e_parent.padding,
					margin: e_parent.margin
				};
			case UIParent.Camera(e_parent):
				return {
					x: 0,
					y: 0,
					width: e_parent.width,
					height: e_parent.height,
					padding: UILayout.zeroBox,
					margin: UILayout.zeroBox
				};
		}
	}

	/**
	 * Main `UIContainer` base class. Other UI Containers and FlxBasic types can be added to this. 
	 * @param	p_placement See UIPlacement enum for options.  Determines placement of UI Container in reference to its parent
	 * @param	p_size See UISIze enum for options. Determines size of UI Container
	 * @param	p_childPlacement See UIPlacement enum for options. Determines default placement of children added. Can be overridden if children has a different placement (only works with UIContainer types).
	 * @param	p_padding See options in UILayout. Uses box structure: { left:0, right:0, top:0, bottom:0 } Padding of children elements. 
	 * @param	p_margin See options in UILayout. Uses box structure: { left:0, right:0, top:0, bottom:0 } Margin inside the container. 
	 * @param	p_parent See UIParent enum. Parent of UI Container. This is used for placement settings. Default is just the game screen dimensions. 
	 */
	public function new(?p_placement:UIPlacement, ?p_size:UISize, ?p_childPlacement:UIPlacement, ?p_padding:Box, ?p_margin:Box, ?p_parent:UIParent)
	{
		super();
		scrollFactor = new FlxCallbackPoint(pointXCallback, pointYCallback, pointXYCallback);
		(p_childPlacement == null) ? childPlacement = UIPlacement.TopLeft : setChildPlacement(p_childPlacement);

		(p_parent == null) ? parent = UIParent.Game : parent = p_parent;

		(p_margin == null) ? margin = UILayout.zeroBox : margin = p_margin;
		(p_padding == null) ? padding = UILayout.zeroBox : padding = p_padding;

		if (p_size == null)
			p_size = UISize.Fill;
		setSize(p_size);

		if (p_placement == null)
			p_placement = UIPlacement.TopLeft;
		setPlacement(p_placement);
	}

	public function setParent(p_parent:UIParent)
	{
		parent = p_parent;
		refresh(true);
	}

	public function setSize(p_size:UISize, p_refreshChildren:Bool = false)
	{
		size = p_size;
		var pRect = parentRect;
		var pWidth = pRect.width - (pRect.margin.left + pRect.margin.right);
		var pHeight = pRect.height - (pRect.margin.top + pRect.margin.bottom);
		switch (size)
		{
			case UISize.XFill(e_h):
				width = pWidth;
				height = e_h;
			case UISize.YFill(e_w):
				width = e_w;
				height = pHeight;
			case UISize.XShrink(e_h):
				width = getChildrenWidth();
				height = e_h;
			case UISize.YShrink(e_w):
				width = e_w;
				height = getChildrenHeight();
			case UISize.Percent(e_w, e_h):
				width = pWidth * e_w / 100;
				height = pHeight * e_h / 100;
			case UISize.Size(e_w, e_h):
				width = e_w;
				height = e_h;
			case UISize.XPercent_YSize(e_w, e_h):
				width = pWidth * e_w / 100;
				height = e_h;
			case UISize.XSize_YPercent(e_w, e_h):
				width = e_w;
				height = pHeight * e_h / 100;
			case UISize.XFill_YPercent(e_h):
				width = pWidth;
				height = pHeight * e_h / 100;
			case UISize.XPercent_YFill(e_w):
				width = pWidth * e_w / 100;
				height = pHeight;
			case UISize.Grid(e_w, e_h):
				switch (parent)
				{
					case UIParent.Container(e_parent):
						switch (e_parent.childPlacement)
						{
							case UIPlacement.Grid(_):
								width = (pWidth / e_parent.gridX) * e_w - (pRect.padding.left + pRect.padding.right);
								height = (pHeight / e_parent.gridY) * e_h - (pRect.padding.top + pRect.padding.bottom);
							default:
								width = pWidth;
								height = pHeight;
						}
					default:
						width = pWidth;
						height = pHeight;
				}
			default:
				width = pWidth;
				height = pHeight;
		}

		if (!p_refreshChildren)
			return;
		refreshChildren();
	}

	/**
	 * updates size and placement of object
	 * @param	p_refreshChildren updates children as well
	 */
	public function refresh(p_refreshChildren:Bool = false)
	{
		setSize(size);
		setPlacement(placement);

		if (!p_refreshChildren)
			return;
		refreshChildren();
	}

	public function setPlacement(p_placement:UIPlacement, p_refreshChildren:Bool = false)
	{
		placement = p_placement;
		var pRect = parentRect;
		x = pRect.x;
		y = pRect.y;

		switch (placement)
		{
			case UIPlacement.Left | UIPlacement.CenterYLeft | UIPlacement.JustifiedYLeft:
				x += pRect.margin.left + pRect.padding.left;
				y += pRect.height / 2 - height / 2;
			case UIPlacement.Right | UIPlacement.CenterYRight | UIPlacement.JustifiedYRight:
				x += pRect.width - width - pRect.margin.right - pRect.padding.right;
				y += pRect.height / 2 - height / 2;
			case UIPlacement.Center | UIPlacement.CenterY | UIPlacement.Justified | UIPlacement.JustifiedY:
				x += pRect.width / 2 - width / 2;
				y += pRect.height / 2 - height / 2;
			case UIPlacement.Top | UIPlacement.CenterXTop | UIPlacement.JustifiedXTop:
				x += pRect.width / 2 - width / 2;
				y += pRect.margin.top + pRect.padding.top;
			case UIPlacement.Bottom | UIPlacement.CenterXBottom | UIPlacement.JustifiedXBottom:
				x += pRect.width / 2 - width / 2;
				y += pRect.height - height - pRect.margin.bottom - pRect.padding.bottom;
			case UIPlacement.BottomLeft:
				x += pRect.margin.left + pRect.padding.left;
				y += pRect.height - height - pRect.margin.bottom - pRect.padding.bottom;
			case UIPlacement.TopRight:
				x += pRect.width - width - pRect.margin.right - pRect.padding.right;
				y += pRect.margin.top + pRect.padding.top;
			case UIPlacement.BottomRight:
				x += pRect.width - width - pRect.margin.right - pRect.padding.right;
				y += pRect.height - height - pRect.margin.bottom - pRect.padding.bottom;
			case UIPlacement.Percent(e_x, e_y):
				x += pRect.width * e_x / 100 - width / 2;
				y += pRect.height * e_y / 100 - height / 2;
			case UIPlacement.Pos(e_x, e_y):
				x += e_x;
				y += e_y;
			case UIPlacement.Grid(e_x, e_y):
				switch (parent)
				{
					case UIParent.Container(e_parent):
						var pWidth = pRect.width - (pRect.margin.left + pRect.margin.right);
						var pHeight = pRect.height - (pRect.margin.top + pRect.margin.bottom);
						x += pWidth / e_parent.gridX * e_x + pRect.margin.left + pRect.padding.left;
						y += pHeight / e_parent.gridY * e_y + pRect.margin.top + pRect.padding.top;
					default:
						x += pRect.margin.left + pRect.padding.left;
						y += pRect.margin.top + pRect.padding.top;
				}
			default:
				x += pRect.margin.left + pRect.padding.left;
				y += pRect.margin.top + pRect.padding.top;
		}

		if (!p_refreshChildren)
			return;
		refreshChildren();
	}

	public function setChildPlacement(p_placement:UIPlacement, p_refreshChildren:Bool = false)
	{
		childPlacement = p_placement;
		switch (childPlacement)
		{
			case UIPlacement.Grid(e_x, e_y):
				gridX = e_x;
				gridY = e_y;
			default:
		}

		if (!p_refreshChildren)
			return;
		refreshChildren();
	}

	/**
	 * 
	 * @param	p_margin see UILayout for options
	 * @param	p_refreshChildren
	 */
	public function setMargin(p_margin:Box, p_refreshChildren:Bool = false)
	{
		if (margin == p_margin)
			return;
		margin = p_margin;

		if (!p_refreshChildren)
			return;
		refreshChildren();
	}

	/**
	 * 
	 * @param	p_padding see UILayout for options
	 * @param	p_refreshChildren
	 */
	public function setPadding(p_padding:Box, p_refreshChildren:Bool = false)
	{
		if (padding == p_padding)
			return;
		padding = p_padding;

		if (!p_refreshChildren)
			return;
		refreshChildren();
	}

	public function changeParent(p_parent:UIParent)
	{
		parent = p_parent;
		refresh();
	}

	public function getChildrenWidth()
	{
		var totalLength = 0.0;
		var count = 0;
		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], FlxObject))
			{
				var flxObj = cast members[i];
				switch (childPlacement)
				{
					case UIPlacement.CenterY | UIPlacement.CenterYLeft | UIPlacement.CenterYRight | UIPlacement.Bottom | UIPlacement.Top | UIPlacement.JustifiedY | UIPlacement.JustifiedYLeft | UIPlacement.JustifiedYRight:
						var objLength = flxObj.width;
						if (objLength > totalLength)
						{
							totalLength = objLength;
							count = 1;
						}
					case UIPlacement.Grid(_) | UIPlacement.Percent(_) | UIPlacement.Pos(_):
						return width;
					case UIPlacement.Inherit:
						return flxObj.width;
					default:
						count++;
						totalLength += flxObj.width;
				}
			}
			else if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain = cast members[i];
				if (uiContain.placement == childPlacement || uiContain.placement == UIPlacement.Inherit)
				{
					switch (childPlacement)
					{
						case UIPlacement.CenterY | UIPlacement.CenterYLeft | UIPlacement.CenterYRight | UIPlacement.Bottom | UIPlacement.Top | UIPlacement.JustifiedY | UIPlacement.JustifiedYLeft | UIPlacement.JustifiedYRight:
							var objLength = uiContain.width;
							if (objLength > totalLength)
							{
								totalLength = objLength;
								count = 1;
							}
						case UIPlacement.Grid(_) | UIPlacement.Percent(_) | UIPlacement.Pos(_):
							return width;
						case UIPlacement.Inherit:
							return uiContain.width;
						default:
							count++;
							totalLength += uiContain.width;
					}
				}
			}
		}
		return totalLength + margin.left + margin.right + (padding.left + padding.right) * count;
	}

	public function getChildrenHeight()
	{
		var totalLength = 0.0;
		var count = 0;
		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], FlxObject))
			{
				var flxObj = cast members[i];
				switch (childPlacement)
				{
					case UIPlacement.Center | UIPlacement.CenterXBottom | UIPlacement.CenterXTop | UIPlacement.Left | UIPlacement.Right | UIPlacement.TopLeft | UIPlacement.TopRight | UIPlacement.BottomLeft | UIPlacement.BottomRight | UIPlacement.Justified | UIPlacement.JustifiedXBottom | UIPlacement.JustifiedXTop:
						var objLength = flxObj.height;
						if (objLength > totalLength)
						{
							totalLength = objLength;
							count = 1;
						}
					case UIPlacement.Grid(_) | UIPlacement.Percent(_) | UIPlacement.Pos(_):
						return height;
					case UIPlacement.Inherit:
						return flxObj.height;
					default:
						count++;
						totalLength += flxObj.height;
				}
			}
			else if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain = cast members[i];
				if (uiContain.placement == childPlacement || uiContain.placement == UIPlacement.Inherit)
				{
					switch (childPlacement)
					{
						case UIPlacement.Center | UIPlacement.CenterXBottom | UIPlacement.CenterXTop | UIPlacement.Left | UIPlacement.Right | UIPlacement.Justified | UIPlacement.JustifiedXBottom | UIPlacement.JustifiedXTop:
							var objLength = uiContain.getChildrenHeight();
							if (objLength > totalLength)
							{
								count = 1;
								totalLength = objLength;
							}
						case UIPlacement.Grid(_) | UIPlacement.Percent(_) | UIPlacement.Pos(_):
							return height;
						case UIPlacement.Inherit:
							return uiContain.height;
						default:
							count++;
							totalLength += uiContain.getChildrenHeight();
					}
				}
			}
		}
		return totalLength + margin.top + margin.bottom + (padding.top + padding.bottom) * count;
	}

	public function refreshChildren()
	{
		var tempx = x;
		var tempy = y;
		x = 0;
		y = 0;

		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain:UIContainer = cast members[i];
				uiContain.refresh();
			}
		}

		var totalLength = 0.0;
		if (childPlacement.match(UIPlacement.Center | UIPlacement.CenterY | UIPlacement.CenterXTop | UIPlacement.CenterXBottom | UIPlacement.CenterYLeft | UIPlacement.CenterYRight | UIPlacement.Justified | UIPlacement.JustifiedY | UIPlacement.JustifiedXTop | UIPlacement.JustifiedXBottom | UIPlacement.JustifiedYLeft | UIPlacement.JustifiedYRight))
		{
			for (i in 0...members.length)
			{
				if (Std.isOfType(members[i], FlxObject))
				{
					var flxObj = cast members[i];
					switch (childPlacement)
					{
						case UIPlacement.Center | UIPlacement.CenterXTop | UIPlacement.CenterXBottom:
							totalLength += flxObj.width;
							totalLength += padding.left + padding.right;
						case UIPlacement.Justified | UIPlacement.JustifiedXBottom | UIPlacement.JustifiedXTop:
							totalLength += flxObj.width;
						case UIPlacement.CenterY | UIPlacement.CenterYLeft | UIPlacement.CenterYRight:
							totalLength += flxObj.height;
							totalLength += padding.top + padding.bottom;
						case UIPlacement.JustifiedY | UIPlacement.JustifiedYLeft | UIPlacement.JustifiedYRight:
							totalLength += flxObj.height;
						default:
					}
				}
				else if (Std.isOfType(members[i], UIContainer))
				{
					var uiContain = cast members[i];
					if (uiContain.placement == childPlacement || uiContain.placement == UIPlacement.Inherit)
					{
						switch (childPlacement)
						{
							case UIPlacement.Center | UIPlacement.CenterXTop | UIPlacement.CenterXBottom:
								totalLength += uiContain.width;
								totalLength += padding.left + padding.right;
							case UIPlacement.Justified | UIPlacement.JustifiedXBottom | UIPlacement.JustifiedXTop:
								totalLength += uiContain.width;
							case UIPlacement.CenterY | UIPlacement.CenterYLeft | UIPlacement.CenterYRight:
								totalLength += uiContain.height;
								totalLength += padding.top + padding.bottom;
							case UIPlacement.JustifiedY | UIPlacement.JustifiedYLeft | UIPlacement.JustifiedYRight:
								totalLength += uiContain.height;
							default:
						}
					}
				}
			}
		}

		var xoffset = margin.left + padding.left;
		var yoffset = margin.top + padding.top;
		var joffset = 0.0;

		switch (childPlacement)
		{
			case UIPlacement.Left:
				yoffset = height / 2;
			case UIPlacement.Right:
				xoffset = width - margin.right - padding.right;
				yoffset = height / 2;
			case UIPlacement.Top:
				xoffset = width / 2;
				yoffset = margin.top + padding.top;
			case UIPlacement.Bottom:
				xoffset = width / 2;
				yoffset = height - margin.bottom - padding.bottom;
			case UIPlacement.BottomLeft:
				yoffset = height - margin.bottom - padding.bottom;
			case UIPlacement.TopRight:
				xoffset = width - margin.right - padding.right;
				yoffset = margin.top + padding.top;
			case UIPlacement.BottomRight:
				xoffset = width - margin.right - padding.right;
				yoffset = height - margin.bottom - padding.bottom;
			case UIPlacement.Center:
				xoffset = (width - totalLength) / 2 + padding.left;
				yoffset = height / 2;
			case UIPlacement.CenterXTop:
				xoffset = (width - totalLength) / 2 + padding.left;
			case UIPlacement.CenterXBottom:
				xoffset = (width - totalLength) / 2 + padding.left;
				yoffset = height - margin.bottom - padding.bottom;
			case UIPlacement.CenterY:
				xoffset = width / 2;
				yoffset = (height - totalLength) / 2 + padding.top;
			case UIPlacement.CenterYLeft:
				yoffset = (height - totalLength) / 2 + padding.top;
			case UIPlacement.CenterYRight:
				xoffset = width - margin.right - padding.right;
				yoffset = (height - totalLength) / 2 + padding.top;
			case UIPlacement.Justified:
				xoffset = margin.left;
				yoffset = height / 2;
				joffset = (width - totalLength - margin.left - margin.right) / (members.length - 1);
			case UIPlacement.JustifiedXTop:
				xoffset = margin.left;
				joffset = (width - totalLength - margin.left - margin.right) / (members.length - 1);
			case UIPlacement.JustifiedXBottom:
				xoffset = margin.left;
				yoffset = height - margin.bottom - padding.bottom;
				joffset = (width - totalLength - margin.left - margin.right) / (members.length - 1);
			case UIPlacement.JustifiedY:
				xoffset = width / 2;
				yoffset = margin.top;
				joffset = (height - totalLength - margin.top - margin.bottom) / (members.length - 1);
			case UIPlacement.JustifiedYLeft:
				yoffset = margin.top;
				joffset = (height - totalLength - margin.top - margin.bottom) / (members.length - 1);
			case UIPlacement.JustifiedYRight:
				xoffset = width - margin.right - padding.right;
				yoffset = margin.top;
				joffset = (height - totalLength - margin.top - margin.bottom) / (members.length - 1);
			default:
		}

		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], FlxObject))
			{
				var flxObj:FlxObject = cast members[i];

				flxObj.x = xoffset;
				flxObj.y = yoffset;
				switch (childPlacement)
				{
					case UIPlacement.Left:
						flxObj.y = yoffset - flxObj.height / 2;
						xoffset += flxObj.width + padding.right + padding.left;
					case UIPlacement.Right:
						flxObj.x = xoffset - flxObj.width;
						flxObj.y = yoffset - flxObj.height / 2;
						xoffset -= flxObj.width + padding.left + padding.right;
					case UIPlacement.Top:
						flxObj.x = xoffset - flxObj.width / 2;
						yoffset += flxObj.height + padding.bottom + padding.top;
					case UIPlacement.Bottom:
						flxObj.x = xoffset - flxObj.width / 2;
						flxObj.y = yoffset - flxObj.height;
						yoffset -= flxObj.height + padding.top + padding.bottom;
					case UIPlacement.TopLeft:
						xoffset += flxObj.width + padding.right + padding.left;
					case UIPlacement.BottomLeft:
						flxObj.y = yoffset - flxObj.height;
						xoffset += flxObj.width + padding.right + padding.left;
					case UIPlacement.TopRight:
						flxObj.x = xoffset - flxObj.width;
						xoffset -= flxObj.width + padding.left + padding.right;
					case UIPlacement.BottomRight:
						flxObj.x = xoffset - flxObj.width;
						flxObj.y = yoffset - flxObj.height;
						xoffset -= flxObj.width + padding.left + padding.right;
					case UIPlacement.Percent(e_x, e_y):
						flxObj.x = width * e_x / 100 - flxObj.width / 2;
						flxObj.y = height * e_y / 100 - flxObj.height / 2;
					case UIPlacement.Pos(e_x, e_y):
						flxObj.x = e_x;
						flxObj.y = e_y;
					case UIPlacement.Center:
						flxObj.y = yoffset - flxObj.height / 2;
						xoffset += flxObj.width + padding.right + padding.left;
					case UIPlacement.CenterXTop:
						flxObj.y = yoffset;
						xoffset += flxObj.width + padding.right + padding.left;
					case UIPlacement.CenterXBottom:
						flxObj.y = yoffset - flxObj.height;
						xoffset += flxObj.width + padding.right + padding.left;
					case UIPlacement.CenterY:
						flxObj.x = xoffset - flxObj.width / 2;
						yoffset += flxObj.height + padding.top + padding.bottom;
					case UIPlacement.CenterYLeft:
						flxObj.x = xoffset;
						yoffset += flxObj.height + padding.top + padding.bottom;
					case UIPlacement.CenterYRight:
						flxObj.x = xoffset - flxObj.width;
						yoffset += flxObj.height + padding.top + padding.bottom;
					case UIPlacement.Justified:
						flxObj.y = yoffset - flxObj.height / 2;
						xoffset += flxObj.width + joffset;
					case UIPlacement.JustifiedXTop:
						flxObj.y = yoffset;
						xoffset += flxObj.width + joffset;
					case UIPlacement.JustifiedXBottom:
						flxObj.y = yoffset - flxObj.height;
						xoffset += flxObj.width + joffset;
					case UIPlacement.JustifiedY:
						flxObj.x = xoffset - flxObj.width / 2;
						yoffset += flxObj.height + joffset;
					case UIPlacement.JustifiedYLeft:
						flxObj.x = xoffset;
						yoffset += flxObj.height + joffset;
					case UIPlacement.JustifiedYRight:
						flxObj.x = xoffset - flxObj.width;
						yoffset += flxObj.height + joffset;
					default:
						xoffset += flxObj.width + padding.right + padding.left;
				}
			}
			else if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain:UIContainer = cast members[i];
				if (uiContain.placement == childPlacement || uiContain.placement == UIPlacement.Inherit)
				{
					uiContain.x = xoffset;
					uiContain.y = yoffset;
					switch (childPlacement)
					{
						case UIPlacement.Left:
							uiContain.y = yoffset - uiContain.height / 2;
							xoffset += uiContain.width + padding.right + padding.left;
						case UIPlacement.Right:
							uiContain.x = xoffset - uiContain.width;
							uiContain.y = yoffset - uiContain.height / 2;
							xoffset -= uiContain.width + padding.left + padding.right;
						case UIPlacement.Top:
							uiContain.x = xoffset - uiContain.width / 2;
							yoffset += uiContain.height + padding.bottom + padding.top;
						case UIPlacement.Bottom:
							uiContain.x = xoffset - uiContain.width / 2;
							uiContain.y = yoffset - uiContain.height;
							yoffset -= uiContain.height + padding.top + padding.bottom;
						case UIPlacement.TopLeft:
							xoffset += uiContain.width + padding.right + padding.left;
						case UIPlacement.BottomLeft:
							uiContain.y = yoffset - uiContain.height;
							xoffset += uiContain.width + padding.right + padding.left;
						case UIPlacement.TopRight:
							uiContain.x = xoffset - uiContain.width;
							xoffset -= uiContain.width + padding.left + padding.right;
						case UIPlacement.BottomRight:
							uiContain.x = xoffset - uiContain.width;
							uiContain.y = yoffset - uiContain.height;
							xoffset -= uiContain.width + padding.left + padding.right;
						case UIPlacement.Center:
							uiContain.y = yoffset - uiContain.height / 2;
							xoffset += uiContain.width + padding.right + padding.left;
						case UIPlacement.CenterXTop:
							uiContain.y = yoffset;
							xoffset += uiContain.width + padding.right + padding.left;
						case UIPlacement.CenterXBottom:
							uiContain.y = yoffset - uiContain.height;
							xoffset += uiContain.width + padding.right + padding.left;
						case UIPlacement.CenterY:
							uiContain.x = xoffset - uiContain.width / 2;
							yoffset += uiContain.height + padding.top + padding.bottom;
						case UIPlacement.CenterYLeft:
							uiContain.x = xoffset;
							yoffset += uiContain.height + padding.top + padding.bottom;
						case UIPlacement.CenterYRight:
							uiContain.x = xoffset - uiContain.width;
							yoffset += uiContain.height + padding.top + padding.bottom;
						case UIPlacement.Justified:
							uiContain.y = yoffset - uiContain.height / 2;
							xoffset += uiContain.width + joffset;
						case UIPlacement.JustifiedXTop:
							uiContain.y = yoffset;
							xoffset += uiContain.width + joffset;
						case UIPlacement.JustifiedXBottom:
							uiContain.y = yoffset - uiContain.height;
							xoffset += uiContain.width + joffset;
						case UIPlacement.JustifiedY:
							uiContain.x = xoffset - uiContain.width / 2;
							yoffset += uiContain.height + joffset;
						case UIPlacement.JustifiedYLeft:
							uiContain.x = xoffset;
							yoffset += uiContain.height + joffset;
						case UIPlacement.JustifiedYRight:
							uiContain.x = xoffset - uiContain.width;
							yoffset += uiContain.height + joffset;
						default:
					}
				}
				uiContain.refreshChildren();
			}
		}

		x = tempx;
		y = tempy;
	}

	public function close()
	{
		visible = false;
		justOpened = false;
		opened = visible;
	}

	public function open()
	{
		if (!visible)
		{
			justOpened = true;
			justOpenedDelay = 2;
		}

		visible = true;
		opened = visible;
	}

	public function closedCheck():Bool
	{
		if (!visible || justOpened)
		{
			justOpenedDelay--;
			justOpened = (justOpenedDelay > 0);
			return true;
		}
		return false;
	}

	/**
	 * Adds a new `FlxBasic` subclass (`FlxBasic`, `FlxSprite`, `Enemy`, etc) to the group.
	 * `FlxGroup` will try to replace a `null` member of the array first.
	 * Failing that, `FlxGroup` will add it to the end of the member array.
	 * WARNING: If the group has a `maxSize` that has already been met,
	 * the object will NOT be added to the group!
	 * 
	 * UIContainer will automatically refresh children if an object is added to it.
	 *
	 * @param   p_obj    The object you want to add to the group.
	 * @return  The same `FlxBasic` object that was passed in.
	 */
	override public function add(p_obj:FlxBasic):FlxBasic
	{
		var tempx = x;
		var tempy = y;
		x = 0;
		y = 0;

		if (Std.isOfType(p_obj, FlxObject))
		{
			var flxObj:FlxObject = cast p_obj;
			flxObj.scrollFactor.set(scrollFactor.x, scrollFactor.y);
		}
		else if (Std.isOfType(p_obj, UIContainer))
		{
			var uiContain:UIContainer = cast p_obj;
			uiContain.scrollFactor.set(scrollFactor.x, scrollFactor.y);
			uiContain.parent = UIParent.Container(this);
			uiContain.refresh(true);
		}

		super.add(p_obj);
		refreshChildren();

		x = tempx;
		y = tempy;
		return p_obj;
	}

	private function pointXCallback(p_point:FlxPoint)
	{
		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], FlxObject))
			{
				var flxObj:FlxObject = cast members[i];
				flxObj.scrollFactor.x = p_point.x;
			}
			else if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain:UIContainer = cast members[i];
				uiContain.scrollFactor.x = p_point.x;
			}
		}
	}

	private function pointYCallback(p_point:FlxPoint)
	{
		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], FlxObject))
			{
				var flxObj:FlxObject = cast members[i];
				flxObj.scrollFactor.y = p_point.y;
			}
			else if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain:UIContainer = cast members[i];
				uiContain.scrollFactor.y = p_point.y;
			}
		}
	}

	private function pointXYCallback(p_point:FlxPoint)
	{
		for (i in 0...members.length)
		{
			if (Std.isOfType(members[i], FlxObject))
			{
				var flxObj:FlxObject = cast members[i];
				flxObj.scrollFactor.set(p_point.x, p_point.y);
			}
			else if (Std.isOfType(members[i], UIContainer))
			{
				var uiContain:UIContainer = cast members[i];
				uiContain.scrollFactor.set(p_point.x, p_point.y);
			}
		}
	}

	override public function destroy()
	{
		scrollFactor.destroy();
		super.destroy();
	}
}

class UILayout
{
	static public var zeroBox:Box = {
		left: 0,
		right: 0,
		top: 0,
		bottom: 0,
	};

	static public function left(p_left:Float):Box
	{
		return {
			left: p_left,
			right: 0,
			top: 0,
			bottom: 0
		};
	}

	static public function right(p_right:Float):Box
	{
		return {
			left: 0,
			right: p_right,
			top: 0,
			bottom: 0
		};
	}

	static public function top(p_top:Float):Box
	{
		return {
			left: 0,
			right: 0,
			top: p_top,
			bottom: 0
		};
	}

	static public function bottom(p_bottom:Float):Box
	{
		return {
			left: 0,
			right: 0,
			top: 0,
			bottom: p_bottom
		};
	}

	static public function sides(p_sides:Float):Box
	{
		return {
			left: p_sides,
			right: p_sides,
			top: p_sides,
			bottom: p_sides
		};
	}

	static public function hori(p_hori:Float):Box
	{
		return {
			left: p_hori,
			right: p_hori,
			top: 0,
			bottom: 0
		};
	}

	static public function vert(p_vert:Float):Box
	{
		return {
			left: 0,
			right: 0,
			top: p_vert,
			bottom: p_vert
		};
	}

	static public function horivert(p_hori:Float, p_vert:Float):Box
	{
		return {
			left: p_hori,
			right: p_hori,
			top: p_vert,
			bottom: p_vert
		};
	}

	static public function topbottom(p_top:Float, p_bottom:Float):Box
	{
		return {
			left: 0,
			right: 0,
			top: p_top,
			bottom: p_bottom
		};
	}

	static public function leftright(p_left:Float, p_right:Float):Box
	{
		return {
			left: p_left,
			right: p_right,
			top: 0,
			bottom: 0
		};
	}

	static public function topleft(p_top:Float, p_left:Float):Box
	{
		return {
			left: p_left,
			right: 0,
			top: p_top,
			bottom: 0
		};
	}

	static public function box(p_left:Float, p_right:Float, p_top:Float, p_bottom:Float):Box
	{
		return {
			left: p_left,
			right: p_right,
			top: p_top,
			bottom: p_bottom
		};
	}
}
