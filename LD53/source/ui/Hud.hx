package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIText;

/**
 * ...
 * @author aeveis
 */
class Hud extends FlxGroup
{
	public var boxHealth:FlxSprite;
	public var healthBar:FlxSprite;
	public var parcelHealth(get, null):Float;

	public var tapeCounter:UIText;
	public var tapeCount(get, set):String;

	function get_tapeCount():String
	{
		return tapeCounter.text;
	}

	function set_tapeCount(value:String):String
	{
		tapeCounter.text = value;
		return tapeCounter.text;
	}

	function get_parcelHealth():Float
	{
		return healthBar.scale.y;
	}

	public function new()
	{
		super();

		boxHealth = new FlxSprite(4, 24, AssetPaths.boxhealth__png);
		boxHealth.scrollFactor.set(0, 0);

		healthBar = new FlxSprite(8, 47);
		healthBar.scrollFactor.set(0, 0);
		healthBar.makeGraphic(4, 58, FlxColor.GREEN);
		healthBar.origin.y = 58;

		add(boxHealth);
		add(healthBar);

		var textZoomRatio = 4.0;
		var countCam:FlxCamera = new FlxCamera(5, 25, Math.floor(10 * textZoomRatio), Math.floor(10 * textZoomRatio), 1.0 / textZoomRatio);
		countCam.bgColor = 0;

		tapeCounter = new UIText("0");
		tapeCounter.setAlignment(FlxTextAlign.CENTER);
		tapeCounter.setPlacement(UIPlacement.Pos(0, 0.5));
		tapeCounter.scrollFactor.set(0, 0);
		tapeCounter.setParent(UIParent.Camera(countCam));
		tapeCounter.setMaxWidth(countCam.width);
		tapeCounter.textSprite.cameras = [countCam];
		add(tapeCounter);
		FlxG.cameras.add(countCam);
	}

	public function addHealth(amount:Float)
	{
		healthBar.scale.y += amount;
		if (healthBar.scale.y < 0)
		{
			healthBar.scale.y = 0;
		}
		if (healthBar.scale.y > 1.0)
		{
			healthBar.scale.y = 1.0;
		}
	}

	override function destroy()
	{
		super.destroy();
	}
}
