package ui;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import util.Input;
import util.InputState;
import util.ui.UIBitmapText;
import util.ui.UIContainer;
import util.ui.UIImage;
import util.ui.UIText;

/**
 * ...
 * @author aeveis
 */
enum PopupState
{
	Hidden;
	Show;
	Shown;
	Open;
	Hide;
	Notify;
}

class TextPopup extends UIImage
{
	private var t_interact:UIText;
	private var state:PopupState = PopupState.Hidden;
	private var startY:Float;
	private var startX:Float;
	private var startWidth:Float = 0;
	private var offsetX:Float = 0;
	private var offsetY:Float = 0;
	private var appearY:Float = 8;
	private var openY:Float = 3;
	private var notifyY:Float = 8;
	private var animateTime:Float = 0.1;

	private var read:Bool = false;
	private var notifySet:Bool = false;

	private var currentSelect:String = "X";

	public function new(px:Float, py:Float)
	{
		super(AssetPaths.pickup__png, UIPlacement.Pos(px, py), UISize.Size(8, 8), UIPlacement.Top);
		scrollFactor.set(1, 1);
		startX = x;
		startY = y;
		// nineSlice(UILayout.box(1, 1, 1, 1));

		// t_interact = new UIText("[X]");
		// t_interact.setColor(0xff232855);
		// add(t_interact);
		setSizeToInteract(1.0);
		// Input.setSwitchGamepadCallback(updateGamepadButton);
		// Input.setSwitchKeysCallback(updateKeyboardButton);
		refresh(true);

		close();
	}

	public function setPos(px:Float, py:Float)
	{
		x = startX = px;
		y = startY = py;
	}

	public function setSizeToInteract(ratio:Float = 1.0)
	{
		/*var newWidth = ratio * 8.0;
			(ratio < 1.0) ? offsetX = 0 : offsetX = startWidth - newWidth;
			setSize(UISize.Size(newWidth, ratio + 2));
			x = startX + (bgSprite.width * (1.0 - ratio)) / 2.0 - 1.0 * (1.0 - ratio) + offsetX / 2.0; */
		bgSprite.scale.set(ratio, ratio);
		bgSprite.centerOrigin();
	}

	public function updateGamepadButton()
	{
		var input:InputState = Input.control.keys.get("select");
		currentSelect = Input.getGamepadInputString(input.gamepadMapping[input.lastChangedGamepadIndex]);
		refresh(true);
	}

	public function updateKeyboardButton()
	{
		var input:InputState = Input.control.keys.get("select");
		// trace(input.lastChangedIndex);
		currentSelect = Input.getInputString(input.keyMapping[input.lastChangedIndex]);
		refresh(true);
	}

	public function setState(p_state:PopupState)
	{
		if (state == p_state)
			return;
		switch (p_state)
		{
			case PopupState.Show:
				if (state == PopupState.Shown)
					return;
				if (state == PopupState.Notify)
					return;
				open();
				y = startY;
				offsetY = appearY;
				setSizeToInteract(0.0);
			/*t_interact.visible = false;
				if (!notifySet)
				{
					t_interact.text = "[" + currentSelect + "]";
			}*/
			case PopupState.Hide:
				if (state == PopupState.Hidden)
					return;
				if (notifySet)
					return;
				y = startY;
				offsetY = 0;
				// t_interact.visible = false;
				state = PopupState.Hide;
			case PopupState.Open:
				if (state == PopupState.Hidden)
					return;
				read = true;
				color = 0xaaaaaa;
				y = startY;
				offsetY = 0;
				// t_interact.visible = false;
				notifySet = false;
			case PopupState.Shown:
				open();
				y = startY;
				offsetY = 0;
				setSizeToInteract(1.0);
			// t_interact.visible = true;
			case PopupState.Hidden:
				close();
			case Notify:
				if (notifySet)
					return;
				open();
				color = 0xffffff;
				read = false;
				y = startY;
				offsetY = appearY;
				setSizeToInteract(0.0);
				/*t_interact.visible = false;
					t_interact.text = "!" + currentSelect + "!"; */
				notifySet = true;
				new FlxTimer().start(0.5, showNotifySelect);
		}
		state = p_state;
	}

	public function showNotifySelect(timer:FlxTimer)
	{
		if (!notifySet)
			return;
		// t_interact.text = "[" + currentSelect + "]";
		setSizeToInteract(1.0);
		timer.start(0.5, showNotifyPoint);
	}

	public function showNotifyPoint(timer:FlxTimer)
	{
		if (!notifySet)
			return;
		t_interact.text = "!" + currentSelect + "!";
		// setSizeToInteract(1.0);
		timer.start(0.5, showNotifySelect);
	}

	public function resetRead()
	{
		color = 0xffffff;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		switch (state)
		{
			case PopupState.Show | PopupState.Notify:
				offsetY -= elapsed / animateTime * appearY;
				y = startY + offsetY;
				setSizeToInteract(1.0 - offsetY / appearY);
				if (y <= startY)
				{
					y = startY;
					setSizeToInteract(1.0);
					// t_interact.visible = true;
					state = PopupState.Shown;
				}
			case PopupState.Open:
				offsetY += elapsed / animateTime * openY;
				y = startY - offsetY;
				setSizeToInteract(1.0 - offsetY / openY);
				if (y <= startY - openY)
				{
					setSizeToInteract(0);
					state = PopupState.Hidden;
					close();
				}
			case PopupState.Hide:
				offsetY += elapsed / animateTime * appearY;
				y = startY + offsetY;
				setSizeToInteract(1.0 - offsetY / appearY);
				if (y >= startY + appearY)
				{
					setSizeToInteract(0);
					state = PopupState.Hidden;
					close();
				}
			case PopupState.Shown:
				if (notifySet)
				{
					offsetY += elapsed * notifyY;
					y += 0.2 * FlxMath.fastSin(offsetY);
				}
			default:
		}
	}
}
