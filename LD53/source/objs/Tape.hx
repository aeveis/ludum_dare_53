package objs;

import flixel.FlxSprite;

/**
 * ...
 * @author aeveis
 */
class Tape extends FlxSprite
{
	public function new(px:Float, py:Float)
	{
		super(px, py, AssetPaths.tape__png);
	}
}
