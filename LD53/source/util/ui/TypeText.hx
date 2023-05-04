package util.ui;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;
import util.ui.TypeTextShader;

/**
 * Type Text that uses a shader to run typing animation to reduce cost of processing letters
 * Processes up to 4 animation tags <anim=wave|shake></anim>
 * Processes up to 5 color tags <color=[FlxColor macros] | 0x[ffffff]></color>
 * @author aeveis
 */
class TypeText extends FlxText
{
	static public var noTyping:Bool = false;

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
		text = parseTag(p_text);
		if (textField != null)
		{
			var ot:String = textField.text;
			textField.text = text;
			_regen = (textField.text != ot) || _regen;
			if (_regen)
			{
				drawFrame(true);
				refreshShaderValues();
			}
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
	public function new(p_x:Float = 0, p_y:Float = 0, p_fieldWidth:Float = 0, ?p_text:String, p_size = 8, p_embeddedFont = true, p_startTyping = false)
	{
		colorTags = new Array<ColorTag>();
		animTags = new Array<AnimTag>();
		lineDoneRatio = new Array<LineRatio>();
		super(p_x, p_y, p_fieldWidth, p_text, p_size, p_embeddedFont);

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

	public function refreshShaderValues()
	{
		lines = textField.numLines;
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
			var endIndex:Int = textField.getLineLength(i) - 1;
			var endRect:Rectangle = null;
			while (endRect == null && endIndex < text.length)
			{
				endRect = textField.getCharBoundaries(endIndex);
				endIndex--;
			}
			var endlineRatio:Float = endRect.x / textField.width;
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

		var lineratio:Float = ratio * lines;
		var xpos:Float = lineratio % 1.0;
		var ypos:Float = Math.floor(lineratio) / lines + 0.5 / lines;
		// typeTextShader.typePos.value = [xpos, ypos];
		if (textField.getCharIndexAtPoint(xpos * fieldWidth, ypos * height) == -1)
			return;

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
		// textField.hitTestPoint();
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

	private function crunchAnimTag(tag:AnimTag):Array<Float>
	{
		if (tag.type == AnimType.Normal)
			return [0, 0, 0];

		var endRect:Rectangle = null;
		var endIndex:Int = tag.endIndex;
		var toEndofText:Bool = false;
		if (endIndex >= text.length)
		{
			endIndex = text.length - 1;
			toEndofText = true;
		}
		while (endRect == null && endIndex < text.length)
		{
			endRect = textField.getCharBoundaries(endIndex);
			endIndex++;
		}
		endIndex--;
		var startLine:Int = textField.getLineIndexOfChar(tag.startIndex) + 1;
		var endLine:Int = textField.getLineIndexOfChar(endIndex) + 1;
		var width = textField.width;
		var startX:Float = textField.getCharBoundaries(tag.startIndex).x / width;

		var endX:Float = (endRect.x + (toEndofText ? endRect.width : 0)) / width;
		return [tag.type, startLine + endLine / 1000.0, Math.floor(startX * 1000.0) + endX];
	}

	private function crunchColorTag(tag:ColorTag):Array<Float>
	{
		if (tag.enabled == 0.0)
			return [0, 0, 0];

		var endRect:Rectangle = null;
		var endIndex:Int = tag.endIndex;
		var toEndofText:Bool = false;
		if (endIndex >= text.length)
		{
			endIndex = text.length - 1;
			toEndofText = true;
		}
		while (endRect == null && endIndex < text.length)
		{
			endRect = textField.getCharBoundaries(endIndex);
			endIndex++;
		}
		endIndex--;
		var startLine:Int = textField.getLineIndexOfChar(tag.startIndex) + 1;
		var endLine:Int = textField.getLineIndexOfChar(endIndex) + 1;
		var width = textField.width;
		var startX:Float = textField.getCharBoundaries(tag.startIndex).x / width;
		var endX:Float = (endRect.x + (toEndofText ? endRect.width : 0)) / width;
		return [1.0, startLine + endLine / 1000.0, Math.floor(startX * 1000.0) + endX];
	}

	private function setColorFromTag(tag:ColorTag):Array<Float>
	{
		return [tag.color.redFloat, tag.color.greenFloat, tag.color.blueFloat];
	}
}
