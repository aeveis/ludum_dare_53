package objs;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import util.FSM;
import util.MultiEmitter;
import util.MultiSprite.SpriteProperty;

/**
 * ...
 * @author aeveis
 */
class TrailEmitter extends MultiEmitter
{
	public static var instance:TrailEmitter;

	public function new()
	{
		super(250);
		loadGraphic(AssetPaths.traildust__png, true, 2, 2);
		animation.add("0_right", [0], 10, false);
		animation.add("1_right", [1], 10, false);
		animation.add("2_right", [2], 10, false);
		animation.add("3_right", [3], 10, false);
		animation.add("0_left", [4], 10, false);
		animation.add("1_left", [5], 10, false);
		animation.add("2_left", [6], 10, false);
		animation.add("3_left", [7], 10, false);
		animation.play("0_right");
		width = 4;
		height = 4;

		minLifespan = 0.2;
		maxLifespan = 0.5;

		instance = this;
	}

	public function poof()
	{
		minVelX = -45;
		maxVelX = 45;
		minVelY = -45;
		maxVelY = 10;
		minLifespan = 0.2;
		maxLifespan = 0.4;
		for (i in 0...10)
		{
			color = FlxColor.interpolate(0x80ffe6, 0x25b6f5, FlxG.random.float());
			emitParticle(x, y - 2);
		}
	}

	public function constantPoof()
	{
		minVelX = -0.5;
		maxVelX = 0.5;
		minVelY = -0.5;
		maxVelY = 0.5;
		minLifespan = 0.2;
		maxLifespan = 0.5;

		if (FlxG.random.bool(65))
		{
			color = FlxColor.interpolate(0x80ffe6, 0x25b6f5, FlxG.random.float());
			emitParticle(x, y);
		}
	}

	override function initParticle(sp:SpriteProperty)
	{
		super.initParticle(sp);
		sp.color = color;
	}

	override function spriteUpdate(sp:SpriteProperty, elapsed:Float)
	{
		super.spriteUpdate(sp, elapsed);

		sp.velocityX += FlxG.random.float(-1, 1);
		sp.velocityY += FlxG.random.float(-1, 1);
		var frameNum:Int = Math.floor(ratio * 4);
		if (frameNum >= 4)
		{
			frameNum = 3;
		}
		if (sp.velocityX > 0)
		{
			sp.anim = frameNum + "_right";
		}
		else
		{
			sp.anim = frameNum + "_left";
		}
	}
}
