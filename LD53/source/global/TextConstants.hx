package global;

import flixel.util.FlxDirectionFlags;
import util.Input;

/**
 * ...
 * @author aeveis
 */
enum TextLink
{
	Repeatable;
	Oneshot;
	Triggerable(e_enableCallback:() -> Bool);
	Choices(e_choices:Array<String>, e_nodes:Array<TextNode>);
	Notify(e_callback:() -> Bool, e_node:TextNode, e_popup:Bool, e_skipCallback:() -> Bool);
}

class TextNode
{
	static public var _nodes:Array<TextNode>;

	public var texts:Array<String>;
	public var portraits:Array<String>;
	public var link:TextLink;

	public function new(p_link:TextLink = Repeatable)
	{
		texts = new Array<String>();
		portraits = new Array<String>();
		portraits.push("light");
		link = p_link;

		if (_nodes == null)
		{
			_nodes = new Array<TextNode>();
		}
		_nodes.push(this);
	}

	static public function destroy()
	{
		for (node in _nodes)
		{
			node.link = null;
			node.texts = null;
			node.portraits = null;
			node = null;
		}
		_nodes = null;
	}
}

class TextConstants
{
	static private var _instance:TextConstants;
	static public var instance(get, null):TextConstants;

	static public function get_instance():TextConstants
	{
		if (_instance == null)
		{
			_instance = new TextConstants();
		}
		return _instance;
	}

	static public function destroy()
	{
		TextNode.destroy();
		_instance = null;
	}

	public var debug:TextNode = new TextNode();
	public var error:TextNode = new TextNode();
	public var intro:TextNode = new TextNode();
	public var flying:TextNode = new TextNode();
	public var resting:TextNode = new TextNode();
	public var flyingtop:TextNode = new TextNode();
	public var flipping:TextNode = new TextNode();
	public var hi:TextNode = new TextNode();
	public var sandbox:TextNode = new TextNode();
	public var startparcel:TextNode = new TextNode();
	public var careful:TextNode = new TextNode();
	public var ending:TextNode = new TextNode();

	public function new()
	{
		debug.texts = ["Debug Text. <wave>This is the debug text.</wave>"];
		error.texts = ["Text ID not found. :("];
		intro.texts = [
			"<color=cyan>Flipping Finches</color> By aeveis (dan lin) <lime>Ludum Dare 53: Delivery</lime>",
			"[ <color=yellow>Arrow keys</color> to move ]    [ <color=yellow>Space or Up</color> to flap/jump ]\n[ <color=yellow>X</color> to Interact ]"
		];
		flying.texts = [
			"You can press <yellow>[Space]</yellow> or <yellow>[Up]</yellow> to fly. If you hold it you can even glide!",
			"That's something you know already, right?"
		];
		resting.texts = [
			"I've heard you have a history of doing lots of flips...",
			"Be careful with those parcels please!!"
		];
		flyingtop.texts = ["Hello. Don't be breaking this latest parcel now you hear?"];
		flipping.texts = [
			"Flip master! I know you can flip <yellow>turning in the air</yellow>...",
			"But I didn't think <yellow>< ^ ></yellow> or <yellow>> ^ <</yellow> would work either! Thank you!"
		];
		hi.texts = [
			"Hi. we have a package ready for you higher up.",
			"Please don't destroy this one..."
		];
		sandbox.texts = [
			"I just want to fly around... do flips and such.",
			"Though I've heard with a parcel things are a bit different."
		];
		startparcel.texts = [
			"Hey there. This parcel has been prepared and wrapped tightly to prevent damage.",
			"We'll like you to fly all the way to the top with it. You'll know it when you see it.",
			"What's in the parcel? That's confidential!"
		];
		careful.texts = [
			"Given your and others' history with parcels we have tape scattered around.",
			"Yes, tape. You can repair your package with it."
		];
	}
}
