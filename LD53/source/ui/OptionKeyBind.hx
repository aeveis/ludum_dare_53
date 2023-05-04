package ui;

import flixel.FlxSprite;
import util.Input;
import util.InputState;
import util.ui.UIBitmapText;
import util.ui.UIContainer.Box;
import util.ui.UIContainer.UILayout;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIContainer.UISize;
import util.ui.UIImage;
import util.ui.UIKeyBind;
import util.ui.UIOption;

/**
 * Specific UI Option for displaying key binds
 * Dependancy on Input
 * @author aeveis
 */
class OptionKeyBind extends UIOption
{
	public var input:InputState;
	public var inputKey:UIBitmapText;
	public var border:UIImage;
	public var isGamepad:Bool = false;

	public function new(p_input:InputState, p_name:String, p_placement:UIPlacement, p_size:UISize, ?p_childPlacement:UIPlacement, ?p_padding:Box,
			?p_margin:Box)
	{
		super(p_name, p_placement, p_size, p_childPlacement, p_padding, p_margin);
		input = p_input;
		nameLabel.setPlacement(UIPlacement.Left);

		border = new UIImage(null, UIPlacement.Right, UISize.Fill, UIPlacement.Center);
		border.setBG(AssetPaths.keyBG__png, 8, 8);
		border.addBGAnim("idle", [0]);
		border.playBGAnim("idle");
		border.nineSlice(UILayout.sides(2));
		inputKey = new UIBitmapText(UIPlacement.Inherit, "", 5);
		refreshKeyDisplay();

		border.add(inputKey);
		add(border);
	}

	public function refreshKeyDisplay()
	{
		var keyString:String = "";
		if (!isGamepad)
		{
			keyString += Input.getInputString(input.keyMapping[input.lastChangedIndex]);
		}
		else
		{
			keyString += Input.getGamepadInputString(input.gamepadMapping[input.lastChangedGamepadIndex]);
		}
		inputKey.text = keyString;
		inputKey.setPlacement(UIPlacement.Center);
		border.setSize(UISize.Size(inputKey.width, inputKey.height + 4));
		refresh(true);
	}
}
