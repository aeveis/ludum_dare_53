package util.ui;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import util.ui.UIContainer;
import util.ui.UIImage;

/**
 * ...
 * @author aeveis
 */
class UIToggle extends UIImage
{

	public var toggleSprite:FlxSprite;
	public var toggled:Bool = true;
	public var callback:Bool->Void;
	
	public function new(p_bgImage:FlxGraphicAsset, p_toggleImage:FlxGraphicAsset, p_size:UISize = UISize.Fill) 
	{
		super(p_bgImage, UIPlacement.Inherit, p_size, UIPlacement.Center);
		
		toggleSprite = new FlxSprite(p_toggleImage);
		add(toggleSprite);
	}
	
	public function setToggleCallback(p_callback:Bool -> Void)
	{
		callback = p_callback;
	}
	
	public function toggle()
	{
		toggleSprite.visible = !toggleSprite.visible;
		toggled = toggleSprite.visible;
		
		if (callback == null) return;
		callback(toggleSprite.visible);
	}
	
}