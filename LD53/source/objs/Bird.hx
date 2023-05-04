package objs;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxDirectionFlags;
import global.G;
import util.FSM;
import util.Input;
import util.TimedBool;

enum MoveState
{
	Idle;
	Walk;
	Fall;
	Jump;
	Flap;
	WeakFlap;
	Glide;
	Land;
	AirDash;
	Crouch;
	Stun;
	Flip;
}

class Bird extends FlxSprite
{
	public static var instance:Bird;

	public var moveSpeed:Float = 320;
	public var groundBoost:Float = 30;
	public var airMoveSpeed:Float = 250;
	public var airBoost:Float = 30;
	public var jumpStrength:Float = 80;
	public var jumpVariable:Float = 5;
	public var flapCount:Float = 0;
	public var weakflapStrength:Float = 50;
	public var flapStrength:Float = 150;
	public var currentFlapStrength:Float = 150;
	public var flapVariable:Float = 20;
	public var gravity:Float = 300;
	public var glideGravity:Float = 50;
	public var idleDrag:Float = 600;
	public var airDrag:Float = 150;
	public var moveDrag:Float = 250;
	public var airDashStrength:Float = 300;
	public var airDashDiagonalStrength:Float;
	public var maxDashVelocity = 400;
	public var maxMoveVelocity = 120;

	public var elapsed:Float = 0;
	public var fsm:FSM;

	static public var control:Bool = true;

	public var onGround:TimedBool;
	public var jumping:TimedBool;
	public var jumpCooldown:TimedBool;
	public var dashing:TimedBool;
	public var dashCooldown:TimedBool;
	public var delayedDash:Bool = false;
	public var stunned:TimedBool;

	public var dashLimited:Bool = true;
	public var dashUntethered:Bool = true;
	public var dashCount:Int = 0;
	public var normalDashTime:Float = 0.15;
	public var untetheredDashTime:Float = 0.2;

	public var flipDir:FlxDirectionFlags = FlxDirectionFlags.NONE;
	public var flipSpeed:Float = 80;
	public var flipPeriod:Float = 9.0;
	public var flipCounter:Float = 0;
	public var flipCache:Array<FlxDirectionFlags>;
	public var flipCacheCheck:TimedBool;
	public var flipCacheSize:Int = 3;
	public var preservedVelocity:FlxPoint;

	public var followPoint:FlxPoint;
	public var followOffset:Float = 3;

	public var chirping:TimedBool;

	private var groundYOffset = 4;
	private var airYOffset = 2;

	public var parcel:Parcel;
	public var straps:FlxSprite;

	public function new(px:Float, py:Float)
	{
		super(px, py + 4);

		loadGraphic(AssetPaths.bird__png, true, 8, 8);

		width = height = 4;
		centerOffsets();

		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
		setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		facing = FlxDirectionFlags.LEFT;
		flipCache = new Array<FlxDirectionFlags>();
		for (i in 0...flipCacheSize)
		{
			flipCache.push(FlxDirectionFlags.NONE);
		}
		preservedVelocity = FlxPoint.get();

		maxVelocity.x = maxVelocity.y = maxMoveVelocity;
		drag.x = drag.y = idleDrag;
		acceleration.y = gravity;
		elasticity = 0;

		onGround = new TimedBool(0.15);
		jumping = new TimedBool(0.2);
		jumpCooldown = new TimedBool(0.3);
		dashing = new TimedBool(normalDashTime);
		dashCooldown = new TimedBool(0.2);
		stunned = new TimedBool(0.25);
		chirping = new TimedBool(0.15);
		flipCacheCheck = new TimedBool(0.2);
		airDashDiagonalStrength = Math.sqrt(airDashStrength * airDashStrength / 2.0);

		animation.add("idle", [0], 5, false);
		animation.add("crouch", [3], 12, false);
		animation.add("land", [2], 12, false);
		animation.add("walk", [1, 2, 0], 10, true);
		animation.add("jump", [2, 1, 4, 8, 8, 8], 20, false);
		animation.add("flap", [4, 4, 5, 6, 7, 8, 8, 8, 8], 40, false);
		animation.add("weakflap", [4, 4, 5, 6, 7, 7], 25, false);
		animation.add("fall", [4, 5], 6, false);
		animation.add("glide", [7, 9, 7, 10], 6, true);
		animation.add("flip", [11, 12, 13, 14, 8], 5, true);
		// animation.add("airDash", [10, 13, 13, 13, 12, 11], 50, false);
		// animation.add("airDashDiaUp", [10, 16, 16, 16, 15, 14, 3], 50, false);
		// animation.add("airDashDiaDown", [10, 19, 19, 19, 18, 17, 3], 50, false);
		animation.add("stun", [13], 8, false);
		fsm = new FSM();

		fsm.addState(MoveState.Idle, idleEnter, idleUpdate);
		fsm.addState(MoveState.Walk, walkEnter, walkUpdate, walkLeave);
		fsm.addState(MoveState.Fall, fallEnter, fallUpdate);
		fsm.addState(MoveState.Jump, jumpEnter, jumpUpdate);
		fsm.addState(MoveState.Flap, flapEnter, flapUpdate);
		fsm.addState(MoveState.WeakFlap, weakflapEnter, flapUpdate);
		fsm.addState(MoveState.Glide, glideEnter, glideUpdate, glideLeave);
		fsm.addState(MoveState.Land, landEnter, landUpdate);
		fsm.addState(MoveState.AirDash, airDashEnter, airDashUpdate, airDashLeave);
		fsm.addState(MoveState.Crouch, crouchEnter, crouchUpdate);
		fsm.addState(MoveState.Stun, stunEnter, stunUpdate);
		fsm.addState(MoveState.Flip, flipEnter, flipUpdate, flipLeave);
		fsm.switchState(MoveState.Idle);

		straps = new FlxSprite(x, y, AssetPaths.straps__png);
		parcel = new Parcel(x, y);
		parcel.held = false;
		// followPoint = FlxPoint.get();
		// followPoint.set(x, y);
		control = true;
		instance = this;
	}

	override public function update(elapsed:Float):Void
	{
		if (!control)
		{
			return;
		}
		this.elapsed = elapsed;
		checkFlip();

		dashCooldown.update(elapsed);
		dashing.update(elapsed);
		if (!dashCooldown.soft)
		{
			onGround.hard = isTouching(FlxDirectionFlags.FLOOR);
			onGround.update(elapsed);
		}
		jumping.update(elapsed);
		jumpCooldown.update(elapsed);
		stunned.update(elapsed);
		chirping.update(elapsed);
		fsm.update();
		super.update(elapsed);
		updateParcel();

		/*switch (facing)
			{
				case FlxDirectionFlags.LEFT:
					followPoint.x -= elapsed * moveSpeed;
					if (followPoint.x < x - FlxG.height / followOffset)
					{
						followPoint.x = x - FlxG.height / followOffset;
					}
					followPoint.y = y;
				case FlxDirectionFlags.RIGHT:
					followPoint.x += elapsed * moveSpeed;
					if (followPoint.x > x + FlxG.height / followOffset)
					{
						followPoint.x = x + FlxG.height / followOffset;
					}
					followPoint.y = y;
				default:
		}*/

		if (Input.control.keys.get("action").justPressed)
		{
			G.playSound("birdtype", 2);
			/*if (animation.frameIndex < 25)
				{
					animation.frameIndex += 25;
			}*/
			TrailEmitter.instance.x = x + 1;
			TrailEmitter.instance.y = y;
			TrailEmitter.instance.poof();

			chirping.trigger();
		}
		/*else if (chirping.soft && animation.frameIndex < 25)
			{
				animation.frameIndex += 25;
			}
			else if (animation.frameIndex >= 25 && !chirping.soft)
			{
				animation.frameIndex -= 25;
		}*/

		// Dash Ground Cancel
		if (dashing.soft && velocity.y > 50)
		{
			onGround.hard = overlaps(PlayState.instance.tilemap);
			if (onGround.hard)
			{
				dashing.reset();
				dashCooldown.reset();
				velocity.y = 0;
				y -= 4;
				fsm.switchState(MoveState.Land);
			}
		}
	}

	override function draw()
	{
		straps.draw();
		parcel.draw();
		super.draw();
	}

	private function updateParcel()
	{
		straps.scale.set(0, 0);
		if (!parcel.held)
			return;

		straps.setPosition(x - 2.0, y - 4.0);
		straps.scale.set(1, FlxMath.distanceBetween(this, parcel) / 4.0);
		straps.angle = Math.atan2(y - parcel.y, x - parcel.x) * 180.0 / Math.PI - 90.0;

		var flip:Bool = fsm.current == MoveState.Flip;
		if (flip)
		{
			return;
		}

		var fall:Bool = fsm.current == MoveState.Fall;

		parcel.heldPoint.set(x, y - 9.0);
		switch (animation.frameIndex)
		{
			case 0:
			case 1:
				parcel.heldPoint.y--;
			case 2 | 8 | 11:
				parcel.heldPoint.y++;
			default:
				parcel.heldPoint.y += 2;
		}

		if (fall)
		{
			parcel.yoffset -= elapsed * 5;
		}
		else
		{
			parcel.fallBackDown(elapsed);
		}
		parcel.setHeldPos();
	}

	private function clearFlipCache()
	{
		flipCacheCheck.reset();
		for (i in 0...flipCacheSize)
		{
			flipCache[i] = FlxDirectionFlags.NONE;
		}
	}

	private function checkFlip()
	{
		flipCacheCheck.update(elapsed);
		if (Input.control.none)
		{
			return;
		}
		if (Input.control.left.justPressed)
		{
			for (i in 1...flipCacheSize)
			{
				flipCache[flipCacheSize - i] = flipCache[flipCacheSize - i - 1];
			}
			flipCache[0] = FlxDirectionFlags.LEFT;
			flipCacheCheck.hard = true;
		}
		if (Input.control.right.justPressed)
		{
			for (i in 1...flipCacheSize)
			{
				flipCache[flipCacheSize - i] = flipCache[flipCacheSize - i - 1];
			}
			flipCache[0] = FlxDirectionFlags.RIGHT;
			flipCacheCheck.hard = true;
		}
		if (Input.control.up.justPressed)
		{
			for (i in 1...flipCacheSize)
			{
				flipCache[flipCacheSize - i] = flipCache[flipCacheSize - i - 1];
			}
			flipCache[0] = FlxDirectionFlags.UP;
			flipCacheCheck.hard = true;
		}
		if (!flipCacheCheck.soft || Input.control.down.justPressed)
		{
			clearFlipCache();
		}
	}

	private function idleEnter()
	{
		drag.x = drag.y = idleDrag;
		offset.y = groundYOffset;

		followOffset = 3;
		animation.play("idle");
	}

	private function landEnter()
	{
		drag.x = drag.y = moveDrag;
		velocity.y = 0;
		offset.y = groundYOffset;
		jumping.reset();
		jumpCooldown.reset();
		followOffset = 3;
		animation.play("land");
		FlxG.sound.play(AssetPaths.land__ogg);
	}

	private function crouchEnter()
	{
		drag.x = drag.y = moveDrag;
		offset.y = groundYOffset;
		jumping.reset();
		jumpCooldown.reset();
		followOffset = 3;
		animation.play("crouch");
	}

	private function walkEnter()
	{
		drag.x = drag.y = moveDrag;
		offset.y = groundYOffset;
		followOffset = 2;
		animation.play("walk");
	}

	private function walkLeave()
	{
		animation.stop();
	}

	private function fallEnter()
	{
		drag.x = drag.y = airDrag;
		offset.y = airYOffset;
		followOffset = 2;
		acceleration.y = gravity;
	}

	private function jumpEnter()
	{
		acceleration.y = gravity;
		drag.x = drag.y = airDrag;
		offset.y = airYOffset;
		followOffset = 2;
		animation.play("jump");
		jump(jumpStrength, jumpVariable);
		FlxG.sound.play(AssetPaths.flap__ogg);
	}

	private function flapEnter()
	{
		drag.x = drag.y = airDrag;
		followOffset = 2;
		animation.play("flap");
		jump(flapStrength, flapVariable);
		currentFlapStrength = flapStrength;
		FlxG.sound.play(AssetPaths.flap__ogg);
	}

	private function weakflapEnter()
	{
		drag.x = drag.y = airDrag;
		followOffset = 2;
		animation.play("weakflap");
		if (parcel.held)
		{
			currentFlapStrength /= 2.0;
		}
		if (currentFlapStrength < weakflapStrength)
		{
			currentFlapStrength = weakflapStrength;
		}
		// trace("weak flap: " + currentFlapStrength);
		jump(currentFlapStrength, flapVariable);
		FlxG.sound.play(AssetPaths.flap__ogg, currentFlapStrength / flapStrength);
	}

	private function glideEnter()
	{
		drag.x = drag.y = airDrag;
		followOffset = 2;
		acceleration.y = glideGravity;
	}

	private function glideLeave()
	{
		acceleration.y = gravity;
		animation.stop();
	}

	private function stunEnter()
	{
		velocity.x = velocity.y = 0;
		offset.y = groundYOffset;
		followOffset = 3;
		stunned.trigger();
		animation.play("stun");
		// FlxG.sound.play(AssetPaths.stun__ogg);
	}

	private function airDashEnter()
	{
		drag.x = drag.y = airDrag;
		offset.y = airYOffset;

		elasticity = 0.5;
		followOffset = 2;
		acceleration.y = 1;
		maxVelocity.x = maxVelocity.y = maxDashVelocity;
		angle = 0;
		dashCooldown.trigger();
		dashing.trigger();
		// FlxG.sound.play(AssetPaths.dash__ogg);
		DustEmitter.instance.x = x;
		DustEmitter.instance.y = y;

		/*trace("delayed left: " + Input.control.left.justPressedDelayed + " right: " + Input.control.right.justPressedDelayed + " up: "
				+ Input.control.up.justPressedDelayed + " down: " + Input.control.down.justPressedDelayed);
			trace("justpressed left: " + Input.control.left.justPressed + " right: " + Input.control.right.justPressed + " up: " + Input.control.up.justPressed
				+ " down: " + Input.control.down.justPressed);
			trace("pressed left: " + Input.control.left.pressed + " right: " + Input.control.right.pressed + " up: " + Input.control.up.pressed
				+ " down: " + Input.control.down.pressed); */

		delayedDash = !Input.control.anyJustPressed;

		var diagonal:Bool = Input.control.anyLeftRight;
		if (Input.control.left.justPressedDelayed)
		{
			facing = FlxDirectionFlags.LEFT;
		}
		if (Input.control.right.justPressedDelayed)
		{
			facing = FlxDirectionFlags.RIGHT;
		}

		if (Input.control.up.pressed || Input.control.up.justPressedDelayed)
		{
			animation.play("airDash");
			if (facing == FlxDirectionFlags.LEFT && diagonal)
			{
				velocity.x = -airDashDiagonalStrength;
				velocity.y = -airDashDiagonalStrength;
				// animation.play("airDashDiaUp");
				angle = 45;
				DustEmitter.instance.dashStartPoof(velocity);
				return;
			}
			if (facing == FlxDirectionFlags.RIGHT && diagonal)
			{
				velocity.x = airDashDiagonalStrength;
				velocity.y = -airDashDiagonalStrength;
				// animation.play("airDashDiaUp");
				angle = -45;
				DustEmitter.instance.dashStartPoof(velocity);
				return;
			}

			if (facing == FlxDirectionFlags.LEFT)
			{
				angle = 90;
			}
			else
			{
				angle = -90;
			}
			velocity.x = 0;
			velocity.y = -airDashStrength;
			DustEmitter.instance.dashStartPoof(velocity);
			return;
		}
		if (Input.control.down.pressed || Input.control.down.justPressedDelayed)
		{
			animation.play("airDash");
			if (facing == FlxDirectionFlags.LEFT && diagonal)
			{
				velocity.x = -airDashDiagonalStrength;
				velocity.y = airDashDiagonalStrength;
				// animation.play("airDashDiaDown");
				angle = -45;
				DustEmitter.instance.dashStartPoof(velocity);
				return;
			}
			if (facing == FlxDirectionFlags.RIGHT && diagonal)
			{
				velocity.x = airDashDiagonalStrength;
				velocity.y = airDashDiagonalStrength;
				// animation.play("airDashDiaDown");
				angle = 45;
				DustEmitter.instance.dashStartPoof(velocity);
				return;
			}

			if (facing == FlxDirectionFlags.LEFT)
			{
				angle = -90;
			}
			else
			{
				angle = 90;
			}
			velocity.x = 0;
			velocity.y = airDashStrength;
			DustEmitter.instance.dashStartPoof(velocity);
			return;
		}
		if (facing == FlxDirectionFlags.LEFT)
		{
			velocity.x = -airDashStrength;
			velocity.y = 0;
			animation.play("airDash");
			DustEmitter.instance.dashStartPoof(velocity);
			return;
		}
		if (facing == FlxDirectionFlags.RIGHT)
		{
			velocity.x = airDashStrength;
			velocity.y = 0;
			animation.play("airDash");
			DustEmitter.instance.dashStartPoof(velocity);
			return;
		}
	}

	private function airDashLeave()
	{
		acceleration.y = gravity;
		maxVelocity.x = maxVelocity.y = maxMoveVelocity;
		angle = 0;
		scale.x = 1.0;
		scale.y = 1.0;
		elasticity = 0;
	}

	private function idleUpdate()
	{
		if (Input.control.pressedBothX || Input.control.pressedBothY)
		{
			return;
		}
		if (canDash())
		{
			/*if (onGround.soft && Input.control.down.pressed)
				{
					fsm.switchState(MoveState.Crouch);
					return;
			}*/
			fsm.switchState(MoveState.AirDash);
			onGround.hard = false;
			return;
		}
		if (onGround.soft)
		{
			if (Input.control.down.justPressed)
			{
				fsm.switchState(MoveState.Crouch);
				return;
			}
			if (Input.control.anyLeftRight)
			{
				fsm.switchState(MoveState.Walk);
			}
			if (Input.control.up.justPressed)
			{
				fsm.switchState(MoveState.Jump);
			}
			return;
		}

		fsm.switchState(MoveState.Fall);
	}

	private function crouchUpdate()
	{
		if (canDash())
		{
			/*if (onGround.soft && Input.control.down.pressed)
				{
					fsm.switchState(MoveState.Crouch);
					return;
			}*/
			fsm.switchState(MoveState.AirDash);
			onGround.hard = false;
			return;
		}
		if (Input.control.pressedBothX || Input.control.pressedBothY)
		{
			return;
		}
		else if (Input.control.left.pressed)
		{
			facing = FlxDirectionFlags.LEFT;
		}
		else if (Input.control.right.pressed)
		{
			facing = FlxDirectionFlags.RIGHT;
		}

		if (onGround.soft)
		{
			if (!Input.control.down.pressed)
			{
				fsm.switchState(MoveState.Idle);
				return;
			}
			if (Input.control.up.justPressed)
			{
				fsm.switchState(MoveState.Jump);
				return;
			}
			return;
		}

		fsm.switchState(MoveState.Fall);
	}

	private function walkUpdate()
	{
		if (canDash())
		{
			/*if (onGround.soft && Input.control.down.pressed)
				{
					fsm.switchState(MoveState.Crouch);
					return;
			}*/
			fsm.switchState(MoveState.AirDash);
			onGround.hard = false;
			return;
		}
		if (onGround.soft)
		{
			move(moveSpeed);
			if (Input.control.down.justPressed)
			{
				fsm.switchState(MoveState.Crouch);
				return;
			}
			if (Input.control.up.justPressed)
			{
				fsm.switchState(MoveState.Jump);
			}
			if (!Input.control.anyLeftRight)
			{
				fsm.switchState(MoveState.Idle);
			}
			return;
		}

		fsm.switchState(MoveState.Fall);
	}

	private function fallUpdate()
	{
		if (onGround.soft)
		{
			fsm.switchState(MoveState.Land);
			return;
		}
		if (canDash())
		{
			fsm.switchState(MoveState.AirDash);
		}
		else if (canFlip())
		{
			fsm.switchState(MoveState.Flip);
			return;
		}
		else if (Input.control.up.justPressed && !jumpCooldown.soft)
		{
			fsm.switchState(MoveState.Flap);
		}
		else if (Input.control.up.justPressed)
		{
			fsm.switchState(MoveState.WeakFlap);
			return;
		}
		else if (Input.control.up.pressed || Input.control.keys.get("select").pressed)
		{
			fsm.switchState(MoveState.Glide);
		}
		if (animation.finished)
		{
			animation.play("fall");
		}
		move(airMoveSpeed);
	}

	private function landUpdate()
	{
		if (canDash())
		{
			fsm.switchState(MoveState.AirDash);
			onGround.hard = false;
			return;
		}
		move(moveSpeed);
		if (onGround.soft)
		{
			if (Input.control.down.pressed)
			{
				fsm.switchState(MoveState.Crouch);
				return;
			}
			if (Input.control.up.justPressed)
			{
				fsm.switchState(MoveState.Jump);
			}
			if (animation.finished)
				fsm.switchState(MoveState.Idle);
			return;
		}

		fsm.switchState(MoveState.Fall);
	}

	private function jumpUpdate()
	{
		if (canDash())
		{
			fsm.switchState(MoveState.AirDash);
			onGround.hard = false;
			return;
		}
		if (onGround.hard)
		{
			fsm.switchState(MoveState.Land);
			return;
		}
		if (canFlip())
		{
			fsm.switchState(MoveState.Flip);
			return;
		}
		if (!jumping.soft)
		{
			if (Input.control.up.justPressed && !jumpCooldown.soft)
			{
				fsm.switchState(MoveState.Flap);
				return;
			}
			else if (Input.control.up.justPressed)
			{
				if (parcel.held)
				{
					fsm.switchState(MoveState.WeakFlap);
				}
				else
				{
					fsm.switchState(MoveState.Flap);
				}
				return;
			}
			else if (Input.control.up.pressed || Input.control.keys.get("select").pressed)
			{
				fsm.switchState(MoveState.Glide);
				return;
			}

			if (animation.finished)
				fsm.switchState(MoveState.Fall);
		}

		if (!Input.control.up.justPressed)
		{
			jump(jumpStrength, jumpVariable);
		}
		move(airMoveSpeed);
	}

	private function flapUpdate()
	{
		if (canDash())
		{
			fsm.switchState(MoveState.AirDash);
			onGround.hard = false;
			return;
		}
		if (onGround.hard)
		{
			fsm.switchState(MoveState.Land);
			return;
		}
		if (canFlip())
		{
			fsm.switchState(MoveState.Flip);
			return;
		}
		if (!jumping.soft)
		{
			if (canDash())
			{
				fsm.switchState(MoveState.AirDash);
			}
			else if (Input.control.up.justPressed && !jumpCooldown.soft)
			{
				fsm.switchState(MoveState.Flap);
				return;
			}
			else if (Input.control.up.justPressed)
			{
				if (parcel.held)
				{
					fsm.switchState(MoveState.WeakFlap);
				}
				else
				{
					fsm.switchState(MoveState.Flap);
				}
				return;
			}
			else if (Input.control.up.pressed || Input.control.keys.get("select").pressed)
			{
				fsm.switchState(MoveState.Glide);
				return;
			}
			fsm.switchState(MoveState.Fall);
		}

		if (!Input.control.up.justPressed)
		{
			jump(jumpStrength, jumpVariable);
		}
		move(airMoveSpeed);
	}

	private function glideUpdate()
	{
		if (onGround.hard)
		{
			fsm.switchState(MoveState.Land);
			return;
		}
		if (canDash())
		{
			fsm.switchState(MoveState.AirDash);
		}
		else if (canFlip())
		{
			fsm.switchState(MoveState.Flip);
			return;
		}
		else if (Input.control.up.justPressed && !jumpCooldown.soft)
		{
			fsm.switchState(MoveState.Flap);
			return;
		}
		else if (Input.control.up.justPressed)
		{
			if (parcel.held)
			{
				fsm.switchState(MoveState.WeakFlap);
			}
			else
			{
				fsm.switchState(MoveState.Flap);
			}
			return;
		}
		if (!Input.control.up.pressed && !Input.control.keys.get("select").pressed)
		{
			fsm.switchState(MoveState.Fall);
			return;
		}
		if (animation.finished)
		{
			animation.play("glide");
		}
		move(airMoveSpeed);
	}

	private function airDashUpdate()
	{
		if (onGround.hard)
		{
			fsm.switchState(MoveState.Land);
			return;
		}

		if (!dashUntethered && isTouching(FlxDirectionFlags.WALL | FlxDirectionFlags.CEILING))
		{
			fsm.switchState(MoveState.Stun);
			return;
		}

		if (Input.control.anyJustPressed && Input.control.keys.get("select").justPressedDelayed)
		{
			fsm.switchState(MoveState.AirDash);
		}
		else if (dashUntethered && (Input.control.anyJustPressed || Input.control.keys.get("select").justPressed))
		{
			fsm.switchState(MoveState.AirDash);
		}

		if (isTouching(FlxDirectionFlags.FLOOR) && velocity.y > 10.0)
		{
			animation.stop();
			onGround.hard = true;
			fsm.switchState(MoveState.Land);
			return;
		}
		if (!dashing.soft && animation.finished)
		{
			if (Input.control.keys.get("select").pressed)
			{
				fsm.switchState(MoveState.Glide);
				return;
			}
			fsm.switchState(MoveState.Fall);
		}
		else
		{
			if (animation.curAnim.curFrame == 2)
			{
				scale.x = 1.5;
				scale.y = 0.5;
			}
			else
			{
				scale.x = scale.y = 1.0;
			}

			DustEmitter.instance.x = x;
			DustEmitter.instance.y = y;
			DustEmitter.instance.dashPoof();
			if (!dashLimited)
			{
				DustEmitter.instance.dashPoof();
			}
			if (dashUntethered)
			{
				DustEmitter.instance.dashPoof();
			}
			move(airMoveSpeed);
		}
	}

	private function stunUpdate()
	{
		if (!stunned.soft)
		{
			if (onGround.hard)
			{
				fsm.switchState(MoveState.Land);
				return;
			}
			fsm.switchState(MoveState.Fall);
		}
	}

	private function flipEnter()
	{
		drag.x = drag.y = airDrag;
		parcel.spring = 4.0;
		followOffset = 2;
		acceleration.y = 0;
		flipCounter = 0;
		// preservedVelocity.set(velocity.x, velocity.y);
		preservedVelocity.set(parcel.held ? velocity.x : 0, 0);
		animation.play("flip");
		DustEmitter.instance.x = x;
		DustEmitter.instance.y = y;
		DustEmitter.instance.dashStartPoof(velocity);

		if (!parcel.held)
			return;
		DustEmitter.instance.x = parcel.x + width / 2;
		DustEmitter.instance.y = parcel.y + height / 2;
		DustEmitter.instance.dashStartPoof(velocity);
		parcel.velocity.x = preservedVelocity.x * 0.9;
		/*if (velocity.y < 0)
			{
				parcel.velocity.y = velocity.y / 1.5;
		}*/
	}

	private function flipUpdate()
	{
		parcel.spring = 4.0;
		if (parcel.held)
		{
			parcel.y = (parcel.y * 5.0 + y) / 6.0;
		}
		TrailEmitter.instance.x = x + width / 2;
		TrailEmitter.instance.y = y + height / 2;
		TrailEmitter.instance.constantPoof();
		if (onGround.hard)
		{
			fsm.switchState(MoveState.Land);
			return;
		}
		if (isTouching(FlxDirectionFlags.CEILING))
		{
			if (parcel.held)
			{
				parcel.velocity.x = 0;
				parcel.held = false;
			}
		}
		if (isTouching(FlxDirectionFlags.WALL | FlxDirectionFlags.CEILING))
		{
			fsm.switchState(MoveState.Stun);
			return;
		}

		/*if (Input.control.anyJustPressed && Input.control.keys.get("select").justPressedDelayed)
			{
				fsm.switchState(MoveState.AirDash);
			}
			else if (dashUntethered && (Input.control.anyJustPressed || Input.control.keys.get("select").justPressed))
			{
				fsm.switchState(MoveState.AirDash);
		}*/

		if (isTouching(FlxDirectionFlags.FLOOR))
		{
			onGround.hard = true;
			velocity.set(0, 0);
			fsm.switchState(MoveState.Land);
			return;
		}
		if (flipCounter > (3.14 / flipPeriod) && flipCounter < (6.0 / flipPeriod) && canFlipinFlip())
		{
			setIfParcelCanBeHeld();
			flipEnter();
		}

		if ((flipCounter > (3.14 / flipPeriod)
			&& flipCounter < (6.28 / flipPeriod)
			&& ((flipDir == FlxDirectionFlags.RIGHT) ? Input.control.left.pressed : Input.control.right.pressed))
			|| flipCounter > (6.28 / flipPeriod)
			|| Input.control.down.justPressed
			|| (flipCounter > (1.0 / flipPeriod)
				&& ((flipDir == FlxDirectionFlags.RIGHT) ? Input.control.left.justPressed : Input.control.right.justPressed)))
		{
			if (Input.control.keys.get("select").pressed)
			{
				fsm.switchState(MoveState.Glide);
				return;
			}
			fsm.switchState(MoveState.Fall);
		}
		else
		{
			moveFlip(airMoveSpeed / 3.0);
		}

		if (!parcel.held)
			return;
		DustEmitter.instance.x = parcel.x + width / 2;
		DustEmitter.instance.y = parcel.y + height / 2;
		DustEmitter.instance.constantDownPoof();
	}

	private function flipLeave()
	{
		if (velocity.x < 0)
		{
			facing = FlxDirectionFlags.LEFT;
		}
		else if (velocity.x > 0)
		{
			facing = FlxDirectionFlags.RIGHT;
		}
		animation.stop();

		setIfParcelCanBeHeld();
		if (!parcel.held)
			return;
		parcel.spring = 4.0;
		DustEmitter.instance.x = parcel.x + width / 2;
		DustEmitter.instance.y = parcel.y + height / 2;
		DustEmitter.instance.downPoof();
		DustEmitter.instance.floorPoof();
	}

	private function setIfParcelCanBeHeld()
	{
		// All the flips
		return;
		if (Math.abs(parcel.x - x) > 8 || Math.abs(parcel.y - y) > 20)
		{
			parcel.held = false;
		}
	}

	private function canDash()
	{
		if (dashUntethered)
		{
			dashing.setDelay(untetheredDashTime);
		}
		else
		{
			dashing.setDelay(normalDashTime);
		}

		var attemptDash:Bool = (Input.control.keys.get("select").justPressed && !dashCooldown.soft);
		if (attemptDash && dashLimited)
		{
			if (dashCount <= 0)
				return false;

			dashCount--;
			// PlayState.instance.updateDashCount();
		}
		return attemptDash;
	}

	private function canFlip()
	{
		if (flipCache[0] == FlxDirectionFlags.LEFT && flipCache[1] == FlxDirectionFlags.UP && flipCache[2] == FlxDirectionFlags.RIGHT)
		{
			// trace("0: " + flipCache[0] + " \n1: " + flipCache[1] + " \n2: " + flipCache[2]);
			flipDir = FlxDirectionFlags.RIGHT;
			clearFlipCache();
			return true;
		}
		if (flipCache[0] == FlxDirectionFlags.RIGHT && flipCache[1] == FlxDirectionFlags.UP && flipCache[2] == FlxDirectionFlags.LEFT)
		{
			// trace("0: " + flipCache[0] + " \n1: " + flipCache[1] + " \n2: " + flipCache[2]);
			flipDir = FlxDirectionFlags.LEFT;
			clearFlipCache();
			return true;
		}
		if (flipCache[0] == FlxDirectionFlags.LEFT && facing == FlxDirectionFlags.RIGHT)
		{
			// trace("0: " + flipCache[0] + " \n1: " + flipCache[1] + " \n2: " + flipCache[2]);
			flipDir = FlxDirectionFlags.RIGHT;
			clearFlipCache();
			return true;
		}
		if (flipCache[0] == FlxDirectionFlags.RIGHT && facing == FlxDirectionFlags.LEFT)
		{
			// trace("0: " + flipCache[0] + " \n1: " + flipCache[1] + " \n2: " + flipCache[2]);
			flipDir = FlxDirectionFlags.LEFT;
			clearFlipCache();
			return true;
		}
		return false;
	}

	private function canFlipinFlip()
	{
		if (flipCache[0] == FlxDirectionFlags.RIGHT && flipDir == FlxDirectionFlags.RIGHT)
		{
			// trace("0: " + flipCache[0] + " \n1: " + flipCache[1] + " \n2: " + flipCache[2]);
			flipDir = FlxDirectionFlags.LEFT;
			clearFlipCache();
			return true;
		}
		if (flipCache[0] == FlxDirectionFlags.LEFT && flipDir == FlxDirectionFlags.LEFT)
		{
			// trace("0: " + flipCache[0] + " \n1: " + flipCache[1] + " \n2: " + flipCache[2]);
			flipDir = FlxDirectionFlags.RIGHT;
			clearFlipCache();
			return true;
		}
		return false;
	}

	private function move(p_move_speed:Float)
	{
		DustEmitter.instance.x = x;
		DustEmitter.instance.y = y;
		DustEmitter.instance.constantPoof();

		if (onGround.soft)
		{
			if (Input.control.left.pressed && velocity.x > -groundBoost)
			{
				velocity.x = -groundBoost;
			}
			if (Input.control.right.pressed && velocity.x < groundBoost)
			{
				velocity.x = groundBoost;
			}
		}
		if (Input.control.pressedBothX) {}
		else if (Input.control.left.pressed)
		{
			velocity.x -= elapsed * p_move_speed;
		}
		else if (Input.control.right.pressed)
		{
			velocity.x += elapsed * p_move_speed;
		}
		if (velocity.x < 0)
		{
			facing = FlxDirectionFlags.LEFT;
		}
		else if (velocity.x > 0)
		{
			facing = FlxDirectionFlags.RIGHT;
		}
	}

	private function moveFlip(p_move_speed:Float)
	{
		DustEmitter.instance.x = x;
		DustEmitter.instance.y = y;
		DustEmitter.instance.constantPoof();

		if (Input.control.pressedBothX) {}
		else if (Input.control.left.pressed)
		{
			preservedVelocity.x -= elapsed * p_move_speed;
		}
		else if (Input.control.right.pressed)
		{
			preservedVelocity.x += elapsed * p_move_speed;
		}
		if (Input.control.pressedBothY) {}
		else if (Input.control.up.pressed)
		{
			preservedVelocity.y -= elapsed * p_move_speed;
		}
		else if (Input.control.down.pressed)
		{
			preservedVelocity.y += elapsed * p_move_speed;
		}

		flipCounter += elapsed;
		var dir:Float = (flipDir == FlxDirectionFlags.RIGHT) ? 1.0 : -1.0;
		velocity.x = preservedVelocity.x +
			dir * flipSpeed * FlxMath.fastCos(flipCounter * flipPeriod); // * Math.max(1.0, Math.abs(preservedVelocity.x / 50.0));
		velocity.y = preservedVelocity.y + -flipSpeed * FlxMath.fastSin(flipCounter * flipPeriod); // * Math.max(1.0, Math.abs(preservedVelocity.x / 50.0));
	}

	private function jump(p_jump_strength:Float, p_jump_variable:Float)
	{
		if (Input.control.up.justPressed)
		{
			velocity.y -= p_jump_strength;
			/*if (velocity.y < -jumpStrength && p_jump_strength == flapStrength)
				{
					velocity.y = -jumpStrength;
			}*/

			if (!jumping.soft)
			{
				jumping.trigger();
			}
			jumpCooldown.trigger();
			DustEmitter.instance.x = x;
			DustEmitter.instance.y = y;
			if (Input.control.left.justPressedDelayed)
			{
				velocity.x -= airBoost;
				DustEmitter.instance.leftPoof();
			}
			else if (Input.control.right.justPressedDelayed)
			{
				velocity.x += airBoost;
				DustEmitter.instance.rightPoof();
			}
			DustEmitter.instance.downPoof();
		}
		else if (Input.control.up.pressed && jumping.soft)
		{
			velocity.y -= elapsed * p_jump_variable;
		}

		if (Input.control.down.pressed)
		{
			// velocity.y += elapsed * p_move_speed;
		}
	}

	override function destroy()
	{
		preservedVelocity.put();
		super.destroy();
	}
}
