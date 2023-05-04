package objs;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.path.FlxPath;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import ui.TextPopup;
import ui.TextTrigger;
import util.Input;

/**
 * ...
 * @author aeveis
 */
enum ObjType
{
	Light;
	Krill;
	Other;
}

class Object extends FlxSprite
{
	private var timer:Float = 0;

	public static inline var NONE:Int = 0;
	public static inline var BOUNCE:Int = 1;
	public static inline var RISEFADE:Int = 2;
	public static inline var HIDE:Int = 3;

	public var state:Int = 0;
	public var sineAmount:Float = 1;
	public var sineSpeed:Float = 3;

	public var startY:Float = 0;

	public var textTrigger:TextTrigger;

	public var name:String = "";
	public var unique:String = "";
	public var paths:Map<Int, Array<FlxPoint>>;
	public var pathIndex:Int = 0;
	public var moving:Bool = false;

	public function new(px:Float, py:Float, pname:String = "")
	{
		super(px, py);
		drag.set(10, 10);
		setup(px, py, pname);
	}

	public function setup(px:Float, py:Float, pname:String = "")
	{
		x = px;
		y = py;
		startY = py;
		setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
		switch (pname)
		{
			case "bluebird" | "sprout":
				name = pname;
				loadGraphic(AssetPaths.npc__png, true, 8, 8);
				animation.add("bluebird", [0], 10, false);
				animation.add("sprout", [1], 10, false);
				animation.play(name);
			default:
				if (pname != "")
				{
					name = pname;
					loadGraphic(AssetPaths.getFile(pname));
				}
		}
		// solid = true;

		timer = FlxG.random.float(0, 5);
	}

	public function setUnique(pUniqueName:String)
	{
		unique = pUniqueName;
		paths = new Map<Int, Array<FlxPoint>>();
		animation.play(pUniqueName);
	}

	public override function update(elapsed:Float)
	{
		var textboxOn:Bool = PlayState.instance.textbox.visible;
		if (!textboxOn)
		{
			super.update(elapsed);
		}

		switch (state)
		{
			case BOUNCE:
				timer += elapsed * sineSpeed;
				if (moving)
				{
					y += (textboxOn ? 0.1 : 0.5) * sineAmount * Math.sin(timer);
				}
				else
				{
					y = startY + sineAmount * Math.sin(timer);
				}
			case RISEFADE:
				y -= elapsed * 5;
				alpha -= elapsed / 2;
				if (alpha <= 0)
				{
					visible = false;
					alpha = 1;
					y = startY;
					state = HIDE;
				}
			default:
		}

		if (textTrigger == null)
			return;

		/*if (Input.control.keys.get("select").justPressed)
			{
				if (PlayState.instance.bird.x < x)
				{
					facing = FlxDirectionFlags.LEFT;
				}
				else if (PlayState.instance.bird.x > x)
				{
					facing = FlxDirectionFlags.RIGHT;
				}
		}*/

		if (!moving)
			return;

		if (velocity.x > 2)
		{
			facing = FlxDirectionFlags.RIGHT;
		}
		else if (velocity.x < -2)
		{
			facing = FlxDirectionFlags.LEFT;
		}
		if (textboxOn)
			return;
		textTrigger.setPosFromNPC(x, y);
	}

	public function nextPath()
	{
		if (paths == null)
			return;

		var points = paths.get(pathIndex);
		if (points == null)
		{
			trace("path missing index " + pathIndex);
			return;
		}

		if (moving)
		{
			for (pt in points)
			{
				path.addPoint(pt);
			}
			return;
		}

		if (path == null)
		{
			path = new FlxPath();
			path.autoCenter = false;
			path.onComplete = onCompletePath;
		}

		moving = true;
		path.start(points, 75, FlxPathType.FORWARD);
	}

	public function onCompletePath(ppath:FlxPath)
	{
		attemptStopMoving();
	}

	public function attemptStopMoving(?timer:FlxTimer)
	{
		startY = y;
		moving = false;
		pathIndex++;
		textTrigger.checkNotify();
	}

	override function destroy()
	{
		if (path != null)
		{
			path.destroy();
		}
		if (paths != null)
		{
			for (array in paths)
			{
				for (pt in array)
				{
					pt.put();
				}
			}
			paths.clear();
			paths = null;
		}
		super.destroy();
	}
}
