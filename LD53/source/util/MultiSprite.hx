package util;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import haxe.ds.GenericStack;

/**
 * A special sprite class used to draw multiple of the same sprite with slightly different properties such as scale or rotation.
 * @author aeveis
 */
class MultiSprite extends FlxSprite
{

	private var sprites:Array<SpriteProperty>;
	private var deadList:GenericStack<Int>;
	private var count:Int = 0;
	private var overflowIndex:Int = 0;
	private var deadCount:Int = 0;
	
	public var maxSize:Int;
	public var anyDead(get, null):Bool;
	
	public function new(size:Int = 0) 
	{
		sprites = new Array<SpriteProperty>();
		super(0, 0);
		deadList = new GenericStack<Int>();
		solid = false;
		
		maxSize = size;
	}
	
	/**
	 * Preloads with max size sprite properites if maxSize > 0
	 */
	public function preload()
	{
		clear();
		for (i in 0...maxSize)
		{
			var sp:SpriteProperty = add(0, 0);
			sp.kill();
		}
	}
	
	public function add(X:Float, Y:Float, Scale:Float = 1, Alpha:Float = 1):SpriteProperty
	{
		var sp:SpriteProperty;
		if (anyDead)
		{
			var i:Int = deadList.pop();
			sprites[i].reset(X, Y, Scale);
			sprites[i].alpha = Alpha;
			sp = sprites[i];
		}
		else if (maxSize != 0 && count >= maxSize)
		{
			sprites[overflowIndex].reset(X, Y, Scale);
			sprites[overflowIndex].alpha = Alpha;
			sp = sprites[overflowIndex];
			overflowIndex++;
			overflowIndex = overflowIndex % maxSize;
		}
		else
		{
			sp = new SpriteProperty(X, Y);
			sp.scaleX = sp.scaleY = Scale;
			sp.alpha = Alpha;
			sprites.push(sp);
			count++;
		}
		sp.offset = offset.x;
		return sp;
	}
	
	public function get_anyDead():Bool
	{
		return deadList.first() != null;
	}
	
	public function killAll()
	{
		for (sp in sprites)
		{
			sp.kill();
		}
	}
	
	/**
	 * Clear all sprite properties. May want to be avoid if you can recycle instead with killAll()
	 */
	public function clear()
	{
		while (sprites.length > 0)
		{
			sprites.pop();
		}
		count = 0;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		for(i in 0...deadCount)
		{
			deadList.pop();
		}
		deadCount = 0;
		
		for (i in 0...sprites.length)
		{
			if (sprites[i].active)
			{
				spriteUpdate(sprites[i], elapsed);
			}
			else
			{
				deadList.add(i);
				deadCount++;
			}
		}
	}
	
	public function spriteUpdate(sprite:SpriteProperty, elapsed:Float)
	{
		if (moves) //update sprite motion
		{
			var dt:Float = FlxG.elapsed;
			var velocityDelta = 0.5 * (FlxVelocity.computeVelocity(sprite.angularVelocity, angularAcceleration, angularDrag, maxAngular, elapsed) - sprite.angularVelocity);
			sprite.angularVelocity += velocityDelta; 
			sprite.angle += sprite.angularVelocity * dt;
			sprite.angularVelocity += velocityDelta;
			
			velocityDelta = 0.5 * (FlxVelocity.computeVelocity(sprite.velocityX, sprite.accelX, drag.x, maxVelocity.x, elapsed) - sprite.velocityX);
			sprite.velocityX += velocityDelta;
			var delta = sprite.velocityX * dt;
			sprite.velocityX += velocityDelta;
			sprite.x += delta;
			
			velocityDelta = 0.5 * (FlxVelocity.computeVelocity(sprite.velocityY, sprite.accelY, drag.y, maxVelocity.y, elapsed) - sprite.velocityY);
			sprite.velocityY += velocityDelta;
			delta = sprite.velocityY * dt;
			sprite.velocityY += velocityDelta;
			sprite.y += delta;
		}
		
	}
	
	override public function draw()
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;
		
		if (dirty)	//rarely 
			calcFrame(useFramePixels);
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;
			
			for (sprite in sprites)
			{
				if (!isOnScreenMulti(sprite, camera) || !sprite.active || sprite.alpha == 0)
				{
					continue;
				}

				if(sprite.alpha != alpha)
					alpha = sprite.alpha;
				if(sprite.color != color)
					color = sprite.color;

				if(sprite.anim != null && animation.name != sprite.anim)
					animation.play(sprite.anim);

				getScreenPositionMulti(sprite, _point, camera).subtractPoint(offset);

				if (isSimpleRenderMulti(sprite, camera))
					drawSimpleMulti(sprite, camera);
				else
					drawComplexMulti(sprite, camera);
				
			}
			
			alpha = 1;
			color = FlxColor.WHITE;
			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
	public function getScreenPositionMulti(sprite:SpriteProperty, ?point:FlxPoint, ?Camera:FlxCamera):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();

		if (Camera == null)
			Camera = FlxG.camera;

		point.set(sprite.x, sprite.y);
		if (pixelPerfectPosition)
			point.floor();

		return point.subtract(Camera.scroll.x * scrollFactor.x, Camera.scroll.y * scrollFactor.y);
	}

	function drawSimpleMulti(sprite:SpriteProperty, pcamera:FlxCamera):Void
	{
		if (isPixelPerfectRender(pcamera))
			_point.floor();

		_point.copyToFlash(_flashPoint);
		pcamera.copyPixels(_frame, framePixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
	}

	function drawComplexMulti(sprite:SpriteProperty, pcamera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(sprite.scaleX, sprite.scaleY);

		if (bakedRotationAngle <= 0)
		{
			updateTrigMulti(sprite);

			if (sprite.angle != 0)
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		pcamera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	@:noCompletion
	inline function updateTrigMulti(sprite:SpriteProperty):Void
	{
		if (sprite.angleChanged)
		{
			var radians:Float = sprite.angle * FlxAngle.TO_RAD;
			_sinAngle = Math.sin(radians);
			_cosAngle = Math.cos(radians);
			sprite.angleChanged = false;
		}
	}

	/**
	 * Checks if the Sprite is being rendered in "simple mode" (via copyPixels). True for flash when no angle, bakedRotations, 
	 * scaling or blend modes are used. This enables the sprite to be rendered much faster if true.
	 */
	public function isSimpleRenderMulti(sprite:SpriteProperty, ?pcamera:FlxCamera):Bool
	{ 
		if (FlxG.renderTile)
			return false;

		var result:Bool = (sprite.angle == 0 || bakedRotationAngle > 0) && sprite.scaleX == 1 && sprite.scaleY == 1 && blend == null;
		result = result && (pcamera != null ? isPixelPerfectRender(pcamera) : pixelPerfectRender);
		return result;
	}
	
	/**
	 * Check and see if this sprite instance is currently on screen. Differs from FlxObject's implementation
	 * in that it takes the actual graphic into account, not just the hitbox or bounding box or whatever.
	 * 
	 * @param	sprite		Check Specific Sprite Property
	 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
	 * @return	Whether the object is on screen or not.
	 */
	public function isOnScreenMulti(sprite:SpriteProperty, ?Camera:FlxCamera):Bool
	{
		if (Camera == null)
			Camera = FlxG.camera;
		
		var minX:Float = sprite.x - sprite.offset - Camera.scroll.x * scrollFactor.x;
		var minY:Float = sprite.y - sprite.offset - Camera.scroll.y * scrollFactor.y;
		
		if ((sprite.angle == 0 || bakedRotationAngle > 0) && (sprite.scaleX == 1) && (sprite.scaleY == 1))
		{
			_point.set(minX, minY);
			return Camera.containsPoint(_point, frameWidth, frameHeight);
		}

		var radiusX:Float = _halfSize.x;
		var radiusY:Float = _halfSize.y;
		var ox:Float = origin.x;
		if (ox != radiusX)
		{
			var x1:Float = Math.abs(ox);
			var x2:Float = Math.abs(frameWidth - ox);
			radiusX = Math.max(x2, x1);
		}

		var oy:Float = origin.y;
		if (oy != radiusY)
		{
			var y1:Float = Math.abs(oy);
			var y2:Float = Math.abs(frameHeight - oy);
			radiusY = Math.max(y2, y1);
		}

		radiusX *= Math.abs(sprite.scaleX);
		radiusY *= Math.abs(sprite.scaleY);
		var radius:Float = Math.max(radiusX, radiusY);
		radius *= FlxMath.SQUARE_ROOT_OF_TWO;

		minX += ox - radius;
		minY += oy - radius;

		var doubleRadius:Float = 2 * radius;

		_point.set(minX, minY);	
		return Camera.containsPoint(_point, doubleRadius, doubleRadius);
	
	}
	
	/*override private function set_x(NewX:Float):Float
	{
		var offset:Float = NewX - x;
		for (sprite in sprites)
		{
			sprite.x += offset;
		}*
		return super.set_x(NewX);
	}
	
	override private function set_y(NewY:Float):Float
	{
		var offset:Float = NewY - y;
		for (sprite in sprites)
		{
			sprite.y += offset;
		}
		return super.set_y(NewY);
	}*/
}

class SpriteProperty 
{
	public var x:Float = 0;
	public var y:Float = 0;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var velocityX:Float = 0;
	public var velocityY:Float = 0;
	public var accelX:Float = 0;
	public var accelY:Float = 0;
	public var angle(default, set):Float = 0;
	public var angularVelocity:Float = 0;
	public var color:Int = FlxColor.WHITE;
	public var angleChanged:Bool = false;
	public var alpha:Float = 1;
	public var maxLifespan:Float = 0;
	public var lifespan:Float = 0;
	public var anim:String = null;
	// Assuming offsets are same in the x and y!
	public var offset:Float = 0;
	public var active:Bool = true;
	// Any additional custom properties to be added.
	public var custom:Array<Float>;

	
	public function new(X:Float, Y:Float, Scale:Float = 1)
	{
		x = X;
		y = Y;
		scaleX = Scale;
		scaleY = Scale;
	}
	
	private function set_angle(Value:Float):Float
	{
		angleChanged = (angle != Value) || angleChanged;
		return angle = Value;
	}
	
	public function kill()
	{
		active = false;
	}
	
	public function reset(X:Float, Y:Float, Scale:Float = 1)
	{
		x = X;
		y = Y;
		scaleX = Scale;
		scaleY = Scale;
		alpha = 1;
		velocityX = 0;
		velocityY = 0;
		accelX = 0;
		accelY = 0;
		angle = 0;
		angularVelocity = 0;
		color = FlxColor.WHITE;
		angleChanged = false;
		maxLifespan = 0;
		lifespan = 0;
		anim = null;
		offset = 0;
		active = true;
	}
}