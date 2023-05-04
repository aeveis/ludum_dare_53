package ui;
import flixel.FlxG;
import global.G;
import util.Input;
import util.ui.UIContainer;

/**
 * ...
 * @author ...
 */
class PauseMenu extends UIContainer
{
	public var options:OptionsMenu;
	public var controls:ControlsMenu;
	
	public function new() 
	{
		super(UIPlacement.Center, UISize.Percent(80, 70), UIPlacement.Inherit, UILayout.sides(2), UILayout.zeroBox, UIParent.Camera(PlayState.instance.gameCam));
		scrollFactor.set(0, 0);
		
		options = new OptionsMenu();
		options.optionsList.setOptionCallbackByName("Close", close);
		options.optionsList.setOptionCallbackByName("Controls", openControls);
		
		controls = new ControlsMenu();
		controls.controlOptions.setOptionCallbackByName("Back", closeControls);
		
		controls.close();
		
		add(options);
		add(controls);
	}
	
	override public function update(elapsed:Float)
	{
		if (closedCheck()) return;
		super.update(elapsed);
		
		if (global.G.waitForInput) return;
		
		var gamepad = FlxG.gamepads.lastActive;
		var gamepadKey = -1;
		if (gamepad != null)
		{
			gamepadKey = gamepad.firstJustPressedID();
			if (Input.control.keys.get("undo").justPressed)
			{
				if (controls.opened)
				{
					closeControls();
				}
				else if (options.opened)
				{
					close();
				}
			}
		}
		
		if (opened)
		{
			if (Input.control.keys.get("select").justPressed)
			{
				G.playSound("button");
			}
			if (Input.control.anyJustPressed)
			{
				G.playSound("click");
			}
		}
	}
	
	public function openControls()
	{
		controls.open();
		options.close();
	}
	
	public function closeControls()
	{
		controls.close();
		options.open();
	}
	
	override public function close()
	{
		closeControls();
		super.close();
		options.optionsList.setFocus();
		if (Input.control.keys.get("select").justPressed)
		{
			G.playSound("button");
		}
	}
	
	override public function open()
	{
		super.open();
	}

}