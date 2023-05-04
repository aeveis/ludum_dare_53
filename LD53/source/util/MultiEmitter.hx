package util;

import flixel.FlxG;
import util.MultiSprite;

/**
 * ...
 * @author aeveis
 */
class MultiEmitter extends MultiSprite
{
	var minLifespan:Float = 0;
	var maxLifespan:Float = 1;
	var minVelX:Float = 0;
	var minVelY:Float = 0;
	var maxVelX:Float = 0;
	var maxVelY:Float = 0;
	var ratio:Float = 0;
	var randomInSize:Bool = true;
	var persistent:Bool = false;

	public function new(poolSize:Int)
	{
		super(poolSize);
		preload();
	}

	public function emitParticle(px:Float, py:Float)
	{
		var sp:SpriteProperty = add(px - (Std.int(width) >> 1), py - (Std.int(height) >> 1));
		if (randomInSize)
		{
			sp.x += FlxG.random.float(0, width);
			sp.y += FlxG.random.float(0, height);
		}
		sp.velocityX = FlxG.random.float(minVelX, maxVelX);
		sp.velocityY = FlxG.random.float(minVelY, maxVelY);
		sp.maxLifespan = FlxG.random.float(minLifespan, maxLifespan);
		sp.lifespan = sp.maxLifespan;
		initParticle(sp);
	}

	public function initParticle(sp:SpriteProperty)
	{
		// to be overriden
	}

	override function spriteUpdate(sp:SpriteProperty, elapsed:Float)
	{
		super.spriteUpdate(sp, elapsed);
		if (persistent)
		{
			return;
		}
		if (sp.lifespan > 0)
		{
			sp.lifespan -= elapsed;
			ratio = 1 - sp.lifespan / sp.maxLifespan;
			if (sp.lifespan <= 0)
			{
				sp.kill();
				return;
			}
		}
	}
}
