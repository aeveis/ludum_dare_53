package util;

/**
 * ...
 * @author aeveis
 */
class TimedBool
{
	public var delay:Float;
	public var delay_timer:Float = 0;
	public var hard:Bool = false;
	public var soft(get, null):Bool;

	function get_soft()
	{
		return delay_timer > 0;
	}

	public function new(Delay:Float)
	{
		delay = Delay;
	}

	public function update(elapsed:Float)
	{
		if (hard)
		{
			delay_timer = delay;
		}
		else if (delay_timer > 0)
		{
			delay_timer -= elapsed;
		}
	}

	public function trigger()
	{
		delay_timer = delay;
	}

	public function reset()
	{
		delay_timer = 0;
	}

	public function setDelay(p_delay:Float)
	{
		delay = p_delay;
	}
}
