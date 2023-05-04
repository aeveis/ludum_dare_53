package util.ui;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;
import openfl.display.ShaderParameter;
import util.ui.UIContainer.Box;
import util.ui.UIContainer.UILayout;
import util.ui.UIContainer.UIParent;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIContainer.UISize;

/**
 * An image specifically used for UI. Functions the same as `UIContainer`, 
 * but has an sprite that renders as a background separate from its members
 * 
 * Also has options for 9 slicing.
 * 
 * @author aeveis
 */
class UIImage extends UIContainer
{
	public var bgSprite(default, null):FlxSprite;
	public var bgSides(default, null):Box;
	
	public var sheetWidth:Float = 0;
	public var sheetHeight:Float = 0;
	
	public var color(default, set):FlxColor;
	function set_color(p_color:FlxColor):FlxColor
	{
		if (bgSprite != null) bgSprite.color = p_color;
		return color = p_color;
	}
	
	private var nineSliceShader:NineSliceShader = null;
	
	public function new(?p_bgImage:FlxGraphicAsset, ?p_placement:UIPlacement, ?p_size:UISize, ?p_childPlacement:UIPlacement, ?p_padding:Box, ?p_margin:Box, ?p_parent:UIParent) 
	{
		nineSliceShader = new NineSliceShader();
		bgSides = UILayout.zeroBox;
		bgSprite = new FlxSprite();
		super(p_placement, p_size, p_childPlacement, p_padding, p_margin, p_parent);
		
		setBG(p_bgImage);
	}
	
	public function setBG(?p_bgImage:FlxGraphicAsset, p_width:Float = 0, p_height:Float = 0)
	{
		if (p_bgImage != null) 
		{
			var graph:FlxGraphic = FlxG.bitmap.add(p_bgImage);
			sheetWidth = graph.width;
			sheetHeight = graph.height;
			bgSprite.loadGraphic(p_bgImage, p_width != 0, Std.int(p_width), Std.int(p_height));
		}
		else
		{
			bgSprite.makeGraphic(4, 4);
		}
		
		bgSprite.origin.set(0, 0);
		scaleBG();
	}
	
	public function addBGAnim(p_animName:String, p_frames:Array<Int>, p_framerate:Int = 10, p_loop:Bool = false)
	{
		bgSprite.animation.add(p_animName, p_frames, p_framerate, p_loop);
	}
	
	public function playBGAnim(p_animName:String)
	{
		bgSprite.animation.play(p_animName);
	}
	
	/**
	 * Set background to nine slice the background image
	 * if box is not specified, it will just stretch the image
	 * @param	p_sides Use UILayout for faster box declarations
	 */
	public function nineSlice(?p_sides:Box)
	{
		if (p_sides == null) p_sides = UILayout.zeroBox;
		
		bgSides = p_sides;
		scaleBG();
		bgSprite.shader = nineSliceShader;
	}
	
	private function scaleBG()
	{
		var sx = width / bgSprite.width;
		var sy = height / bgSprite.height;
		bgSprite.scale.set(sx, sy);
		if(sx < 1.0 || sy < 1.0) return;
		
		nineSliceShader.fullsize.value = [width, height];
		nineSliceShader.basesize.value = [bgSprite.width, bgSprite.height];
		nineSliceShader.sides.value = [bgSides.left, bgSides.right, bgSides.top, bgSides.bottom];
		nineSliceShader.uvOffset.value = [bgSprite.width / sheetWidth, bgSprite.height / sheetHeight];
	}
	
	override public function setSize(p_size:UISize, p_refreshChildren:Bool = false)
	{
		super.setSize(p_size, p_refreshChildren);
		scaleBG();
	}
	
	override public function setPlacement(p_placement:UIPlacement, p_refreshChildren:Bool = false)
	{
		bgSprite.x = x;
		bgSprite.y = y;
		super.setPlacement(p_placement, p_refreshChildren);
	}
	
	override function set_x(p_x:Float): Float
	{
		bgSprite.x += p_x - x;
		return super.set_x(p_x);
	}
	
	override function set_y(p_y:Float):Float
	{
		bgSprite.y += p_y - y;
		return super.set_y(p_y);
	}
	
	override private function pointXCallback(p_point:FlxPoint)
	{
		bgSprite.scrollFactor.x = p_point.x;
		super.pointXCallback(p_point);
	}
	override private function pointYCallback(p_point:FlxPoint)
	{
		bgSprite.scrollFactor.y = p_point.y;
		super.pointYCallback(p_point);
	}
	override private function pointXYCallback(p_point:FlxPoint)
	{
		bgSprite.scrollFactor.set(p_point.x, p_point.y);
		super.pointXYCallback(p_point);
	}
	
	override function set_camera(p_cam:FlxCamera):FlxCamera
	{
		bgSprite.camera = p_cam;
		return super.set_camera(p_cam);
	}
	
	override function set_cameras(p_cams:Array<FlxCamera>):Array<FlxCamera>
	{
		bgSprite.cameras = p_cams;
		return super.set_cameras(p_cams);
	}
	
	override public function draw()
	{
		bgSprite.draw();
		super.draw();
	}
	
	override public function destroy()
	{
		bgSprite.destroy();
		super.destroy();
	}
}

class NineSliceShader extends FlxShader
	{
		
	@:glFragmentSource('
		#pragma header
		#ifdef GL_ES
			precision mediump float;
		#endif
		
		uniform vec4 sides;
		uniform vec2 basesize;
		uniform vec2 fullsize;
		uniform vec2 uvOffset;
		
		void main()
		{
			vec2 uv = openfl_TextureCoordv;
			
			float xTileRatio = floor(uv.x/uvOffset.x);
			float yTileRatio = floor(uv.y/uvOffset.y);
			
			uv.x = mod(uv.x/uvOffset.x, 1.0);
			uv.y = mod(uv.y/uvOffset.y, 1.0);
			
			float l = sides.x / fullsize.x;
			float r = (fullsize.x - sides.y) / fullsize.x;
			float t = sides.z / fullsize.y;
			float b = (fullsize.y - sides.w) / fullsize.y;
			
			float xratio = fullsize.x / basesize.x;
			//xratio = (1 - step(1, xratio)) + step(1, xratio) * xratio;
			float leftmask = (1.0 - step(l, uv.x));
			float rightmask = step(r, uv.x);
			float rightoffset = (fullsize.x - basesize.x) / basesize.x;
			
			float xmask = 1.0 - (leftmask + rightmask);
			float xstretch = ((basesize.x - (sides.x + sides.y)) / basesize.x) / ((fullsize.x - (sides.x + sides.y)) / fullsize.x);
			float xoffset = sides.x / basesize.x - l * xstretch;
			
			uv.x *= xmask * xstretch + (leftmask + rightmask) * xratio;
			uv.x += xmask * xoffset - rightmask * rightoffset;
			
			float topmask = (1.0 - step(t, uv.y));
			float bottommask = step(b, uv.y);
			float bottomoffset = (fullsize.y - basesize.y) / basesize.y;
			
			float yratio = fullsize.y / basesize.y;
			//yratio = (1 - step(1, yratio)) + step(1, yratio) * yratio;
			float ymask = 1.0 - (topmask + bottommask);
			float ystretch = ((basesize.y - (sides.z + sides.w)) / basesize.y) / ((fullsize.y - (sides.z + sides.w)) / fullsize.y);
			float yoffset = sides.z / basesize.y - t * ystretch;
			
			uv.y *= ymask * ystretch + (topmask + bottommask) * yratio;
			uv.y += ymask * yoffset - bottommask * bottomoffset;
			
			uv.x = (uv.x + xTileRatio) * uvOffset.x;
			uv.y = (uv.y + yTileRatio) * uvOffset.y;
			gl_FragColor = texture2D(bitmap, uv);
			if(hasColorTransform)
			{
				gl_FragColor.rgb *= openfl_ColorMultiplierv.rgb;
			}

			//gl_FragColor = vec4(uv.x, uv.y, 0, 1);
			
		}
	')

	public function new()
	{
		super();
	}
}