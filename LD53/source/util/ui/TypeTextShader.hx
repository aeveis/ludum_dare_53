package util.ui;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

typedef ColorTag =
{
	enabled:Float,
	startIndex:Int,
	endIndex:Int,
	color:FlxColor
}

typedef AnimTag =
{
	type:AnimType,
	startIndex:Int,
	endIndex:Int,
}

typedef LineRatio =
{
	start:Float,
	end:Float
}

@:enum
abstract AnimType(Float) from Float to Float
{
	var Normal = 0.0;
	var Wave = 1.0;
	var Shaky = 2.0;
}

@:enum
abstract ERegTag(String) from String to String
{
	var Tag = "tag"; // special check for tag
	var TagAll = "tagall"; // special check for all tags
	var NewLine = "newline"; // special check for newline character
	var Color = "color";
	var Anim = "anim";
}

class TypeTextShader extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		#ifdef GL_ES
			precision mediump float;
		#endif
		
		uniform float ratio;
		uniform float timer;
		uniform float lines;
		// crunchline: startline + endline/1000
		// crunchX: startx*1000 + endx
		// max of 4 animated segments (type, crunchLine, crunchX)
		uniform vec3 anim0;
		uniform vec3 anim1;
		uniform vec3 anim2;
		uniform vec3 anim3;
		// max of 5 colored segments (enabled, crunchLine, crunchX)
		uniform vec3 colPos0;
		uniform vec3 colPos1;
		uniform vec3 colPos2;
		uniform vec3 colPos3;
		uniform vec3 colPos4;
		// max of 5 colors (r,g,b)		
		uniform vec3 col0;
		uniform vec3 col1;
		uniform vec3 col2;
		uniform vec3 col3;
		uniform vec3 col4;

        //uniform vec2 typePos;
		float lineOffset = 0.15;
	
		float sectionMask(vec2 uv, float crunchLine, float crunchX)
		{
			float startline = floor(crunchLine);
			float endline = floor(mod(crunchLine, 1.0) * 1000.0 + 0.01);
			float line = 1.0/(lines + lineOffset);
			float endy = endline/(lines + lineOffset);
			float starty = max(0.0, (startline/(lines + lineOffset)) - line);

			float startx = floor(crunchX)/1000.0;
			float endx = mod(crunchX, 1.0);
			float mask = float(
				((startline == endline) && uv.y >= starty && uv.y < endy && uv.x >= startx && uv.x < endx) ||
				((endline != startline) && ((uv.y < (starty + line) && uv.y >= starty && uv.x >= startx) || 
						(uv.y >= (endy - line) && uv.y < endy && uv.x < endx) || 
						(uv.y >= (starty + line) && uv.y < (endy - line))))
				);

			return mask;
		}

        float circle(vec2 uv, vec2 pos, float radius)
        {
            float x = uv.x - pos.x;
            float y = uv.y - pos.y;
            float dist = sqrt(x*x + y*y);
            if(dist > radius / 2.0) 
            {
                return 0.0;
            }
            else 
            {
                return 1.0;
            }
        }

		void main()
		{
			vec2 uv = openfl_TextureCoordv;

			float totalratio = ratio * lines;
			float yline = uv.y * lines + lineOffset;

			float fadeThreshold = 0.05;
			float lineratio = mod(totalratio, 1.0)*(1.0 + fadeThreshold) - fadeThreshold;
			float fade = 0.0;

			fade = float(uv.x > lineratio && ceil(yline+0.01) > totalratio) * smoothstep(lineratio, lineratio + fadeThreshold, uv.x);
            float offset = fade/(lines * 5.0) * (1.0 - mod(yline, 1.0));
			uv.y += offset;
			uv.x += offset/4.0;

			// Wave 1 
			float wave = 0.02/lines * sin(uv.x * 10.0 + timer * 6.28);

			// Shaky 2
			float shaky = 0.02/lines * sin(uv.x * 50.0 + timer * 47.12);

            float animMask = 0.0;

			if(anim0.x != 0.0)
			{
				float anim = wave * float(anim0.x == 1.0) + shaky * float(anim0.x == 2.0);
				animMask += anim * sectionMask(uv, anim0.y, anim0.z);
			}
			if(anim1.x != 0.0)
			{
				float anim = wave * float(anim1.x == 1.0) + shaky * float(anim1.x == 2.0);
				animMask += anim * sectionMask(uv, anim1.y, anim1.z);
			}
			if(anim2.x != 0.0)
			{
				float anim = wave * float(anim2.x == 1.0) + shaky * float(anim2.x == 2.0);
				animMask += anim * sectionMask(uv, anim2.y, anim2.z);
			}
			if(anim3.x != 0.0)
			{
				float anim = wave * float(anim3.x == 1.0) + shaky * float(anim3.x == 2.0);
				animMask += anim * sectionMask(uv, anim3.y, anim3.z);
			}
            uv.y += animMask * (1.0 - fade);

			vec4 col = texture2D(bitmap, uv);

			col *= float(floor(yline) <= totalratio);

			if(colPos0.x != 0.0)
			{
				float colorMask = sectionMask(uv, colPos0.y, colPos0.z);
				col.rgb *= col0 * colorMask + (1.0 - colorMask);
			}
			if(colPos1.x != 0.0)
			{
				float colorMask = sectionMask(uv, colPos1.y, colPos1.z);
				col.rgb *= col1 * colorMask + (1.0 - colorMask);
			}
			if(colPos2.x != 0.0)
			{
				float colorMask = sectionMask(uv, colPos2.y, colPos2.z);
				col.rgb *= col2 * colorMask + (1.0 - colorMask);
			}
			if(colPos3.x != 0.0)
			{
				float colorMask = sectionMask(uv, colPos3.y, colPos3.z);
				col.rgb *= col3 * colorMask + (1.0 - colorMask);
			}
			if(colPos4.x != 0.0)
			{
				float colorMask = sectionMask(uv, colPos4.y, colPos4.z);
				col.rgb *= col4 * colorMask + (1.0 - colorMask);
			}

			float alphaMask = float(col.a > 0.0);
			col *= (1.0 - fade) * alphaMask + (1.0 - alphaMask);
			
            //col.r += circle(uv, typePos, 0.01);
			gl_FragColor = col;
			if(hasColorTransform)
			{
				gl_FragColor.rgb *= openfl_ColorMultiplierv.rgb;
			}
		}
	')
	public function new()
	{
		super();
	}
}
