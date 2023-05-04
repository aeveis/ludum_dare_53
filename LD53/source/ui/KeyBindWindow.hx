package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import global.G;
import util.Input;
import util.InputState;
import util.ui.UIBitmapText;
import util.ui.UIContainer.UILayout;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIContainer.UISize;
import util.ui.UIContainer;
import util.ui.UIImage;
import util.ui.UIList;
import util.ui.UIOption;

/**
 * ...
 * @author aeveis
 */
class KeyBindWindow extends UIImage
{
	public var header:UIBitmapText;
	public var infoLabel:UIBitmapText;
	public var keysPanel:UIOption;
	public var gamepadPanel:UIOption;
	public var optionsList:UIList;
	public var keyList:UIList;
	public var gamepadList:UIList;

	private var input:InputState;
	private var isKey:Bool = true;
	private var toRemoveKey:Int = -1;

	public function new()
	{
		super(AssetPaths.optionsMenuBG__png, UIPlacement.Center, UISize.Fill, UIPlacement.Top, UILayout.sides(2), UILayout.sides(4));
		nineSlice(UILayout.sides(2));

		header = new UIBitmapText("Key", 4);
		add(header);
		add(makeBar(0xffffefd7));
		optionsList = new UIList(UIPlacement.Inherit, UISize.XFill_YPercent(80), UIPlacement.Grid(2, 4), UILayout.sides(2), UILayout.sides(0));

		keysPanel = makeOption("Keys", UIPlacement.Grid(0, 0), UISize.Grid(2, 1), UIPlacement.Left, selectKey);
		keysPanel.add(new FlxSprite(0, 0, AssetPaths.keyIcon__png));
		keyList = new UIList(UIPlacement.Right, UISize.XShrink(22), UIPlacement.Left, UILayout.sides(2));
		keysPanel.add(keyList);
		optionsList.addOption(keysPanel);

		gamepadPanel = makeOption("Gamepad", UIPlacement.Grid(0, 1), UISize.Grid(2, 1), UIPlacement.Left, selectGamepad);
		gamepadPanel.add(new FlxSprite(0, 0, AssetPaths.gamepadIcon__png));
		gamepadList = new UIList(UIPlacement.Right, UISize.XShrink(22), UIPlacement.Left, UILayout.sides(2));
		gamepadPanel.add(gamepadList);
		optionsList.addOption(gamepadPanel);

		infoLabel = new UIBitmapText(UIPlacement.Grid(0, 2), "", 4);
		optionsList.add(infoLabel);
		setInfoText();
		// optionsList.addOption(makeOption("Add Binding", UIPlacement.Grid(0, 2), UISize.Grid(2, 1), UIPlacement.Center));
		optionsList.addOption(makeOption("Back", UIPlacement.Grid(0, 3), UISize.Grid(2, 1), UIPlacement.Center));

		add(optionsList);
		optionsList.options[optionsList.focus].onFocus();
	}

	public function updateInput(p_input:InputState, p_name:String)
	{
		input = p_input;
		header.text = p_name;
		keyList.clearOptions();
		gamepadList.clearOptions();

		updateBindings();
	}

	public function setInfoText(?p_text:String)
	{
		if (p_text == null)
		{
			p_text = "Press [" + Input.control.getFirstInputString("select") + "] to remap key";
		}
		infoLabel.text = p_text;
		infoLabel.setPlacement(UIPlacement.Grid(0, 2));
		infoLabel.setSize(UISize.Grid(2, 1));
		infoLabel.setChildPlacement(UIPlacement.Center);
		refresh(true);
	}

	public function updateBindings()
	{
		for (i in 0...input.keyMapping.length)
		{
			var key = input.keyMapping[i];
			var option = makeKeyOption(key, UIPlacement.Inherit, UISize.Fill, UIPlacement.Center);
			option.setSize(UISize.Size(option.nameLabel.width + 2, option.nameLabel.height + 4));

			keyList.addOption(option);
		}
		for (i in 0...input.gamepadMapping.length)
		{
			var key = input.gamepadMapping[i];
			var option = makeGamepadOption(key, UIPlacement.Inherit, UISize.Fill, UIPlacement.Center);
			option.setSize(UISize.Size(option.nameLabel.width + 2, option.nameLabel.height + 4));
			gamepadList.addOption(option);
		}
		keyList.setFocus();
		gamepadList.setFocus();

		refresh(true);
	}

	public function makeBar(?p_color:FlxColor):UIImage
	{
		if (p_color == null)
			p_color = FlxColor.WHITE;

		var bar = new UIImage(null, UIPlacement.Inherit, UISize.XFill(2));
		bar.bgSprite.color = p_color;

		return bar;
	}

	public function makeOption(p_name:String, p_placement:UIPlacement, p_size:UISize, p_childPlacement:UIPlacement, ?p_callback:Void->Void):UIOption
	{
		var option:UIOption = new UIOption(p_name, p_placement, p_size, p_childPlacement, UILayout.sides(2), UILayout.box(2, 0, 2, 2));
		option.setLabelHeightOffset(4);
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

	public function makeKeyOption(p_key:FlxKey, p_placement:UIPlacement, p_size:UISize, p_childPlacement:UIPlacement):UIOption
	{
		var option:UIOption = new UIOption(Input.getInputString(p_key), p_placement, p_size, p_childPlacement, UILayout.sides(0), UILayout.vert(2));
		option.setLabelHeightOffset(5);
		option.setBG(AssetPaths.keyBG__png, 8, 8);
		option.nineSlice(UILayout.sides(2));
		option.addBGAnim("idle", [0]);
		option.addBGAnim("focus", [1]);

		option.setFocusCallback(function(p_focus) p_focus ? option.playBGAnim("focus") : option.playBGAnim("idle"));

		option.setSelectedCallback(function()
		{
			option.nameLabel.text = "...";
			keysPanel.refresh(true);
			toRemoveKey = p_key;
			global.G.waitForInput = true;
			isKey = true;
		});

		return option;
	}

	public function makeGamepadOption(p_gamepad:FlxGamepadInputID, p_placement:UIPlacement, p_size:UISize, p_childPlacement:UIPlacement):UIOption
	{
		var option:UIOption = new UIOption(Input.getGamepadInputString(p_gamepad), p_placement, p_size, p_childPlacement, UILayout.sides(0), UILayout.vert(2));
		option.setLabelHeightOffset(5);
		option.setBG(AssetPaths.keyBG__png, 8, 8);
		option.nineSlice(UILayout.sides(2));
		option.addBGAnim("idle", [0]);
		option.addBGAnim("focus", [1]);

		option.setFocusCallback(function(p_focus) p_focus ? option.playBGAnim("focus") : option.playBGAnim("idle"));

		option.setSelectedCallback(function()
		{
			option.nameLabel.text = "...";
			gamepadPanel.refresh(true);
			toRemoveKey = p_gamepad;
			global.G.waitForInput = true;
			isKey = false;
		});

		return option;
	}

	public function setFocus()
	{
		optionsList.setFocus();
	}

	public function selectKey()
	{
		keyList.options[keyList.focus].selected();
	}

	public function selectGamepad()
	{
		gamepadList.options[gamepadList.focus].selected();
	}

	override public function update(elapsed:Float)
	{
		if (closedCheck())
			return;
		super.update(elapsed);
		if (global.G.waitForInput)
		{
			var key = FlxG.keys.firstJustPressed();
			var gamepad = FlxG.gamepads.lastActive;
			var gamepadKey = -1;
			if (gamepad != null)
			{
				gamepadKey = gamepad.firstJustPressedID();
			}
			if (key != -1 && isKey)
			{
				keyList.removeOption(keyList.focus);
				var inputResult = Input.control.replaceInputKeyMap(input, toRemoveKey, key);
				switch (inputResult)
				{
					case Input.INVALID_KEY:
						setInfoText("Invalid Key to Map");
						key = toRemoveKey;
					case Input.SAME_KEY:
						setInfoText("Key Already Mapped");
					case Input.EXISTING_KEY:
						setInfoText("Key is used in [" + Input.control.existingKey + "]");
						key = toRemoveKey;
					case Input.REMAP_KEY:
						var keyName:FlxKey = cast key;
						setInfoText("Key Set to [" + Input.getInputString(keyName) + "]");
						input.lastChangedIndex = input.keyMapping.length - 1;
				}
				var option = makeKeyOption(key, UIPlacement.Inherit, UISize.Fill, UIPlacement.Center);
				option.setSize(UISize.Size(option.nameLabel.width + 2, option.nameLabel.height + 4));
				keyList.addOption(option);
				keyList.setFocus(keyList.options.length - 1);
				refresh(true);
				global.G.waitForInput = false;
				return;
			}
			else if (Input.checkValidGamepadInputs(gamepadKey) && !isKey)
			{
				gamepadList.removeOption(gamepadList.focus);
				var inputResult = Input.control.replaceInputGamepadMap(input, toRemoveKey, gamepadKey);
				switch (inputResult)
				{
					case Input.INVALID_KEY:
						setInfoText("Invalid Key to Map");
						key = toRemoveKey;
					case Input.SAME_KEY:
						setInfoText("Key Already Mapped");
					case Input.EXISTING_KEY:
						setInfoText("Key is used in [" + Input.control.existingKey + "]");
						key = toRemoveKey;
					case Input.REMAP_KEY:
						var keyName:FlxGamepadInputID = cast gamepadKey;
						setInfoText("Key Set to [" + Input.getGamepadInputString(keyName) + "]");
						input.lastChangedGamepadIndex = input.gamepadMapping.length - 1;
				}
				var option = makeGamepadOption(gamepadKey, UIPlacement.Inherit, UISize.Fill, UIPlacement.Center);
				option.setSize(UISize.Size(option.nameLabel.width + 2, option.nameLabel.height + 4));
				gamepadList.addOption(option);
				gamepadList.setFocus(gamepadList.options.length - 1);
				refresh(true);
				global.G.waitForInput = false;
				return;
			}
			else if (key == -1 && isKey && Input.checkValidGamepadInputs(gamepadKey))
			{
				keyList.options[keyList.focus].nameLabel.text = Input.getInputString(toRemoveKey);
				keysPanel.refresh(true);
				setInfoText("Remap with Keyboard");
				global.G.waitForInput = false;
			}
			else if (!Input.checkValidGamepadInputs(gamepadKey) && !isKey && key != -1)
			{
				var keyString:String = Input.getGamepadInputString(toRemoveKey);
				var index = keyString.indexOf("RIGHT_STICK_DIGITAL");
				if (index != -1)
				{
					keyString = "RSD" + keyString.substring(index + 19, keyString.length);
				}
				gamepadList.options[gamepadList.focus].nameLabel.text = keyString;
				gamepadPanel.refresh(true);
				setInfoText("Remap with Gamepad");
				global.G.waitForInput = false;
			}
			else
			{
				return;
			}
		}

		var list:UIList = null;
		if (keysPanel.focused)
			list = keyList;
		else if (gamepadPanel.focused)
			list = gamepadList;
		else
			return;

		if (Input.control.left.justPressed)
		{
			list.nextOption();
			setInfoText();
		}
		if (Input.control.right.justPressed)
		{
			list.prevOption();
			setInfoText();
		}
		if (Input.control.up.justPressed || Input.control.down.justPressed)
		{
			setInfoText();
		}
	}
}
