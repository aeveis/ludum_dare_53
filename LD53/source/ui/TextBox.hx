package ui;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.Portrait;
import util.Input;
import util.InputState;
import util.ui.TypeText;
import util.ui.UIContainer;
import util.ui.UIImage;
import util.ui.UIText;

/**
 * ...
 * @author aeveis
 */
enum TextBoxStatus
{
	Skip;
	Next;
	Done;
}

class TextBox extends UIImage
{
	private var charBox:UIImage;
	private var textBox:UIContainer;
	private var text:UIText;

	public var textCam:FlxCamera;

	private var textZoomRatio:Float;
	private var xbutton:UIText;
	private var xbuttonY:Float;
	private var xbuttonTimer:Float = 0;
	private var status:UIText;
	private var statusState:TextBoxStatus = TextBoxStatus.Skip;

	public var hasMoreText:Bool = false;

	private var charIcon:Portrait;

	public function new(p_bgImage:FlxGraphicAsset, p_placement:UIPlacement, p_size:UISize, ?p_textZoom:Float, ?p_parent:UIParent)
	{
		super(p_bgImage, p_placement, p_size, UIPlacement.Left, UILayout.sides(2), UILayout.hori(1), p_parent);
		scrollFactor.set(0, 0);
		if (p_textZoom == _null)
			p_textZoom = 1;
		textZoomRatio = 1.0 / p_textZoom;

		charBox = new UIImage(null, UIPlacement.Left, UISize.Size(18, 18), UIPlacement.Center, null, UILayout.sides(1));
		textBox = new UIContainer(UIPlacement.Left, UISize.Size(width - height - 60, height), UILayout.top(6));

		textCam = new FlxCamera(0, 0, Math.floor(textBox.width * textZoomRatio), Math.floor(textBox.height * textZoomRatio), p_textZoom);
		textCam.bgColor = 0;

		nineSlice(UILayout.sides(2));
		charBox.nineSlice(UILayout.sides(2));

		charIcon = new Portrait();
		charBox.add(charIcon);

		text = new UIText("Hello hello hello.", true);
		text.setParent(UIParent.Camera(textCam));
		text.setMaxWidth(textBox.width * textZoomRatio);
		text.textSprite.cameras = [textCam];

		textBox.add(text);

		xbutton = new UIText("[X]");
		xbutton.setColor(0xff7ce0db);

		status = new UIText("...");
		status.setColor(0xff2994b6);

		var boxcap:UIContainer = new UIContainer(UIPlacement.Left, UISize.Size(52, height), UIPlacement.Left, UILayout.zeroBox, UILayout.top(-4));
		boxcap.add(status);
		xbutton.setPlacement(UIPlacement.Right);
		boxcap.add(xbutton);

		add(charBox);
		add(textBox);
		add(boxcap);

		text.text = "";

		FlxG.cameras.add(textCam);
		xbuttonY = xbutton.y;

		Input.setSwitchGamepadCallback(updateGamepadButton);
		Input.setSwitchKeysCallback(updateKeyboardButton);
		refreshChildren();
	}

	public function updateGamepadButton()
	{
		var input:InputState = Input.control.keys.get("select");
		xbutton.text = "[" + Input.getGamepadInputString(input.gamepadMapping[input.lastChangedGamepadIndex]) + "]";
		refresh(true);
	}

	public function updateKeyboardButton()
	{
		var input:InputState = Input.control.keys.get("select");
		// trace(input.lastChangedIndex);
		xbutton.text = "[" + Input.getInputString(input.keyMapping[input.lastChangedIndex]) + "]";
		refresh(true);
	}

	public function setPortraitBorderColor(p_color:FlxColor)
	{
		charBox.color = p_color;
	}

	public function setPortraitBorderImage(p_bgImage:FlxGraphicAsset, p_nineSlice:Box, ?p_margin:Box)
	{
		charBox.setBG(p_bgImage);
		charBox.nineSlice(p_nineSlice);
		if (p_margin != null)
			charBox.setMargin(p_margin);

		refreshChildren();
	}

	public function setPortrait(p_image:FlxGraphicAsset, p_animated:Bool = false, p_width:Int = 0, p_height:Int = 0)
	{
		charIcon.loadGraphic(p_image, p_animated, p_width, p_height);
	}

	public function addAnim(p_name:String, p_frames:Array<Int>, p_framerate:Float = 10)
	{
		charIcon.animation.add(p_name, p_frames, p_framerate, true);
	}

	public function playAnim(p_name:String)
	{
		charIcon.animation.play(p_name);
	}

	public function playText(?p_text:String, ?p_typeSound:String, ?p_typeRandomAmount:Int)
	{
		if (p_typeSound != null)
		{
			if (p_typeRandomAmount != null)
			{
				text.setTypingSound(p_typeSound, p_typeRandomAmount);
			}
			else
			{
				text.setTypingSound(p_typeSound);
			}
		}
		if (p_text == null)
		{
			restartTyping();
			return;
		}
		text.text = p_text;
		restartTyping();
		if (TypeText.noTyping || text.shouldSkipType)
		{
			text.skipTyping();
		}
	}

	public override function close()
	{
		super.close();
		text.skipTyping();
	}

	public function skipTyping()
	{
		/*if (isDoneTyping && !hasMoreText)
			{
				visible = false;
		}*/
		text.skipTyping();
	}

	public function restartTyping()
	{
		text.startTyping();
	}

	public var isDoneTyping(get, null):Bool;

	function get_isDoneTyping():Bool
	{
		return !text.isTyping;
	}

	public function hideXButton()
	{
		xbutton.visible = false;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isDoneTyping)
		{
			xbuttonTimer += elapsed * 15;
			xbutton.y = xbuttonY + Math.sin(xbuttonTimer);
		}
		else
		{
			xbutton.y = xbuttonY;
		}

		if (Input.control.keys.get("select").justPressedDelayed)
		{
			xbutton.setColor(0xff2994b6);
			xbutton.y = xbuttonY + 1;
		}
		else
		{
			xbutton.setColor(0xff7ce0db);
		}
	}

	override public function refreshChildren()
	{
		super.refreshChildren();
		refreshTextPlacement();

		xbuttonY = xbutton.y;
	}

	private function refreshTextPlacement()
	{
		textCam.x = textBox.x;
		textCam.y = textBox.y;
		textBox.x = 0;
		textBox.y = 0;
	}

	public function setStatus(p_status:TextBoxStatus)
	{
		if (statusState == p_status)
			return;
		statusState = p_status;
		switch (p_status)
		{
			case TextBoxStatus.Skip:
				status.text = "...";
			case TextBoxStatus.Next:
				status.text = "->";
			default:
				status.text = "OK";
		}
		refresh(true);
	}
}
