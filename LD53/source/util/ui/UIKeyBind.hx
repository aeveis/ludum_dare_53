package util.ui;
import util.ui.UIContainer.Box;
import util.ui.UIContainer.UILayout;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIContainer.UISize;

/**
 * ...
 * @author aeveis
 */
class UIKeyBind extends UIImage
{

	public function new(p_size:UISize, p_childPlacement:UIPlacement, ?p_padding:Box, ?p_margin:Box) 
	{
		super(null, UIPlacement.Inherit, p_size, p_childPlacement, p_padding, p_margin);
	}
	
}