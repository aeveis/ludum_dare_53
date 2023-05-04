package ui;
import flixel.FlxSprite;

/**
 * ...
 * @author aeveis
 */
class Portrait extends FlxSprite
{

	public function new(?p_x:Float, ?p_y:Float) 
	{
		super(p_x, p_y);
	}
	
	public function addAnim(p_name:String, p_frames:Array<Int>, p_framerate:Float = 10)
	{
		animation.add(p_name, p_frames, p_framerate, true); 
	}
	
	public function playAnim(p_name:String)
	{
		animation.play(p_name);
	}
	
}