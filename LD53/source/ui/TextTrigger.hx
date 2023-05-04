package ui;

import flixel.FlxObject;
import flixel.util.FlxTimer;
import global.TextConstants.TextNode;
import global.TextConstants;
import ui.TextPopup.PopupState;

/**
 * ...
 * @author aeveis
 */
enum TextTriggerState
{
	Ready;
	Playing;
	Done;
}

class TextTrigger extends FlxObject
{
	public var textNode:TextNode;
	public var text:Array<String>;
	public var callbacks:Map<Int, Void->Void>;
	public var callAuto:Bool = false;
	public var state:TextTriggerState;

	public var index:Int = 0;
	public var locked:Bool = true;
	public var onTrigger:Bool = false;

	public var name:String;
	public var animName:String = "Normal";

	public var typeSoundName = "type";
	public var typeSoundRandomCount = 1;

	public var unskippable:Bool = false;
	public var oneshot:Bool = false;
	public var textpopup:TextPopup;

	private var hasTextPopup:Bool = false;
	private var poppedup:Bool = false;

	private var checkTimer:FlxTimer;
	private var cancelTimer:FlxTimer;
	private var skipChecked:Bool = false;
	private var isImportant:Bool = false;

	public function new(px:Float, py:Float, pwidth:Float, pheight:Float, pname:String, ptext:TextNode)
	{
		super(px, py);
		width = pwidth;
		height = pheight;
		textNode = ptext;
		text = textNode.texts;
		if (text == null)
		{
			text = TextConstants.instance.error.texts;
		}

		switch (textNode.link)
		{
			case TextLink.Oneshot:
				oneshot = true;
			case TextLink.Triggerable(e_enableCallback):
				oneshot = true;
				visible = false;
			default:
		}

		name = pname;
		solid = true;

		callbacks = new Map<Int, Void->Void>();

		state = TextTriggerState.Ready;
		checkTimer = new FlxTimer();
		cancelTimer = new FlxTimer();
	}

	public function setTextNode(ptextNode:TextNode)
	{
		textNode = ptextNode;
		text = textNode.texts;
	}

	public function addCallback(index:Int, pcallback:Void->Void)
	{
		callbacks.set(index, pcallback);
	}

	public function setTypeSound(soundName:String, soundRandomCount:Int = 0)
	{
		typeSoundName = soundName;
		typeSoundRandomCount = soundRandomCount;
	}

	public function addTextPopup(p_tpopup:TextPopup)
	{
		textpopup = p_tpopup;
		hasTextPopup = true;
	}

	public function setPopupState(state:PopupState)
	{
		if (!hasTextPopup)
			return;
		textpopup.setState(state);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!onTrigger && !oneshot)
		{
			state = TextTriggerState.Ready;
			index = 0;
			setPopupState(PopupState.Hide);
		}
		onTrigger = false;

		if (skipChecked)
			return;

		checkLink();
	}

	public function resetTrigger()
	{
		state = TextTriggerState.Ready;
		index = 0;

		switch (textNode.link)
		{
			case TextLink.Notify(e_callback, e_node, e_popup, e_cancelCallback):
				checkNotify();
			default:
		}
	}

	public function getText():String
	{
		var rtext = text[index];
		if (index >= textNode.portraits.length)
		{
			animName = textNode.portraits[textNode.portraits.length - 1];
		}
		else
		{
			animName = textNode.portraits[index];
		}
		index++;

		if (index == text.length)
		{
			state = TextTriggerState.Done;
			isImportant = false;
			checkNotify();
			if (!skipChecked && isImportant)
			{
				state = TextTriggerState.Ready;
				index = 0;
			}
		}

		return rtext;
	}

	public function checkLink(?timer:FlxTimer)
	{
		switch (textNode.link)
		{
			case TextLink.Notify(e_callback, e_node, e_popup, e_cancelCallback):
				if (e_cancelCallback())
				{
					checkNotify();
				}
				else
				{
					cancelTimer.start(2.0, checkLink);
					skipChecked = true;
				}
			case TextLink.Triggerable(e_enableCallback):
				if (e_enableCallback())
				{
					visible = true;
				}
				else
				{
					cancelTimer.start(0.5, checkLink);
					skipChecked = true;
				}
			default:
				skipChecked = true;
		}
	}

	public function setPosFromNPC(px:Float, py:Float)
	{
		x = px - 8;
		y = py - 8;
		textpopup.setPos(px, py - 18);
	}

	public function checkNotify(?timer:FlxTimer)
	{
		switch (textNode.link)
		{
			case TextLink.Notify(e_callback, e_node, e_popup, e_cancelCallback):
				if (e_callback())
				{
					e_node.portraits[0] = textNode.portraits[0];
					textNode = e_node;

					text = textNode.texts;
					oneshot = (textNode.link == TextLink.Oneshot) ? true : false;
					if (e_popup)
					{
						setPopupState(PopupState.Notify);
						isImportant = true;
					}
					else
					{
						textpopup.resetRead();
						isImportant = false;
					}
					checkTimer.cancel();
					cancelTimer.cancel();
					skipChecked = false;
				}
				else
				{
					checkTimer.start(1, checkNotify);
				}
			default:
		}
	}

	override function destroy()
	{
		callbacks.clear();
		callbacks = null;
		super.destroy();
	}
}
