package util.ui;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import util.ui.TypeTextShader;

/**
 * Type Text that uses a shader to run typing animation to reduce cost of processing letters
 * Processes up to 4 animation tags <anim=wave|shake></anim>
 * Processes up to 5 color tags <color=[FlxColor macros] | 0x[ffffff]></color>
 * @author aeveis
 */
class TypeBitmapText extends FlxBitmapText
{
	static public var noTyping:Bool = false;
	static public var noAnimation:Bool = false;

	public var isTypeText:Bool = false;
	public var isTyping(default, null):Bool = false;
	public var currentLine(default, null):Int = 0;

	private var typeTextShader:TypeTextShader;
	private var ratio:Float = 1.0;
	private var lines:Float = 0;
	private var timer:Float = 0;

	private var typeSpeed:Float = 1.0;
	private var typingSoundTimer:Float = 0;
	private var typingLetterDelay:Float = 0.03;

	private var typeSoundName:String = null;
	private var typeSoundCount:Int = 0;
	private var typeSoundVolume:Float = 1.0;
	private var typeSoundLoaded:Bool = false;

	private var colorTags:Array<ColorTag>;
	private var animTags:Array<AnimTag>;
	private var lineDoneRatio:Array<LineRatio>;

	override function set_text(p_text:String):String
	{
		if (p_text == null)
			return text;
		var newText = parseTag(p_text);
		if (newText != text)
		{
			text = newText;
			refresh();
		}
		return text;
	}

	function set_isTypeText(p_value:Bool):Bool
	{
		if (!p_value)
		{
			setTypeRatio(1.0);
		}
		return isTypeText == p_value;
	}

	/**
	 * Default does not start typing, `startTyping` must be called.
	 */
	public function new(?pfont:FlxBitmapFont, px:Float = 0, py:Float = 0, ?p_text:String, p_startTyping = false)
	{
		colorTags = new Array<ColorTag>();
		animTags = new Array<AnimTag>();
		lineDoneRatio = new Array<LineRatio>();
		super(pfont);
		pixels = new BitmapData(1, 1, true, FlxColor.TRANSPARENT);
		x = 0;
		y = 0;
		text = p_text;
		offset.set(-1, -2);

		typeTextShader = new TypeTextShader();

		for (i in 0...5)
		{
			colorTags.push({
				enabled: 0,
				startIndex: 0,
				endIndex: 0,
				color: FlxColor.WHITE
			});
		}
		for (i in 0...4)
		{
			animTags.push({
				type: AnimType.Normal,
				startIndex: 0,
				endIndex: 0
			});
		}

		shader = typeTextShader;
		setTypeRatio(1.0);
		isTypeText = p_startTyping;
		if (isTypeText)
		{
			readyTyping();
		}
	}

	public function refresh()
	{
		pendingTextChange = true;
		checkPendingChanges(false);
		refreshShaderValues();
	}

	public function refreshShaderValues()
	{
		lines = _lines.length;
		typeTextShader.lines.value = [lines];
		setShaderTagValues();

		if (text.length <= 0 || !isTypeText)
			return;

		// Clear Line Ratios
		while (lineDoneRatio.length > 0)
		{
			lineDoneRatio.pop();
		}

		for (i in 0...(cast lines))
		{
			var endlineRatio:Float = (cast getLineWidth(i)) / (cast fieldWidth);
			lineDoneRatio.push({
				start: i / lines,
				end: i / lines + endlineRatio / lines
			});
		}
		currentLine = 0;
	}

	public function setTypeRatio(p_ratio:Float)
	{
		ratio = p_ratio;
		typeTextShader.ratio.value = [ratio];
	}

	public function readyTyping()
	{
		if (noTyping)
			return;
		isTypeText = true;
		setTypeRatio(0);
		isTyping = false;
	}

	public function startTyping(pixelPerSec:Float = 256.0)
	{
		if (noTyping)
			return;
		isTypeText = true;
		refreshShaderValues();
		setTypeRatio(0);
		typeSpeed = pixelPerSec / width / lines;
		isTyping = true;
	}

	public function skipTyping()
	{
		if (noTyping)
			return;

		isTyping = false;
		setTypeRatio(1.0);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		timer = (timer + elapsed) % 6.28318530;
		typeTextShader.timer.value = [timer];

		if (noTyping)
			return;
		if (!isTypeText)
			return;
		if (!isTyping)
			return;

		ratio += elapsed * typeSpeed;
		if (ratio >= 1.0)
		{
			ratio = 1.0;
		}
		else if (currentLine < lines && ratio >= lineDoneRatio[currentLine].end)
		{
			currentLine++;
			if (currentLine >= lines)
			{
				ratio = 1.0;
			}
			else
			{
				ratio = lineDoneRatio[currentLine].start;
			}
		}
		typeTextShader.ratio.value = [ratio];
		if (ratio == 1.0)
		{
			isTyping = false;
		}

		// var lineratio:Float = ratio * lines;
		// var xpos:Float = lineratio % 1.0;
		// var ypos:Float = Math.floor(lineratio) / lines + 0.5 / lines;
		// typeTextShader.typePos.value = [xpos, ypos];

		// if (textField.getCharIndexAtPoint(xpos * fieldWidth, ypos * height) == -1)
		//	return;

		if (!typeSoundLoaded)
			return;

		typingSoundTimer += elapsed;
		if (typingSoundTimer > typingLetterDelay)
		{
			typingSoundTimer = 0;
			playRandomTypeSound();
		}
	}

	public function setTypingSound(soundName:String, soundRandomCount:Int = 0, volume:Float = 0.5)
	{
		typeSoundName = soundName;
		typeSoundCount = soundRandomCount;
		typeSoundVolume = volume;
		typeSoundLoaded = true;
	}

	private function playRandomTypeSound()
	{
		if (typeSoundCount == 0)
		{
			FlxG.sound.play(typeSoundName, typeSoundVolume);
			return;
		}
		FlxG.sound.play(typeSoundName + FlxG.random.int(0, typeSoundCount - 1), typeSoundVolume);
	}

	private function parseTag(value:String):String
	{
		clearTags();
		var tag:EReg = regexp(ERegTag.Tag);
		var colorIndex = 0;
		var animIndex = 0;
		while (tag.match(value))
		{
			var actual:String = regexp(ERegTag.TagAll).replace(tag.matched(3), "");
			var name:String = tag.matched(1).toLowerCase();
			var nameVal:String = tag.matched(2);
			var tagpos = tag.matchedPos();
			var vtag:EReg = regexp(name);
			var attr:String = name;
			if (nameVal != null)
			{
				vtag.match(nameVal);
				attr = vtag.matched(1).toLowerCase();
			}
			switch (name)
			{
				case ERegTag.Color | "white" | "gray" | "grey" | "black" | "green" | "lime" | "yellow" | "orange" | "red" | "purple" | "blue" | "brown" | "pink" | "magenta" | "cyan":
					var tagColor:Int = FlxColor.WHITE;
					switch (attr)
					{
						case "white":
							tagColor = FlxColor.WHITE;
						case "gray" | "grey":
							tagColor = FlxColor.GRAY;
						case "black":
							tagColor = FlxColor.BLACK;
						case "green":
							tagColor = FlxColor.GREEN;
						case "lime":
							tagColor = FlxColor.LIME;
						case "yellow":
							tagColor = FlxColor.YELLOW;
						case "orange":
							tagColor = FlxColor.ORANGE;
						case "red":
							tagColor = FlxColor.RED;
						case "purple":
							tagColor = FlxColor.PURPLE;
						case "blue":
							tagColor = FlxColor.BLUE;
						case "brown":
							tagColor = FlxColor.BROWN;
						case "pink":
							tagColor = FlxColor.PINK;
						case "magenta":
							tagColor = FlxColor.MAGENTA;
						case "cyan":
							tagColor = FlxColor.CYAN;
						default:
							tagColor = Std.parseInt("0x" + attr);
					}
					var startIndex = tagpos.pos;
					var endIndex = tagpos.pos + actual.length;
					setColorTag(colorIndex, tagColor, startIndex, endIndex);
					colorIndex++;
				case ERegTag.Anim | "wave" | "shake":
					var animType:AnimType = AnimType.Normal;
					switch (attr)
					{
						case "wave":
							animType = AnimType.Wave;
						case "shake":
							animType = AnimType.Shaky;
						default:
					}
					var startIndex = tagpos.pos;
					var endIndex = tagpos.pos + actual.length;
					setAnimTag(animIndex, animType, startIndex, endIndex);
					animIndex++;
				default:
			}

			value = tag.replace(value, "$3");
		}

		return value;
	}

	private function regexp(tagType:ERegTag):EReg
	{
		switch (tagType)
		{
			case ERegTag.NewLine:
				return ~/\n/g;
			case ERegTag.Tag: // check for any valid tag
				return ~/<([A-Za-z]+)(=[#A-Za-z0-9,.]+)?>((?!<\1|<\/\1)(?:.|\n)*?)<\/\1>/i;
			case ERegTag.TagAll: // check for any valid tag
				return ~/<\/?[#A-Za-z0-9,.=]+>/ig;
			case ERegTag.Color:
				return ~/=#?([A-Fa-f0-9]{8}|[A-Fa-f0-9]{6}|[A-Za-z]+)/;
			case ERegTag.Anim:
				return ~/=([A-Za-z]+)/;
			default:
				return ~/([A-Za-z]+)/;
		}
	}

	private function setColorTag(colorIndex:Int, color:FlxColor, startIndex:Int, endIndex:Int)
	{
		if (colorIndex > 4)
		{
			trace("Warning: Cannot have more than 5 color tags");
			return;
		}
		colorTags[colorIndex].enabled = 1.0;
		colorTags[colorIndex].color = color;
		colorTags[colorIndex].startIndex = startIndex;
		colorTags[colorIndex].endIndex = endIndex;
	}

	private function setAnimTag(animIndex:Int, animType:AnimType, startIndex:Int, endIndex:Int)
	{
		if (animIndex > 3)
		{
			trace("Warning: Cannot have more than 4 anim tags");
			return;
		}
		if (noAnimation)
		{
			animType = AnimType.Normal;
		}
		animTags[animIndex].type = animType;
		animTags[animIndex].startIndex = startIndex;
		animTags[animIndex].endIndex = endIndex;
	}

	private function clearTags()
	{
		for (tag in colorTags)
		{
			tag.enabled = 0.0;
			tag.color = FlxColor.WHITE;
			tag.startIndex = 0;
			tag.endIndex = 0;
		}
		for (tag in animTags)
		{
			tag.type = AnimType.Normal;
			tag.startIndex = 0;
			tag.endIndex = 0;
		}
	}

	private function setShaderTagValues()
	{
		typeTextShader.anim0.value = crunchAnimTag(animTags[0]);
		typeTextShader.anim1.value = crunchAnimTag(animTags[1]);
		typeTextShader.anim2.value = crunchAnimTag(animTags[2]);
		typeTextShader.anim3.value = crunchAnimTag(animTags[3]);
		typeTextShader.colPos0.value = crunchColorTag(colorTags[0]);
		typeTextShader.colPos1.value = crunchColorTag(colorTags[1]);
		typeTextShader.colPos2.value = crunchColorTag(colorTags[2]);
		typeTextShader.colPos3.value = crunchColorTag(colorTags[3]);
		typeTextShader.colPos4.value = crunchColorTag(colorTags[4]);
		typeTextShader.col0.value = setColorFromTag(colorTags[0]);
		typeTextShader.col1.value = setColorFromTag(colorTags[1]);
		typeTextShader.col2.value = setColorFromTag(colorTags[2]);
		typeTextShader.col3.value = setColorFromTag(colorTags[3]);
		typeTextShader.col4.value = setColorFromTag(colorTags[4]);
		return;
	}

	private function getLineIndexOfChar(index:Int):Int
	{
		var count:Int = 0;
		for (i in 0..._lines.length)
		{
			count += _lines[i].length;
			if (count > index - i)
			{
				return i;
			}
			else if (i == _lines.length - 1)
			{
				return i;
			}
		}
		return -1;
	}

	private function getPosOfChar(index:Int, end:Bool = false):Float
	{
		var count:Int = 0;
		var line:Int = 0;
		for (i in 0..._lines.length)
		{
			count += _lines[i].length;
			if (count > index - i)
			{
				line = i;
				count = index - (count - _lines[i].length) - i;
				break;
			}
			else if (i == _lines.length - 1)
			{
				line = i;
				count = _lines[i].length;
			}
		}
		if (!end)
		{
			count--;
			if (count < 0)
			{
				count = 0;
			}
		}
		else
		{
			if (count < 0)
			{
				line--;
				count = _lines[line].length - 1;
			}
		}
		var sub = _lines[line].substring(0, count);
		// trace("\n" + line + ": " + _lines[line] + "\n", count, sub, getStringWidth(sub));
		return cast getStringWidth(sub);
	}

	private function crunchAnimTag(tag:AnimTag):Array<Float>
	{
		if (tag.type == AnimType.Normal)
			return [0, 0, 0];

		var startLine:Int = getLineIndexOfChar(tag.startIndex) + 1;
		var endLine:Int = getLineIndexOfChar(tag.endIndex) + 1;
		// trace(tag.startIndex, tag.endIndex);
		var startX:Float = getPosOfChar(tag.startIndex) / (cast fieldWidth);
		var endX:Float = getPosOfChar(tag.endIndex, true) / (cast fieldWidth);
		return [tag.type, startLine + endLine / 1000.0, Math.floor(startX * 1000.0) + endX];
	}

	private function crunchColorTag(tag:ColorTag):Array<Float>
	{
		if (tag.enabled == 0.0)
			return [0, 0, 0];

		var startLine:Int = getLineIndexOfChar(tag.startIndex) + 1;
		var endLine:Int = getLineIndexOfChar(tag.endIndex) + 1;
		// trace(tag.startIndex, tag.endIndex);
		var startX:Float = getPosOfChar(tag.startIndex) / (cast fieldWidth);
		var endX:Float = getPosOfChar(tag.endIndex, true) / (cast fieldWidth);
		return [1.0, startLine + endLine / 1000.0, Math.floor(startX * 1000.0) + endX];
	}

	private function setColorFromTag(tag:ColorTag):Array<Float>
	{
		return [tag.color.redFloat, tag.color.greenFloat, tag.color.blueFloat];
	}

	override public function drawFrame(p_force:Bool = false)
	{
		checkPendingChanges(false);
		calcFrame(p_force);
	}

	override function updateHitbox()
	{
		checkPendingChanges(false);
		width = Math.abs(scale.x) * frameWidth;
		height = Math.abs(scale.y) * frameHeight;
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		centerOrigin();
	}

	override function draw()
	{
		checkEmptyFrame();

		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		if (dirty) // rarely
			calcFrame(useFramePixels);

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			if (isSimpleRender(camera))
				drawSimple(camera);
			else
				drawComplex(camera);

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	override function set_clipRect(Rect:FlxRect):FlxRect
	{
		super.set_clipRect(Rect);
		pendingTextBitmapChange = true;
		return clipRect;
	}

	override function set_color(Color:FlxColor):FlxColor
	{
		super.set_color(Color);
		pendingTextBitmapChange = true;
		return color;
	}

	override function set_alpha(value:Float):Float
	{
		super.set_alpha(value);
		pendingTextBitmapChange = true;
		return value;
	}

	override function set_textColor(value:FlxColor):FlxColor
	{
		if (textColor != value)
		{
			textColor = value;
			pendingPixelsChange = true;
		}

		return value;
	}

	override function set_useTextColor(value:Bool):Bool
	{
		if (useTextColor != value)
		{
			useTextColor = value;
			pendingPixelsChange = true;
		}

		return value;
	}

	override function calcFrame(force:Bool = false)
	{
		checkEmptyFrame();
		if (!force)
			return;
		updateFramePixels();
	}

	override function updateTextBitmap(useTiles:Bool = false)
	{
		computeTextSize();
		textBitmap = FlxDestroyUtil.disposeIfNotEqual(textBitmap, frameWidth, frameHeight);

		if (textBitmap == null)
		{
			textBitmap = new BitmapData(frameWidth, frameHeight, true, FlxColor.TRANSPARENT);
		}
		else
		{
			textBitmap.fillRect(textBitmap.rect, FlxColor.TRANSPARENT);
		}

		textBitmap.lock();
		_fieldWidth = frameWidth;

		var numLines:Int = _lines.length;
		var line:String;
		var lineWidth:Int;

		var ox:Int, oy:Int;

		for (i in 0...numLines)
		{
			line = _lines[i];
			lineWidth = _linesWidth[i];

			// LEFT
			ox = font.minOffsetX;
			oy = i * (font.lineHeight + lineSpacing) + padding;

			if (alignment == FlxTextAlign.CENTER)
			{
				ox += Std.int((frameWidth - lineWidth) / 2);
			}
			else if (alignment == FlxTextAlign.RIGHT)
			{
				ox += (frameWidth - lineWidth) - padding;
			}
			else // LEFT OR JUSTIFY
			{
				ox += padding;
			}

			drawLine(i, ox, oy, false);
		}
		textBitmap.unlock();
		pendingTextBitmapChange = false;
	}

	override function drawLine(lineIndex:Int, posX:Int, posY:Int, useTiles:Bool = false)
	{
		blitLine(lineIndex, posX, posY);
	}

	override function updatePixels(useTiles:Bool = false)
	{
		var colorForFill:Int = background ? backgroundColor : FlxColor.TRANSPARENT;
		var bitmap:BitmapData = null;
		if (pixels == null || (frameWidth != pixels.width || frameHeight != pixels.height))
		{
			pixels = new BitmapData(frameWidth, frameHeight, true, colorForFill);
		}
		else
		{
			pixels.fillRect(graphic.bitmap.rect, colorForFill);
		}

		bitmap = pixels;
		bitmap.lock();
		if (!useTiles)
		{
			bitmap.lock();
		}

		var isFront:Bool = false;

		var iterations:Int = Std.int(borderSize * borderQuality);
		iterations = (iterations <= 0) ? 1 : iterations;

		var delta:Int = Std.int(borderSize / iterations);

		var iterationsX:Int = 1;
		var iterationsY:Int = 1;
		var deltaX:Int = 1;
		var deltaY:Int = 1;

		if (borderStyle == FlxTextBorderStyle.SHADOW)
		{
			iterationsX = Math.round(Math.abs(shadowOffset.x) * borderQuality);
			iterationsX = (iterationsX <= 0) ? 1 : iterationsX;

			iterationsY = Math.round(Math.abs(shadowOffset.y) * borderQuality);
			iterationsY = (iterationsY <= 0) ? 1 : iterationsY;

			deltaX = Math.round(shadowOffset.x / iterationsX);
			deltaY = Math.round(shadowOffset.y / iterationsY);
		}

		// render border
		switch (borderStyle)
		{
			case SHADOW:
				for (iterY in 0...iterationsY)
				{
					for (iterX in 0...iterationsX)
					{
						drawText(deltaX * (iterX + 1), deltaY * (iterY + 1), isFront, bitmap, useTiles);
					}
				}
			case OUTLINE:
				// Render an outline around the text
				// (do 8 offset draw calls)
				var itd:Int = 0;
				for (iter in 0...iterations)
				{
					itd = delta * (iter + 1);
					// upper-left
					drawText(-itd, -itd, isFront, bitmap, useTiles);
					// upper-middle
					drawText(0, -itd, isFront, bitmap, useTiles);
					// upper-right
					drawText(itd, -itd, isFront, bitmap, useTiles);
					// middle-left
					drawText(-itd, 0, isFront, bitmap, useTiles);
					// middle-right
					drawText(itd, 0, isFront, bitmap, useTiles);
					// lower-left
					drawText(-itd, itd, isFront, bitmap, useTiles);
					// lower-middle
					drawText(0, itd, isFront, bitmap, useTiles);
					// lower-right
					drawText(itd, itd, isFront, bitmap, useTiles);
				}
			case OUTLINE_FAST:
				// Render an outline around the text
				// (do 4 diagonal offset draw calls)
				// (this method might not work with certain narrow fonts)
				var itd:Int = 0;
				for (iter in 0...iterations)
				{
					itd = delta * (iter + 1);
					// upper-left
					drawText(-itd, -itd, isFront, bitmap, useTiles);
					// upper-right
					drawText(itd, -itd, isFront, bitmap, useTiles);
					// lower-left
					drawText(-itd, itd, isFront, bitmap, useTiles);
					// lower-right
					drawText(itd, itd, isFront, bitmap, useTiles);
				}
			case NONE:
		}

		isFront = true;
		drawText(0, 0, isFront, bitmap, useTiles);

		bitmap.unlock();

		dirty = true;

		pendingPixelsChange = false;
	}

	override function drawText(posX:Int, posY:Int, isFront:Bool = true, ?bitmap:flash.display.BitmapData, useTiles:Bool = false)
	{
		blitText(posX, posY, isFront, bitmap);
	}

	override function set_background(value:Bool):Bool
	{
		if (background != value)
		{
			background = value;
			pendingPixelsChange = true;
		}

		return value;
	}

	override function set_backgroundColor(value:Int):Int
	{
		if (backgroundColor != value)
		{
			backgroundColor = value;
			pendingPixelsChange = true;
		}

		return value;
	}

	override function set_borderColor(value:Int):Int
	{
		if (borderColor != value)
		{
			borderColor = value;
			pendingPixelsChange = true;
		}

		return value;
	}

	override function get_width():Float
	{
		return width;
	}

	override function get_height():Float
	{
		return height;
	}
}
