package ui;

import flixel.FlxSprite;
import util.ui.UIBitmapText;
import util.ui.UIContainer;

/**
 * ...
 * @author aeveis
 */
class Timer extends UIContainer
{
	var timeText:UIBitmapText;
	var count:Float = 0;
	var start:Bool = false;

	public function new()
	{
		super(UIPlacement.TopLeft, UISize.Size(130, 20), UIPlacement.Left, UILayout.sides(1), UILayout.sides(2));
		scrollFactor.set(0, 0);

		add(new FlxSprite(0, 0, AssetPaths.timer__png));

		timeText = new UIBitmapText(UIPlacement.Inherit, "00:00", 5);
		add(timeText);
	}

	public function startTimer(resetTimer:Bool = true)
	{
		if (resetTimer)
		{
			count = 0;
		}
		start = true;
	}

	public function stopTimer()
	{
		start = false;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (start)
		{
			count += elapsed;

			var timeString = "";

			var min = Math.floor(count / 60.0);

			if (min < 10)
			{
				timeString += "0";
			}
			timeString += min + ":";

			var sec = Math.floor(count % 60.0);
			if (sec < 10)
			{
				timeString += "0";
			}
			timeString += sec;
			timeText.text = timeString;
			refresh(true);
		}
	}
}
