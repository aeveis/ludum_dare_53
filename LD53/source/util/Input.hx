package util;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxDirectionFlags;

enum InputSetup
{
	None;
	TopDown;
	Platformer;
}

/**
 * Input Manager for adding different key states
 * @author aeveis
 */
class Input
{
	public static var control:Input;
	private static var switchToGamepadCallback:Void->Void = null;
	private static var switchToKeysCallback:Void->Void = null;

	public var left:InputState = null;
	public var right:InputState = null;
	public var up:InputState = null;
	public var down:InputState = null;
	public var names:Array<String> = null;
	public var keys:Map<String, InputState> = null;
	public var pressed:Int = FlxDirectionFlags.NONE;
	public var lastPressed:Int = FlxDirectionFlags.NONE;

	public var existingKey:String = null;
	public var inputSetup:InputSetup = InputSetup.None;
	public var upStickJumpDisabled = false;

	public var any(get, null):Bool;

	function get_any()
	{
		return up.pressed || down.pressed || left.pressed || right.pressed;
	}

	public var anyJustPressed(get, null):Bool;

	function get_anyJustPressed()
	{
		return up.justPressed || down.justPressed || left.justPressed || right.justPressed;
	}

	public var noneX(get, null):Bool;

	function get_noneX()
	{
		return (pressed == FlxDirectionFlags.NONE || pressed == FlxDirectionFlags.DOWN || pressed == FlxDirectionFlags.UP);
	}

	public var pressedBothX(get, null):Bool;

	function get_pressedBothX()
	{
		return left.pressed && right.pressed;
	}

	public var pressedBothY(get, null):Bool;

	function get_pressedBothY()
	{
		return up.pressed && down.pressed;
	}

	public var anyUpDown(get, null):Bool;

	function get_anyUpDown()
	{
		return up.pressed || down.pressed;
	}

	public var anyLeftRight(get, null):Bool;

	function get_anyLeftRight()
	{
		return left.pressed || right.pressed;
	}

	public var none(get, null):Bool;

	function get_none()
	{
		return pressed == FlxDirectionFlags.NONE;
	}

	public var stickSensitivity:Float = 0.35;

	private var stickMovedX:Bool = false;
	private var stickJustMovedX:Bool = false;
	private var stickJustReleaseX:Bool = false;
	private var stickMovedY:Bool = false;
	private var stickJustMovedY:Bool = false;
	private var stickJustReleaseY:Bool = false;
	private var refreshStick:Bool = true;
	private var refreshStickCounter:Float = 0;
	private var refreshStickDelay:Float = 0.2;

	static public inline var INVALID_KEY:Int = 0;
	static public inline var REMAP_KEY:Int = 1;
	static public inline var SAME_KEY:Int = 2;
	static public inline var EXISTING_KEY:Int = 3;

	public static function switchToGamepad()
	{
		if (switchToGamepadCallback == null)
			return;
		switchToGamepadCallback();
	}

	public static function switchToKeyboard()
	{
		if (switchToKeysCallback == null)
			return;
		switchToKeysCallback();
	}

	public static function setSwitchGamepadCallback(p_callback:Void->Void)
	{
		switchToGamepadCallback = p_callback;
	}

	public static function setSwitchKeysCallback(p_callback:Void->Void)
	{
		switchToKeysCallback = p_callback;
	}

	public static function checkValidGamepadInputs(p_gamepadKey:FlxGamepadInputID):Bool
	{
		switch (p_gamepadKey)
		{
			case FlxGamepadInputID.GUIDE | FlxGamepadInputID.LEFT_ANALOG_STICK | FlxGamepadInputID.RIGHT_ANALOG_STICK | FlxGamepadInputID.TILT_PITCH | FlxGamepadInputID.LEFT_STICK_DIGITAL_UP | FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT | FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN | FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT | FlxGamepadInputID.TILT_ROLL | FlxGamepadInputID.NONE:
				return false;
			default:
				return true;
		}
	}

	public static function getInputString(p_key:FlxKey):String
	{
		var name:String = p_key.toString();
		switch (p_key)
		{
			case FlxKey.ZERO:
				name = "0";
			case FlxKey.ONE:
				name = "1";
			case FlxKey.TWO:
				name = "2";
			case FlxKey.THREE:
				name = "3";
			case FlxKey.FOUR:
				name = "4";
			case FlxKey.FIVE:
				name = "5";
			case FlxKey.SIX:
				name = "6";
			case FlxKey.SEVEN:
				name = "7";
			case FlxKey.EIGHT:
				name = "8";
			case FlxKey.NINE:
				name = "9";
			case FlxKey.PAGEUP:
				name = "PG_UP";
			case FlxKey.PAGEDOWN:
				name = "PG_DN";
			case FlxKey.INSERT:
				name = "INS";
			case FlxKey.ESCAPE:
				name = "ESC";
			case FlxKey.DELETE:
				name = "DEL";
			case FlxKey.BACKSPACE:
				name = "BKSP";
			case FlxKey.LBRACKET:
				name = "[";
			case FlxKey.RBRACKET:
				name = "]";
			case FlxKey.BACKSLASH:
				name = "\\";
			case FlxKey.CAPSLOCK:
				name = "CL";
			case FlxKey.SEMICOLON:
				name = ";";
			case FlxKey.QUOTE:
				name = "\"";
			case FlxKey.PERIOD:
				name = ".";
			case FlxKey.SLASH:
				name = "/";
			case FlxKey.GRAVEACCENT:
				name = "`";
			case FlxKey.CONTROL:
				name = "CTRL";
			case FlxKey.PRINTSCREEN:
				name = "PRTSC";
			case FlxKey.NUMPADZERO:
				name = "N0";
			case FlxKey.NUMPADONE:
				name = "N1";
			case FlxKey.NUMPADTWO:
				name = "N2";
			case FlxKey.NUMPADTHREE:
				name = "N3";
			case FlxKey.NUMPADFOUR:
				name = "N4";
			case FlxKey.NUMPADFIVE:
				name = "N5";
			case FlxKey.NUMPADSIX:
				name = "N6";
			case FlxKey.NUMPADSEVEN:
				name = "N7";
			case FlxKey.NUMPADNINE:
				name = "N8";
			case FlxKey.NUMPADMINUS:
				name = "N-";
			case FlxKey.NUMPADPLUS:
				name = "N+";
			case FlxKey.NUMPADPERIOD:
				name = "N.";
			case FlxKey.NUMPADMULTIPLY:
				name = "N*";
			default:
		}
		return name;
	}

	public static function getGamepadInputString(p_gamepadKey:FlxGamepadInputID):String
	{
		var name:String = p_gamepadKey.toString();
		switch (p_gamepadKey)
		{
			case FlxGamepadInputID.LEFT_SHOULDER:
				name = "LSHDR";
			case FlxGamepadInputID.RIGHT_SHOULDER:
				name = "RSHDR";
			case FlxGamepadInputID.LEFT_STICK_CLICK:
				name = "LSTKB";
			case FlxGamepadInputID.RIGHT_STICK_CLICK:
				name = "RSTKB";
			case FlxGamepadInputID.DPAD_UP:
				name = "DUP";
			case FlxGamepadInputID.DPAD_DOWN:
				name = "DDOWN";
			case FlxGamepadInputID.DPAD_LEFT:
				name = "DLEFT";
			case FlxGamepadInputID.DPAD_RIGHT:
				name = "DRGHT";
			case FlxGamepadInputID.LEFT_TRIGGER_BUTTON:
				name = "LTBTN";
			case FlxGamepadInputID.RIGHT_TRIGGER_BUTTON:
				name = "RTBTN";
			case FlxGamepadInputID.LEFT_TRIGGER:
				name = "LT";
			case FlxGamepadInputID.RIGHT_TRIGGER:
				name = "RT";
			case FlxGamepadInputID.LEFT_ANALOG_STICK:
				name = "LSTK";
			case FlxGamepadInputID.RIGHT_ANALOG_STICK:
				name = "RSTK";
			case FlxGamepadInputID.LEFT_STICK_DIGITAL_UP:
				name = "LSUP";
			case FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT:
				name = "LSRGT";
			case FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN:
				name = "LSDWN";
			case FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT:
				name = "LSLFT";
			case FlxGamepadInputID.RIGHT_STICK_DIGITAL_UP:
				name = "RSUP";
			case FlxGamepadInputID.RIGHT_STICK_DIGITAL_RIGHT:
				name = "RSRGT";
			case FlxGamepadInputID.RIGHT_STICK_DIGITAL_DOWN:
				name = "RSDWN";
			case FlxGamepadInputID.RIGHT_STICK_DIGITAL_LEFT:
				name = "RSLFT";
			default:
		}
		return name;
	}

	public function new()
	{
		left = new InputState();
		left.name = "left";
		right = new InputState();
		right.name = "right";
		up = new InputState();
		up.name = "up";
		down = new InputState();
		down.name = "down";

		names = new Array<String>();
		keys = new Map<String, InputState>();
	}

	public function topdownSetup()
	{
		inputSetup = InputSetup.TopDown;
		updateInput(left, ["LEFT", "A"], ["DPAD_LEFT"]);
		updateInput(right, ["RIGHT", "D"], ["DPAD_RIGHT"]);
		updateInput(up, ["UP", "W"], ["DPAD_UP"]);
		updateInput(down, ["DOWN", "S"], ["DPAD_DOWN"]);

		addInput("select", ["X", "PERIOD", "SLASH"], ["A"]);
		addInput("undo", ["Z", "E"], ["B"]);
		addInput("pause", ["ENTER", "ESCAPE"], ["START"]);
		addInput("restart", ["R"], ["LEFT_SHOULDER"]);
	}

	public function platformerSetup()
	{
		inputSetup = InputSetup.Platformer;
		updateInput(left, ["LEFT", "A"], ["DPAD_LEFT"]);
		updateInput(right, ["RIGHT", "D"], ["DPAD_RIGHT"]);
		updateInput(up, ["UP", "W", "SPACE"], ["DPAD_UP", "X", "Y"]);
		updateInput(down, ["DOWN", "S"], ["DPAD_DOWN"]);
		upStickJumpDisabled = true;
		refreshStick = false;

		addInput("select", ["X", "PERIOD", "SLASH"], ["A"]);
		addInput("action", ["Z", "E"], ["B"]);
		addInput("pause", ["ENTER", "ESCAPE"], ["START"]);
		addInput("restart", ["R"], ["LEFT_SHOULDER"]);
	}

	public function updateInput(p_input:InputState, p_keys:Array<FlxKey>, ?p_gamepads:Array<FlxGamepadInputID>)
	{
		for (key in p_keys)
		{
			p_input.addKeyInput(key);
		}

		if (p_gamepads != null)
		{
			for (gamepad in p_gamepads)
			{
				p_input.addGamepadInput(gamepad);
			}
		}
	}

	public function addInput(p_name:String, p_keys:Array<FlxKey>, ?p_gamepads:Array<FlxGamepadInputID>)
	{
		var newInput:InputState = null;
		newInput = keys.get(p_name);
		if (newInput == null)
		{
			newInput = new InputState();
			newInput.name = p_name;
			keys.set(p_name, newInput);
			names.push(p_name);
		}
		for (key in p_keys)
		{
			newInput.addKeyInput(key);
		}

		if (p_gamepads != null)
		{
			for (gamepad in p_gamepads)
			{
				newInput.addGamepadInput(gamepad);
			}
		}
	}

	public function getFirstInputString(p_name:String)
	{
		var input = keys.get(p_name);
		if (input != null)
		{
			return input.getFirstInputString();
		}
		return "none";
	}

	public function replaceInputKeyMap(p_input:InputState, p_prevKey:FlxKey, p_key:FlxKey):Int
	{
		if (p_prevKey == p_key)
			return SAME_KEY;
		if (left.keyMapping.indexOf(p_key) != -1)
		{
			existingKey = left.name.toUpperCase();
			return EXISTING_KEY;
		}
		else if (right.keyMapping.indexOf(p_key) != -1)
		{
			existingKey = right.name.toUpperCase();
			return EXISTING_KEY;
		}
		else if (up.keyMapping.indexOf(p_key) != -1)
		{
			existingKey = up.name.toUpperCase();
			return EXISTING_KEY;
		}
		else if (down.keyMapping.indexOf(p_key) != -1)
		{
			existingKey = down.name.toUpperCase();
			return EXISTING_KEY;
		}
		else
		{
			for (input in keys)
			{
				if (input.keyMapping.indexOf(p_key) != -1)
				{
					existingKey = input.name.toUpperCase();
					return EXISTING_KEY;
				}
			}
		}

		var result = p_input.addKeyInput(p_key);
		switch (result)
		{
			case REMAP_KEY:
				p_input.removeKeyInput(p_prevKey);
		}

		return result;
	}

	public function replaceInputGamepadMap(p_input:InputState, p_prevKey:FlxGamepadInputID, p_key:FlxGamepadInputID):Int
	{
		if (p_prevKey == p_key)
			return SAME_KEY;
		if (left.gamepadMapping.indexOf(p_key) != -1)
		{
			existingKey = left.name.toUpperCase();
			return EXISTING_KEY;
		}
		else if (right.gamepadMapping.indexOf(p_key) != -1)
		{
			existingKey = right.name.toUpperCase();
			return EXISTING_KEY;
		}
		else if (up.gamepadMapping.indexOf(p_key) != -1)
		{
			existingKey = up.name.toUpperCase();
			return EXISTING_KEY;
		}
		else if (down.gamepadMapping.indexOf(p_key) != -1)
		{
			existingKey = down.name.toUpperCase();
			return EXISTING_KEY;
		}
		else
		{
			for (input in keys)
			{
				if (input.gamepadMapping.indexOf(p_key) != -1)
				{
					existingKey = input.name.toUpperCase();
					return EXISTING_KEY;
				}
			}
		}

		var result = p_input.addGamepadInput(p_key);
		switch (result)
		{
			case REMAP_KEY:
				p_input.removeGamepadInput(p_prevKey);
		}

		return result;
	}

	public function removeAllBindings()
	{
		left.clearBindings();
		right.clearBindings();
		up.clearBindings();
		down.clearBindings();
		for (state in keys)
		{
			state.clearBindings();
		}
	}

	public function removeKeyInput(p_name:String, p_key:FlxKey)
	{
		var input:InputState = null;
		switch (p_name)
		{
			case "left":
				input = left;
			case "right":
				input = right;
			case "up":
				input = up;
			case "down":
				input = down;
			default:
				input = keys.get(p_name);
		}
		if (input == null)
			return;

		input.removeKeyInput(p_key);
	}

	public function removeGamepadInput(p_name:String, p_gamepad:FlxGamepadInputID)
	{
		var input:InputState = null;
		switch (p_name)
		{
			case "left":
				input = left;
			case "right":
				input = right;
			case "up":
				input = up;
			case "down":
				input = down;
			default:
				input = keys.get(p_name);
		}
		if (input == null)
			return;

		input.removeGamepadInput(p_gamepad);
	}

	public function removeInput(p_name:String)
	{
		keys.remove(p_name);
		names.remove(p_name);
	}

	public function update(elapsed:Float)
	{
		lastPressed = pressed;
		pressed = FlxDirectionFlags.NONE;

		left.update(elapsed);
		right.update(elapsed);
		up.update(elapsed);
		down.update(elapsed);

		for (key in names)
		{
			keys.get(key).update(elapsed);
		}

		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			stickJustMovedX = false;
			stickJustMovedY = false;

			if (gamepad.analog.justMoved.LEFT_STICK_X)
			{
				stickJustMovedX = true;
				refreshStickCounter = 0;
			}
			else if (gamepad.analog.justReleased.LEFT_STICK_X)
			{
				stickJustReleaseX = true;
			}
			if (gamepad.analog.justMoved.LEFT_STICK_Y)
			{
				stickJustMovedY = true;
				refreshStickCounter = 0;
			}
			else if (gamepad.analog.justReleased.LEFT_STICK_Y)
			{
				stickJustReleaseY = true;
			}

			if (gamepad.analog.value.LEFT_STICK_X > stickSensitivity)
			{
				if (!stickMovedX)
				{
					if (!right.isGamepad)
					{
						right.isGamepad = true;
						Input.switchToGamepad();
					}
					stickJustMovedX = true;
				}
				stickMovedX = true;
				right.pressed = true;
				if (refreshStick)
				{
					refreshStickCounter += elapsed;
					if (refreshStickCounter >= refreshStickDelay)
					{
						refreshStickCounter = 0;
						stickJustMovedX = true;
					}
				}
				if (stickJustMovedX)
				{
					right.justPressed = true;
				}
				if (stickJustReleaseX)
				{
					right.justReleased = true;
				}
			}
			else if (gamepad.analog.value.LEFT_STICK_X < -stickSensitivity)
			{
				if (!stickMovedX)
				{
					if (!left.isGamepad)
					{
						left.isGamepad = true;
						Input.switchToGamepad();
					}
					stickJustMovedX = true;
				}
				stickMovedX = true;
				left.pressed = true;
				if (refreshStick)
				{
					refreshStickCounter += elapsed;
					if (refreshStickCounter >= refreshStickDelay)
					{
						refreshStickCounter = 0;
						stickJustMovedX = true;
					}
				}
				if (stickJustMovedX)
				{
					left.justPressed = true;
				}
				if (stickJustReleaseX)
				{
					left.justReleased = true;
				}
			}

			if (gamepad.analog.value.LEFT_STICK_Y > stickSensitivity)
			{
				if (!stickMovedY)
				{
					if (!down.isGamepad)
					{
						down.isGamepad = true;
						Input.switchToGamepad();
					}
					stickJustMovedY = true;
				}
				stickMovedY = true;
				down.pressed = true;
				if (refreshStick)
				{
					refreshStickCounter += elapsed;
					if (refreshStickCounter >= refreshStickDelay)
					{
						refreshStickCounter = 0;
						stickJustMovedY = true;
					}
				}
				if (stickJustMovedY)
				{
					down.justPressed = true;
				}
				if (stickJustReleaseY)
				{
					down.justReleased = true;
				}
			}
			if (gamepad.analog.value.LEFT_STICK_Y < -stickSensitivity)
			{
				if (!stickMovedY)
				{
					if (!up.isGamepad)
					{
						up.isGamepad = true;
						Input.switchToGamepad();
					}
					stickJustMovedY = true;
				}
				stickMovedY = true;

				up.pressed = true;

				if (refreshStick)
				{
					refreshStickCounter += elapsed;
					if (refreshStickCounter >= refreshStickDelay)
					{
						refreshStickCounter = 0;
						stickJustMovedY = true;
					}
				}
				if (!upStickJumpDisabled)
				{
					if (stickJustMovedY)
					{
						up.justPressed = true;
					}
					if (stickJustReleaseY)
					{
						up.justReleased = true;
					}
				}
			}

			if (Math.abs(gamepad.analog.value.LEFT_STICK_X) < stickSensitivity)
			{
				stickMovedX = false;
			}
			if (Math.abs(gamepad.analog.value.LEFT_STICK_Y) < stickSensitivity)
			{
				stickMovedY = false;
			}

			left.released = !left.pressed;
			right.released = !right.pressed;
			up.released = !up.pressed;
			down.released = !down.pressed;
		}

		if (left.pressed)
			pressed |= FlxDirectionFlags.LEFT;
		if (right.pressed)
			pressed |= FlxDirectionFlags.RIGHT;
		if (up.pressed)
			pressed |= FlxDirectionFlags.UP;
		if (down.pressed)
			pressed |= FlxDirectionFlags.DOWN;
	}
}
