package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import global.G;
import util.Input;
import util.ui.TypeBitmapText;
import util.ui.UIBitmapText;
import util.ui.UIContainer.UILayout;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIContainer.UISize;
import util.ui.UIContainer;
import util.ui.UIImage;
import util.ui.UIList;
import util.ui.UIOption;
import util.ui.UIToggle;

/**
 * ...
 * @author aeveis
 */
class OptionsMenu extends UIImage
{
	public var optionsList:UIList;

	public var soundVolume:Float = 1;

	public function new()
	{
		super(AssetPaths.optionsMenuBG__png, UIPlacement.Center, UISize.Fill, UIPlacement.Top, UILayout.sides(2), UILayout.sides(4));
		nineSlice(UILayout.sides(2));

		optionsList = new UIList(UIPlacement.Inherit, UISize.XFill_YPercent(80), UIPlacement.Grid(2, 4), UILayout.sides(2), UILayout.sides(0));

		add(new UIBitmapText(UIPlacement.Inherit, "Options", 4));
		add(makeBar(0xffffefd7));

		optionsList.addOption(makeOption("Controls", UIPlacement.Grid(0, 0), UISize.Grid(1, 1)));
		optionsList.addOption(makeToggleOption("Timer", UIPlacement.Grid(1, 0), UISize.Grid(1, 1), toggleTimer, G.timerToggle));
		optionsList.addOption(makeToggleOption("Type Text", UIPlacement.Grid(0, 1), UISize.Grid(1, 1), toggleTyping, !TypeBitmapText.noTyping));
		optionsList.addOption(makeToggleOption("Anim Text", UIPlacement.Grid(1, 1), UISize.Grid(1, 1), toggleTextAnimation, !TypeBitmapText.noAnimation));

		optionsList.addOption(makeToggleOption("Music", UIPlacement.Grid(0, 2), UISize.Grid(1, 1), toggleMusic, G.musicToggle));
		optionsList.addOption(makeToggleOption("Sound", UIPlacement.Grid(1, 2), UISize.Grid(1, 1), toggleSound, G.soundToggle));

		optionsList.addOption(makeOption("Close", UIPlacement.Grid(0, 3), UISize.Grid(2, 1)));

		add(optionsList);

		optionsList.options[optionsList.focus].onFocus();
	}

	public function makeBar(?p_color:FlxColor):UIImage
	{
		if (p_color == null)
			p_color = FlxColor.WHITE;

		var bar = new UIImage(null, UIPlacement.Inherit, UISize.XFill(2));
		bar.bgSprite.color = p_color;

		return bar;
	}

	public function makeToggleOption(p_name:String, p_placement:UIPlacement, p_size:UISize, p_callback:Void->Void, p_toggled:Bool = true):UIOption
	{
		var option:UIOption = new UIOption(p_name, p_placement, p_size, UIPlacement.Justified, UILayout.sides(2), UILayout.horivert(8, 4));
		option.setLabelHeightOffset(5);
		option.setBG(AssetPaths.optionBG__png, 8, 8);
		option.nineSlice(UILayout.sides(2));
		option.addBGAnim("idle", [0]);
		option.addBGAnim("focus", [1]);

		option.setFocusCallback(function(p_focus) p_focus ? option.playBGAnim("focus") : option.playBGAnim("idle"));

		var toggle = new UIToggle(AssetPaths.toggleBG__png, AssetPaths.toggleCheck__png, UISize.Size(12, 12));
		if (!p_toggled)
			toggle.toggle();
		option.add(toggle);

		option.setSelectedCallback(function()
		{
			toggle.toggle();
			p_callback();
		});

		return option;
	}

	static public function makeOption(p_name:String, p_placement:UIPlacement, p_size:UISize, ?p_callback:Void->Void):UIOption
	{
		var option:UIOption = new UIOption(p_name, p_placement, p_size, UIPlacement.Center, UILayout.sides(2), UILayout.horivert(8, 4));
		option.setLabelHeightOffset(5);
		option.setBG(AssetPaths.optionBG__png, 8, 8);
		option.nineSlice(UILayout.sides(2));
		option.addBGAnim("idle", [0]);
		option.addBGAnim("focus", [1]);

		option.setFocusCallback(function(p_focus) p_focus ? option.playBGAnim("focus") : option.playBGAnim("idle"));
		if (p_callback != null)
		{
			option.setSelectedCallback(p_callback);
		}

		return option;
	}

	override public function update(elapsed:Float)
	{
		if (closedCheck() || global.G.waitForInput)
			return;
		super.update(elapsed);

		if (Input.control.down.justPressed)
		{
			switch (optionsList.focus)
			{
				case 0:
					optionsList.setFocus(2);
				case 1:
					optionsList.setFocus(3);
				case 2:
					optionsList.setFocus(4);
				case 3:
					optionsList.setFocus(5);
				case 4:
					optionsList.setFocus(6);
				default:
					optionsList.nextOption();
			}
		}
		else if (Input.control.up.justPressed)
		{
			switch (optionsList.focus)
			{
				case 1:
					optionsList.setFocus(6);
				case 2:
					optionsList.setFocus(0);
				case 3:
					optionsList.setFocus(1);
				case 4:
					optionsList.setFocus(2);
				case 5:
					optionsList.setFocus(3);
				default:
					optionsList.prevOption();
			}
		}

		if (Input.control.right.justPressed)
		{
			switch (optionsList.focus)
			{
				case 0:
					optionsList.setFocus(1);
				case 2:
					optionsList.setFocus(3);
				case 4:
					optionsList.setFocus(5);
			}
		}
		if (Input.control.left.justPressed)
		{
			switch (optionsList.focus)
			{
				case 1:
					optionsList.setFocus(0);
				case 3:
					optionsList.setFocus(2);
				case 5:
					optionsList.setFocus(4);
			}
		}

		if (Input.control.keys.get("select").justPressed)
		{
			optionsList.onSelected();
		}
	}

	public function toggleMusic()
	{
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.pause();
			G.musicToggle = false;
		}
		else
		{
			FlxG.sound.music.play();
			G.musicToggle = true;
		}
	}

	public function toggleSound()
	{
		G.soundToggle = !G.soundToggle;
		if (G.soundToggle)
		{
			FlxG.sound.defaultSoundGroup.volume = soundVolume;
		}
		else
		{
			soundVolume = FlxG.sound.defaultSoundGroup.volume;
			FlxG.sound.defaultSoundGroup.volume = 0;
		}
	}

	public function toggleTimer()
	{
		G.timerToggle = !G.timerToggle;
	}

	public function toggleTyping()
	{
		TypeBitmapText.noTyping = !TypeBitmapText.noTyping;
	}

	public function toggleTextAnimation()
	{
		TypeBitmapText.noAnimation = !TypeBitmapText.noAnimation;
	}
}
