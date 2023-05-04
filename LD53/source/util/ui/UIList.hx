package util.ui;
import util.ui.UIContainer;

/**
 * UI class for creating a list of selectable options
 * @author aeveis
 */
class UIList extends UIContainer
{

	public var focus:Int = 0;
	public var options:Array<UIOption>;
	private var optionCounter:Int = 0;
	public var currentFocused(get, null):UIOption;
	function get_currentFocused():UIOption
	{
		return options[focus];
	}
	
	public function new(?p_placement:UIPlacement, ?p_size:UISize, 
						?p_childPlacement:UIPlacement, ?p_padding:Box, ?p_margin:Box) 
	{
		super(p_placement, p_size, p_childPlacement, p_padding, p_margin);

		options = new Array<UIOption>(); 
	}
	
	public function addOption(p_option:UIOption, p_add:Bool = true)
	{
		options.push(p_option);
		p_option.index = optionCounter;
		optionCounter++;
		if(p_add) add(p_option);
	}
	
	public function onSelected()
	{
		options[focus].selected();
	}
	
	public function nextOption()
	{
		if (options.length < 1) return;
		options[focus].onFocus(false);
		focus++;
		if (focus >= options.length)
		{
			focus = 0;
		}
		options[focus].onFocus();
	}
	
	public function prevOption()
	{
		if (options.length < 1) return;
		options[focus].onFocus(false);
		focus--;
		if (focus < 0)
		{
			focus = options.length - 1;
		}
		options[focus].onFocus();
	}
	
	public function clearOptions()
	{
		while (options.length > 0)
		{
			var option = options.pop();
			remove(option, true);
			option.destroy();
		}
		focus = 0;
	}
	
	public function removeOption(p_index:Int)
	{
		var option = options[p_index];
		options.remove(option);
		remove(option, true);
		option.destroy();
	}
	
	public function setFocus(p_index:Int = 0)
	{
		if (options.length < 1) return;
		
		options[focus].onFocus(false);
		focus = p_index;
		options[focus].onFocus();
	}
	
	public function setOptionCallbackByName(p_name:String, p_callback:Void->Void)
	{
		for (option in options)
		{
			if (option.nameLabel.text == p_name)
			{
				option.setSelectedCallback(p_callback);
				return;
			}
		}
	}
	public function setOptionCallback(p_option:UIOption, p_callback:Void->Void)
	{
		var index = options.indexOf(p_option);
		if (index !=-1)
		{
			options[index].setSelectedCallback(p_callback);
		}
	}
}