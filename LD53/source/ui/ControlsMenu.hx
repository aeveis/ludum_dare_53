package ui;
import flixel.FlxG;
import flixel.FlxSprite;
import global.G;
import util.Input;
import util.InputState;
import util.ui.UIContainer;
import util.ui.UIImage;
import util.ui.UIList;
import util.ui.UIOption;
import util.ui.UIToggle;

/**
 * ...
 * @author aeveis
 */
class ControlsMenu extends UIContainer 
{
	public var controlPanel:UIImage;
	public var keysPanel:UIImage;
	public var controlOptions:UIList;
	public var keyBindings:UIList;
	public var keyWindow:KeyBindWindow;
	public var gamepadOption:UIOption;
	
	public var currentWindow:UIList;
	
	public function new() 
	{
		super(UIPlacement.Center, UISize.Fill, UIPlacement.Inherit);
		
		controlPanel = new UIImage(AssetPaths.optionsMenuBG__png, UIPlacement.Center, UISize.Fill, UIPlacement.Inherit);
		controlPanel.nineSlice(UILayout.sides(2));
		
		controlOptions = new UIList(UIPlacement.Center, UISize.Fill, UIPlacement.Top, UILayout.sides(2), UILayout.sides(4));
		controlOptions.addOption(makeOption("Key Mappings", openKeybindings));
		controlOptions.addOption(makeOption("Use Key Defaults", resetKeybindings));
		controlOptions.addOption(makeOption("Back"));
		controlOptions.options[controlOptions.focus].onFocus();
		
		keysPanel = new UIImage(AssetPaths.optionsMenuBG__png, UIPlacement.Center, UISize.Fill, UIPlacement.Inherit);
		keysPanel.nineSlice(UILayout.sides(2));
		
		keyBindings = new UIList(UIPlacement.Center, UISize.Fill, UIPlacement.Grid(4, 5), UILayout.sides(2), UILayout.sides(2));
		
		keyBindings.addOption(makeKeyBindOption(Input.control.left, 				"Left", 	UIPlacement.Grid(0, 0), UISize.Grid(2, 1)));
		keyBindings.addOption(makeKeyBindOption(Input.control.right, 				"Right", 	UIPlacement.Grid(0, 1), UISize.Grid(2, 1)));
		keyBindings.addOption(makeKeyBindOption(Input.control.up, 					"Up", 		UIPlacement.Grid(0, 2), UISize.Grid(2, 1)));
		keyBindings.addOption(makeKeyBindOption(Input.control.down, 				"Down", 	UIPlacement.Grid(0, 3), UISize.Grid(2, 1)));
		
		keyBindings.addOption(makeGamepadToggleOption(UIPlacement.Grid(0, 4), UISize.Grid(1, 1)));
		
		keyBindings.addOption(makeKeyBindOption(Input.control.keys.get("select"), 	"Select", 	UIPlacement.Grid(2, 0), UISize.Grid(2, 1)));
		keyBindings.addOption(makeKeyBindOption(Input.control.keys.get("undo"), 	"Undo", 	UIPlacement.Grid(2, 1), UISize.Grid(2, 1)));
		keyBindings.addOption(makeKeyBindOption(Input.control.keys.get("restart"), 	"Restart", 	UIPlacement.Grid(2, 2), UISize.Grid(2, 1)));
		keyBindings.addOption(makeKeyBindOption(Input.control.keys.get("pause"), 	"Pause", 	UIPlacement.Grid(2, 3), UISize.Grid(2, 1)));
		
		keyBindings.addOption(makeOption("Back", UIPlacement.Grid(1, 4), UISize.Grid(3, 1), openControlOptions));
		keyBindings.options[keyBindings.focus].onFocus();
		
		controlPanel.add(controlOptions);
		keysPanel.add(keyBindings);
		
		keyWindow = new KeyBindWindow();
		keyWindow.optionsList.setOptionCallbackByName("Back", openKeybindings);
		
		add(controlPanel);
		add(keysPanel);
		add(keyWindow);
		
		openControlOptions();
	}
	
	
	public function makeToggleOption(p_name:String, p_callback:Void->Void, p_toggled:Bool = true):UIOption
	{
		var option:UIOption = new UIOption(p_name, UIPlacement.Inherit, UISize.XFill(20), UIPlacement.Justified, UILayout.sides(2), UILayout.horivert(8, 4));
		option.setLabelHeightOffset(5);
		option.setBG(AssetPaths.optionBG__png, 8, 8);
		option.nineSlice(UILayout.sides(2));
		option.addBGAnim("idle", [0]); 
		option.addBGAnim("focus", [1]);
		
		option.setFocusCallback(function(p_focus) p_focus ? option.playBGAnim("focus") : option.playBGAnim("idle"));
		
		var toggle = new UIToggle(AssetPaths.toggleBG__png, AssetPaths.toggleCheck__png, UISize.Size(12, 12));
		if (!p_toggled) toggle.toggle();
		option.add(toggle);
		
		option.setSelectedCallback(
		function()
		{
			toggle.toggle();
			p_callback();
		});
		
		
		return option;
	}
	
	public function makeOption(p_name:String, ?p_placement:UIPlacement, ?p_size:UISize, ?p_callback:Void->Void):UIOption
	{
		if (p_placement == null) 	p_placement = UIPlacement.Inherit;
		if (p_size == null) 		p_size = UISize.XFill(20);
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
	
	public function makeGamepadToggleOption(?p_placement:UIPlacement, ?p_size:UISize):UIOption
	{
		gamepadOption = new UIOption("", p_placement, p_size, UIPlacement.Center, UILayout.sides(2), UILayout.horivert(8, 4));
		gamepadOption.remove(gamepadOption.nameLabel, true);
		gamepadOption.nameLabel = null;
		gamepadOption.setBG(AssetPaths.optionBG__png, 8, 8);
		gamepadOption.nineSlice(UILayout.sides(2));
		gamepadOption.addBGAnim("idle", [0]);
		gamepadOption.addBGAnim("focus", [1]);
		
		var gameIcon = new FlxSprite(0, 0, AssetPaths.gamepadIcon__png);
		gamepadOption.add(gameIcon);
		
		gamepadOption.setFocusCallback(function(p_focus) p_focus ? gamepadOption.playBGAnim("focus") : gamepadOption.playBGAnim("idle"));
	
		gamepadOption.setSelectedCallback(function()
		{
			for (o in keyBindings.options)
			{
				if (Std.isOfType(o, OptionKeyBind))
				{
					var option:OptionKeyBind = cast o;
					option.isGamepad = !option.isGamepad;
					if (option.isGamepad)
					{
						gameIcon.loadGraphic(AssetPaths.keyIcon__png);
					}
					else
					{
						gameIcon.loadGraphic(AssetPaths.gamepadIcon__png);
					}
					option.refreshKeyDisplay();
				}
			}
		});
	
		
		return gamepadOption;
	}
	
	public function makeKeyBindOption(p_input:InputState, p_name:String, p_placement:UIPlacement, p_size:UISize):UIOption
	{
		var option:OptionKeyBind = new OptionKeyBind(p_input, p_name, p_placement, p_size, UIPlacement.Right, UILayout.sides(2));
		option.setLabelHeightOffset(5);
		option.setBG(AssetPaths.optionBG__png, 8, 8);
		option.nineSlice(UILayout.sides(2));
		option.addBGAnim("idle", [0]);
		option.addBGAnim("focus", [1]);
		
		option.setFocusCallback(function(p_focus) p_focus ? option.playBGAnim("focus") : option.playBGAnim("idle"));
		
		option.setSelectedCallback(
		function()
		{
			keyWindow.updateInput(p_input, p_name);
			openKeyWindow();
		});
		
		
		return option;
	}
	
	override public function open()
	{
		super.open();
		if (opened)
		{
			openControlOptions();
			controlOptions.setFocus();
		}
	}
	
	override public function close()
	{
		openControlOptions();
		controlOptions.setFocus();
		super.close();
	}
	
	public function openControlOptions()
	{
		currentWindow = controlOptions;
		keysPanel.close();
		keyWindow.close();
		keyBindings.setFocus();
		controlPanel.open();
	}
	
	public function openKeybindings()
	{
		currentWindow = keyBindings;
		controlPanel.close();
		keyWindow.close();
		keyWindow.setFocus();
		for (key in keyBindings.options)
		{
			if (Std.isOfType(key, OptionKeyBind))
			{
				var option:OptionKeyBind = cast key; 
				option.refreshKeyDisplay();
			}
		}
		keysPanel.open();
	}
	
	public function openKeyWindow()
	{
		currentWindow = keyWindow.optionsList;
		keysPanel.close();
		controlPanel.close();
		keyWindow.open();
	}
	
	public function resetKeybindings()
	{
		Input.control.removeAllBindings();
		Input.control.topdownSetup();
		keyBindings.refresh(true);
	}
	
	override public function update(elapsed:Float)
	{
		if (closedCheck()) return;
		super.update(elapsed);
		
		if (global.G.waitForInput) return;
		
		if (currentWindow == null) return;
		
		var gamepad = FlxG.gamepads.lastActive;
		var gamepadKey = -1;
		if (gamepad != null)
		{
			gamepadKey = gamepad.firstJustPressedID();
			if (Input.control.keys.get("undo").justPressed)
			{
				if (currentWindow == keyBindings)
				{
					openControlOptions();
				}
				else if (currentWindow == keyWindow.optionsList)
				{
					openKeybindings();
				}
			}
		}
		
		if (currentWindow != keyBindings)
		{
			if (Input.control.down.justPressed)
			{
				currentWindow.nextOption();
				
			}
			else if (Input.control.up.justPressed)
			{
				currentWindow.prevOption();
			}
		}
		else
		{
			if (Input.control.down.justPressed)
			{
				switch(currentWindow.focus)
				{
					case 4:
						currentWindow.setFocus(0);
					case 9:
						currentWindow.setFocus(5);
					default:
						currentWindow.nextOption();
				}
			}
			else if (Input.control.up.justPressed)
			{
				switch(currentWindow.focus)
				{
					case 0:
						currentWindow.setFocus(4);
					case 5:
						currentWindow.setFocus(9);
					default:
						currentWindow.prevOption();
				}
			}
			
			if (Input.control.right.justPressed)
			{
				switch(currentWindow.focus)
				{
					case 0:
						currentWindow.setFocus(5);
					case 1:
						currentWindow.setFocus(6);
					case 2:
						currentWindow.setFocus(7);
					case 3:
						currentWindow.setFocus(8);
					case 4:
						currentWindow.setFocus(9);
				}
			}
			if (Input.control.left.justPressed)
			{
				switch(currentWindow.focus)
				{
					case 5:
						currentWindow.setFocus(0);
					case 6:
						currentWindow.setFocus(1);
					case 7:
						currentWindow.setFocus(2);
					case 8:
						currentWindow.setFocus(3);
					case 9:
						currentWindow.setFocus(4);
				}
			}
		}
		if (Input.control.keys.get("select").justPressed)
		{
			currentWindow.onSelected();
		}
	}

}