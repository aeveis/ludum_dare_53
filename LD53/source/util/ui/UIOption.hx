package util.ui;

import util.ui.UIBitmapText;
import util.ui.UIContainer;
import util.ui.UIImage;

/**
 * ...
 * @author aeveis
 */
class UIOption extends UIImage
{
	public var nameLabel:UIBitmapText;
	public var focused:Bool = false;
	public var index:Int = -1;

	private var selectedCallback:Void->Void = null;
	private var focusCallback:Bool->Void = null;

	public function new(p_name:String, p_placement:UIPlacement, p_size:UISize, ?p_childPlacement:UIPlacement, ?p_padding:Box, ?p_margin:Box)
	{
		super(null, p_placement, p_size, p_childPlacement, p_padding, p_margin);

		nameLabel = new UIBitmapText();
		nameLabel.text = p_name;

		add(nameLabel);
	}

	public function setLabelHeightOffset(p_heightOffset:Float)
	{
		if (nameLabel == null)
			return;
		nameLabel.heightOffset = p_heightOffset;
		nameLabel.setSizeToText();
		refreshChildren();
	}

	public function setSelectedCallback(p_callback:Void->Void)
	{
		selectedCallback = p_callback;
	}

	public function setFocusCallback(p_callback:Bool->Void)
	{
		focusCallback = p_callback;
	}

	public function selected()
	{
		if (selectedCallback == null)
			return;
		selectedCallback();
	}

	public function onFocus(p_focused:Bool = true)
	{
		focused = p_focused;

		if (focusCallback == null)
			return;
		focusCallback(p_focused);
	}
}
