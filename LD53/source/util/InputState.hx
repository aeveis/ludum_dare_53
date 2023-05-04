package util;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

/**
 * Generalized class for input states
 * @author aeveis
 */
class InputState 
{
	public var name:String = "key name";
	public var keyMapping:Array<FlxKey>;
	public var gamepadMapping:Array<FlxGamepadInputID>;
	public var pressed:Bool = false;
	public var justPressed:Bool = false;
	public var justPressedDelayed:Bool = false;
	public var released:Bool = true;
	public var justReleased:Bool = false;
	private var delayedTotalFrames:Int = 15;
	private var delayedFrameCount:Int = 0;
	public var isGamepad:Bool = false;
	public var lastChangedIndex:Int = 0;
	public var lastChangedGamepadIndex:Int = 0;
	
	public function new() 
	{
		keyMapping = new Array<FlxKey>();
		gamepadMapping = new Array<FlxGamepadInputID>();
	}
	
	public function reset() {
		pressed = false;
		justPressed = false;
		released = true;
		justReleased = false;
	}
	
	public function update(elapsed:Float)
	{
		var prevPressed:Bool = pressed;
		reset();
		
		pressed = FlxG.keys.anyPressed(keyMapping);
		justPressed = FlxG.keys.anyJustPressed(keyMapping);
		justReleased = FlxG.keys.anyJustReleased(keyMapping);
		if (pressed)
		{
			if (!prevPressed && isGamepad)
			{
				Input.switchToKeyboard();
			}
			isGamepad = false;
		}
		
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			pressed = pressed || gamepad.anyPressed(gamepadMapping);
			justPressed = justPressed || gamepad.anyJustPressed(gamepadMapping);
			justReleased = justReleased || gamepad.anyJustReleased(gamepadMapping);
			if (gamepad.anyPressed(gamepadMapping))
			{
				if (!prevPressed && !isGamepad)
				{
					Input.switchToGamepad();
				}
				isGamepad = true;
			}
		}
		
		released = !pressed;
		
		if (justPressed)
		{
			justPressedDelayed = true;
			delayedFrameCount = delayedTotalFrames;
		}
		if (delayedFrameCount > 0)
		{
			delayedFrameCount--;
			if (delayedFrameCount <= 0)
			{
				justPressedDelayed = false;
			}
		}
	}
	
	public function addKeyInput(p_key:FlxKey):Int
	{
		if (keyMapping.indexOf(p_key) != -1) return Input.EXISTING_KEY;
		switch(p_key)
		{
			case 	FlxKey.BACKSLASH | FlxKey.BACKSPACE | 
					FlxKey.TAB | FlxKey.PAGEUP | FlxKey.PAGEDOWN |
					FlxKey.HOME | FlxKey.END | FlxKey.INSERT | FlxKey.MINUS |
					FlxKey.PLUS | FlxKey.DELETE | 
					FlxKey.CAPSLOCK | FlxKey.GRAVEACCENT | FlxKey.PRINTSCREEN | FlxKey.ZERO |
					FlxKey.F1 | FlxKey.F2 | FlxKey.F3 | FlxKey.F4 | FlxKey.F5 | FlxKey.F6 |
					FlxKey.F7 | FlxKey.F8 | FlxKey.F9 | FlxKey.F10 | FlxKey.F11 | FlxKey.F12:
					return Input.INVALID_KEY;
			default:
					for (key in keyMapping)
					{
						if (key == p_key)
						{
							return Input.EXISTING_KEY;
						}
					}
		} 
		keyMapping.push(p_key);
		return Input.REMAP_KEY;
	}
	public function removeKeyInput(p_key:FlxKey):Bool
	{
		return keyMapping.remove(p_key);
	}
	
	public function getFirstInputString():String
	{
		if (!isGamepad)
		{
			return keyMapping[0].toString();
		}
		else
		{
			return gamepadMapping[0].toString();
		}
	}
	
	public function addGamepadInput(p_gamepadKey:FlxGamepadInputID):Int
	{
		if (gamepadMapping.indexOf(p_gamepadKey) != -1) return Input.EXISTING_KEY;
		switch(p_gamepadKey)
		{
			case 	FlxGamepadInputID.GUIDE | FlxGamepadInputID.LEFT_ANALOG_STICK | 
					FlxGamepadInputID.RIGHT_ANALOG_STICK | FlxGamepadInputID.TILT_PITCH |
					FlxGamepadInputID.LEFT_STICK_DIGITAL_UP | FlxGamepadInputID.LEFT_STICK_DIGITAL_RIGHT |
					FlxGamepadInputID.LEFT_STICK_DIGITAL_DOWN | FlxGamepadInputID.LEFT_STICK_DIGITAL_LEFT |
					FlxGamepadInputID.TILT_ROLL:
					return Input.INVALID_KEY;
			default:
					for (key in gamepadMapping)
					{
						if (key == p_gamepadKey)
						{
							return Input.EXISTING_KEY;
						}
					}
		}
		gamepadMapping.push(p_gamepadKey);
		return Input.REMAP_KEY;
	}
	
	public function removeGamepadInput(p_gamepadKey:FlxGamepadInputID):Bool
	{
		return gamepadMapping.remove(p_gamepadKey);
	}
	
	public function clearBindings()
	{
		while (keyMapping.length > 0)
		{
			keyMapping.pop();
		}
		while (gamepadMapping.length > 0)
		{
			gamepadMapping.pop();
		}
	}
	
	public function setJustPressDelay(p_delay:Int = 15)
	{
		delayedTotalFrames = p_delay;
	}

	public function destroy()
	{
		keyMapping = null;
		gamepadMapping = null;
		
	}
	
}
