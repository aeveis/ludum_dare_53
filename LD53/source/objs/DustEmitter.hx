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
class DustEmitter extends MultiEmitter
{
	public static var instance:DustEmitter;

	public var isSmoke:Bool = true;
	public var useAccelY:Bool = false;
	public var accelY:Float = 0;

	public var isCloudEmit:Bool = false;

	public function new()
	{
		super(250);

		loadGraphic(AssetPaths.dust__png, true, 8, 8);
		animation.add("0_right", [0], 10, false);
		animation.add("1_right", [1], 10, false);
		animation.add("2_right", [2], 10, false);
		animation.add("3_right", [3], 10, false);
		animation.add("4_right", [4], 10, false);
		animation.add("5_right", [5], 10, false);
		animation.add("6_right", [6], 10, false);
		animation.add("7_right", [7], 10, false);
		animation.add("8_right", [8], 10, false);
		animation.add("0_left", [9], 10, false);
		animation.add("1_left", [10], 10, false);
		animation.add("2_left", [11], 10, false);
		animation.add("3_left", [12], 10, false);
		animation.add("4_left", [13], 10, false);
		animation.add("5_left", [14], 10, false);
		animation.add("6_left", [15], 10, false);
		animation.add("7_left", [16], 10, false);
		animation.add("8_left", [17], 10, false);
		animation.play("0_right");
		width = 4;
		height = 4;

		minLifespan = 0.5;
		maxLifespan = 1;

		color = 0xff000000;

		instance = this;
	}

	public function randomSkyColor()
	{
		color = FlxColor.interpolate(0xe0f6f9, 0xa8e0f6, FlxG.random.float(0, 0.8));
	}

	public function floorPoof()
	{
		minVelX = -3.0;
		maxVelX = 3.0;
		minVelY = -5.0;
		maxVelY = -5.0;

		if (FlxG.random.bool(15))
		{
			randomSkyColor();
			emitParticle(x, y);
		}
		if (isCloudEmit)
		{
			cloudPoof();
		}
	}

	public function backPoof()
	{
		minVelX = -1.0;
		maxVelX = 1.0;
		minVelY = -1.0;
		maxVelY = -1.0;

		if (FlxG.random.bool(3))
		{
			randomSkyColor();
			emitParticle(x, y);
		}
		if (isCloudEmit)
		{
			cloudPoof();
		}
	}

	public function constantPoof()
	{
		minVelX = -10;
		maxVelX = 10;
		minVelY = -10;
		maxVelY = -10;

		if (FlxG.random.bool(5))
		{
			randomSkyColor();
			emitParticle(x, y);
		}

		if (isCloudEmit)
		{
			cloudPoof();
		}
	}

	public function constantDownPoof()
	{
		minVelY = 20.0;
		maxVelY = 50.0;
		minVelX = -2.0;
		maxVelX = 2.0;

		if (FlxG.random.bool(25))
		{
			randomSkyColor();
			emitParticle(x, y);
		}
	}

	public function rightPoof()
	{
		minVelX = 0.5;
		maxVelX = 3.0;
		minVelY = -1.0;
		maxVelY = 1.0;
		for (i in 0...2)
		{
			randomSkyColor();
			emitParticle(x, y);
		}
	}

	public function leftPoof()
	{
		minVelX = -3.0;
		maxVelX = -0.5;
		minVelY = -1.0;
		maxVelY = 1.0;

		for (i in 0...2)
		{
			randomSkyColor();
			emitParticle(x, y);
		}
	}

	public function upPoof()
	{
		minVelY = 0.5;
		maxVelY = 3.0;
		minVelX = -1.0;
		maxVelX = 1.0;

		for (i in 0...2)
		{
			randomSkyColor();
			emitParticle(x, y);
		}
	}

	public function downPoof()
	{
		minVelY = -6.0;
		maxVelY = -3.5;
		minVelX = -20.0;
		maxVelX = 20.0;

		for (i in 0...6)
		{
			randomSkyColor();
			emitParticle(x, y);
		}
	}

	public function dashPoof()
	{
		minVelX = -5;
		maxVelX = 5;
		minVelY = -5;
		maxVelY = 5;
		minLifespan = 0.4;
		maxLifespan = 0.6;

		if (FlxG.random.bool(20))
		{
			color = FlxColor.interpolate(0x80ffe6, 0xffffff, FlxG.random.float());
			emitParticle(x - 4, y - FlxG.random.float(0, 10));
		}

		if (FlxG.random.bool(45))
		{
			minLifespan = 0.2;
			maxLifespan = 0.4;
			minVelX = 0;
			maxVelX = 0;
			minVelY = 0;
			maxVelY = 0;
			width = 1;
			height = 1;
			color = 0x56ddd7;
			emitParticle(x - 4, y - 4);
		}
		width = 8;
		height = 8;
		minLifespan = 0.5;
		maxLifespan = 1;
	}

	public function dashStartPoof(velocity:FlxPoint)
	{
		minLifespan = 0.2;
		maxLifespan = 0.4;
		minVelX = -velocity.x / 4.0 - 5.0;
		maxVelX = -velocity.x / 4.0 + 5.0;
		minVelY = -velocity.y / 4.0 - 5.0;
		maxVelY = -velocity.y / 4.0 + 5.0;
		for (i in 0...6)
		{
			emitParticle(x - 4, y - 4);
		}
	}

	public function boxPoof()
	{
		minLifespan = 0.2;
		maxLifespan = 0.6;
		minVelX = -25.0;
		maxVelX = 25.0;
		minVelY = -25.0;
		maxVelY = 25.0;
		for (i in 0...10)
		{
			color = FlxColor.interpolate(0xf5e38a, 0xdb791f, FlxG.random.float());
			emitParticle(x - 4, y - 4);
		}
	}

	public function tapePoof()
	{
		minLifespan = 0.2;
		maxLifespan = 0.4;
		minVelX = -15.0;
		maxVelX = 15.0;
		minVelY = -15.0;
		maxVelY = 15.0;
		for (i in 0...4)
		{
			color = FlxColor.interpolate(0xf5e38a, 0xdb791f, FlxG.random.float());
			emitParticle(x - 4, y - 4);
		}
	}

	public function shieldEffect(radius:Float)
	{
		var pangle:Float = FlxG.random.float(0, 6.28);
		radius *= 0.8;
		minVelX = -5;
		maxVelX = 5;
		minVelY = -5;
		maxVelY = 5;
		color = 0xffa205;
		if (FlxG.random.bool(20))
		{
			emitParticle(x + radius * Math.cos(pangle), y + radius * Math.sin(pangle));
		}
	}

	public function shieldHit(radius:Float)
	{
		radius *= 0.95;
		minVelX = -15;
		maxVelX = 15;
		minVelY = -50;
		maxVelY = 15;
		color = 0x00c9ff;
		isSmoke = false;
		for (i in 0...30)
		{
			var pangle:Float = FlxG.random.float(0, 6.28);
			emitParticle(x + radius * Math.cos(pangle), y + radius * Math.sin(pangle));
		}
		isSmoke = true;
		color = FlxColor.WHITE;
	}

	public function moteEffect()
	{
		minVelX = -20;
		maxVelX = 20;
		minVelY = -30;
		maxVelY = 5;
		color = 0x2bf2ff;
		randomInSize = false;
		isSmoke = false;
		if (FlxG.random.bool(40))
		{
			emitParticle(x, y);
		}
		randomInSize = true;
		isSmoke = true;
		color = FlxColor.WHITE;
	}

	public function cryEffect()
	{
		minVelX = -10;
		maxVelX = 10;
		minVelY = 0;
		maxVelY = 10;
		color = 0x00ffd9;
		accelY = 2;
		useAccelY = true;
		randomInSize = false;
		isSmoke = false;
		if (FlxG.random.bool(10))
		{
			emitParticle(x, y);
		}
		minVelX = -20;
		maxVelX = 20;
		minVelY = -10;
		maxVelY = -20;
		if (FlxG.random.bool(2))
		{
			emitParticle(x, y);
		}
		isSmoke = true;
		randomInSize = true;
		useAccelY = false;
		color = FlxColor.WHITE;
	}

	public function poof()
	{
		minVelX = -25;
		maxVelX = 25;
		minVelY = -45;
		maxVelY = 10;
		minLifespan = 0.35;
		maxLifespan = 0.5;
		for (i in 0...10)
		{
			randomSkyColor();
			emitParticle(x, y);
		}
		minLifespan = 0.5;
		maxLifespan = 1;
	}

	public function redPoof()
	{
		width = 32;
		height = 32;
		minVelX = -30;
		maxVelX = 30;
		minVelY = -65;
		maxVelY = 10;
		color = 0xf23e1f;
		for (i in 0...20)
		{
			emitParticle(x, y);
		}
		width = 8;
		height = 8;
	}

	public function greenPoof()
	{
		width = 32;
		height = 32;
		minVelX = -30;
		maxVelX = 30;
		minVelY = -65;
		maxVelY = 10;
		color = 0x59c316;
		for (i in 0...20)
		{
			emitParticle(x, y);
		}
		width = 8;
		height = 8;
	}

	public function largePoof()
	{
		width = 32;
		height = 32;
		minVelX = -65;
		maxVelX = 65;
		minVelY = -65;
		maxVelY = 65;
		for (i in 0...20)
		{
			emitParticle(x, y);
		}
		width = 8;
		height = 8;
	}

	public function fireflyPoof()
	{
		minVelX = -55;
		maxVelX = 55;
		minVelY = -55;
		maxVelY = 55;
		isSmoke = false;
		for (i in 0...30)
		{
			if (i < 10)
				color = 0xd5ff37;
			else if (i < 20)
				color = 0x7dee45;
			else
				color = 0xb26a36;
			emitParticle(x, y);
		}
		color = FlxColor.WHITE;
		isSmoke = true;
	}

	public function smallPoof()
	{
		minVelX = -55;
		maxVelX = 55;
		minVelY = -55;
		maxVelY = 55;
		for (i in 0...10)
		{
			emitParticle(x, y);
		}
	}

	public function tinyPoof()
	{
		minVelX = -55;
		maxVelX = 55;
		minVelY = -55;
		maxVelY = 55;
		minLifespan = 0.25;
		maxLifespan = 0.35;
		for (i in 0...3)
		{
			emitParticle(x, y);
		}
		minLifespan = 0.5;
		maxLifespan = 1;
	}

	public function cloudPoof()
	{
		minVelX = -30;
		maxVelX = 30;
		minVelY = -30;
		maxVelY = 30;
		isSmoke = false;
		for (i in 0...20)
		{
			color = FlxColor.interpolate(0xb2987d, 0x594e48, FlxG.random.float());
			emitParticle(x + FlxG.random.float(-12, 12), y + FlxG.random.float(-8, 8));
		}

		color = FlxColor.WHITE;
		isSmoke = true;
	}

	override function initParticle(sp:SpriteProperty)
	{
		super.initParticle(sp);
		if (useAccelY)
		{
			sp.accelY = accelY;
		}
		sp.color = color;
	}

	override function spriteUpdate(sp:SpriteProperty, elapsed:Float)
	{
		super.spriteUpdate(sp, elapsed);

		sp.velocityX += FlxG.random.float(-1, 1);
		sp.velocityY += FlxG.random.float(-1, 1);
		var frameNum:Int = Math.floor(ratio * 9);
		if (frameNum >= 9)
		{
			frameNum = 8;
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
