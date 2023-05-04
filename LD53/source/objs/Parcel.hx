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

class Parcel extends FlxSprite
{
	public var held(default, set):Bool = false;
	public var heldPoint:FlxPoint;
	public var yoffset:Float = 0;
	public var fakeGravity:Float = 10;
	public var fakeYVel:Float = 0;
	public var lastEdgeTouching:FlxDirectionFlags = FlxDirectionFlags.NONE;
	public var spring:Float = 0;

	public var totalFrames:Int = 8;
	// regular obj settings
	public var gravity:Float = 60;
	public var onBird:Bool = false;

	function set_held(value:Bool):Bool
	{
		if (!value && held)
		{
			DustEmitter.instance.x = x + width / 2;
			DustEmitter.instance.y = y + height / 2;
			DustEmitter.instance.boxPoof();
			acceleration.y = gravity;
			drag.set(100, 100);
			width = height = 8;
			offset.set(0, 0);
		}
		else if (value && !held)
		{
			acceleration.y = 0;
			drag.set(0, 0);
			width = height = 4;
			offset.set(2, 2);
		}
		held = value;
		return held;
	}

	public function new(px:Float, py:Float)
	{
		super(px, py);
		loadGraphic(AssetPaths.box__png, true, 8, 8);
		setHealth(1.0);
		width = height = 4;
		offset.set(2, 2);

		held = true;
		heldPoint = FlxPoint.get();
	}

	public function setHealth(ratio:Float)
	{
		animation.frameIndex = Math.floor((1.0 - ratio) * totalFrames);
	}

	public function setHeldPos()
	{
		if (spring < 1.0)
		{
			x = heldPoint.x;
			y = heldPoint.y + yoffset;
		}
		else
		{
			x = (heldPoint.x + x * spring) / (spring + 1.0);
			y = (heldPoint.y + yoffset + y * spring) / (spring + 1.0);
		}
	}

	override function update(elapsed:Float)
	{
		if (!Bird.control)
			return;
		if (spring > 0)
		{
			spring -= elapsed * 3.0;
		}
		super.update(elapsed);
		if (!onBird)
		{
			PlayState.instance.interactPopup.setState(PopupState.Hide);
		}
		onBird = false;
	}

	public function fallBackDown(elapsed:Float)
	{
		if (yoffset < 0)
		{
			fakeYVel += fakeGravity * elapsed;
			yoffset += fakeYVel;
			if (yoffset > 0)
			{
				yoffset = 0;
				fakeYVel = 0;
			}
		}
	}

	public function fallFromFlip(elapsed:Float)
	{
		fakeYVel += fakeGravity * elapsed;
		yoffset += fakeYVel;
	}

	override function destroy()
	{
		heldPoint.put();
		super.destroy();
	}
}
