package util.ui;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIContainer.UISize;

/**
 * Text class to handle specific text settings for UI
 * Uses set FlxBitmapText for now
 * @author aeveis
 */
class UIBitmapText extends UIContainer
{
	var bitmapText:FlxBitmapText;

	public var heightOffset:Float = 0;

	public var text(default, set):String = "";

	function set_text(p_text:String):String
	{
		bitmapText.text = p_text;
		setSizeToText();
		return text = p_text;
	}

	public function new(p_align:UIPlacement = UIPlacement.Inherit, ?p_text:String, p_heightOffset:Float = 0)
	{
		super(UIPlacement.Inherit, UISize.Fill, p_align);

		setBitmapFont();
		add(bitmapText);
		if (p_text != null)
			text = p_text;

		heightOffset = p_heightOffset;
		setSizeToText();
	}

	public function setColor(p_color:FlxColor)
	{
		bitmapText.color = p_color;
	}

	public function setSizeToText()
	{
		size = UISize.Size(bitmapText.width * bitmapText.scale.x, (bitmapText.height - heightOffset) * bitmapText.scale.y);
		refresh(true);
	}

	public function setBitmapFont(?font:FlxBitmapFont)
	{
		if (font == null)
		{
			font = FlxBitmapFont.fromAngelCode(AssetPaths.Easyable_0__png, AssetPaths.Easyable__fnt);
		}
		bitmapText = new FlxBitmapText(font);
		bitmapText.text = "";
	}
}
