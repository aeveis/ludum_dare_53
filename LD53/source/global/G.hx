package global;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.sound.FlxSound;
import haxe.ds.Map;

/**
 * ...
 * @author aeveis
 */
class G
{
	public static var level:Int = 0;
	public static var maxLevel:Int = 0;

	public static function nextLevel()
	{
		level++;
		if (level > maxLevel)
		{
			level = maxLevel;
		}
		if (G.level == maxLevel)
		{
			// PlayState.instance.ui.winText.visible = true;
		}
	}

	public static function prevLevel()
	{
		level--;
		if (level < 0)
		{
			level = 0;
		}
	}

	static public var startInput:Bool = false;

	public static var musicToggle:Bool = true;
	public static var soundToggle:Bool = true;
	public static var waitForInput:Bool = false;
	public static var timerToggle(default, set):Bool = false;

	static function set_timerToggle(val:Bool):Bool
	{
		if (PlayState.instance != null)
		{
			// PlayState.instance.timer.visible = val;
		}
		return timerToggle = val;
	}

	public static function dist(obj0:FlxSprite, obj1:FlxSprite):Float
	{
		return Math.sqrt((obj0.x - obj1.x) * (obj0.x - obj1.x) + (obj0.y - obj1.y) * (obj0.y - obj1.y));
	}

	public static var soundPlaying:Map<String, Bool> = null;

	public static function playSound(pname:String, random:Int = 0, volume:Float = 1, waitToPlay:Bool = false)
	{
		if (soundPlaying == null)
		{
			soundPlaying = new Map<String, Bool>();
		}

		if (!soundPlaying.get(pname) || !waitToPlay)
		{
			if (random > 0)
			{
				FlxG.sound.play(pname + FlxG.random.int(0, random), volume, false, null, false, () -> soundComplete(pname));
			}
			else
			{
				FlxG.sound.play(pname, volume, false, null, false, () -> soundComplete(pname));
			}
		}
		soundPlaying.set(pname, true);
	}

	public static function soundComplete(pname:String)
	{
		soundPlaying.set(pname, false);
	}

	public static function loadLoopedSound(pname:String, volume:Float = 1):FlxSound
	{
		var sound:FlxSound = new FlxSound();
		sound.loadEmbedded(pname, true);
		sound.play();
		sound.pause();
		FlxG.sound.defaultSoundGroup.add(sound);
		return sound;
	}
}
