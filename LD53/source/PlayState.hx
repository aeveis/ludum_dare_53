package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import global.G;
import global.TextConstants.TextNode;
import global.TextConstants;
import objs.Bird;
import objs.DustEmitter;
import objs.Object;
import objs.Parcel;
import objs.Tape;
import objs.TrailEmitter;
import ui.Hud;
import ui.TextBox;
import ui.TextPopup;
import ui.TextTrigger;
import util.Input;
import util.TiledLevel;
import util.ui.UIContainer.UILayout;
import util.ui.UIContainer.UIParent;
import util.ui.UIContainer.UIPlacement;
import util.ui.UIText;

class PlayState extends FlxState
{
	public static var instance:PlayState;

	public var level:TiledLevel;
	public var tilemap:FlxTilemap;
	public var bgtilemap:FlxTilemap;
	public var fadeComplete:Bool = false;
	public var followCam:FlxObject = null;
	public var frameCount:Int = 0;
	public var overlapFrame:Int = 0;

	public var dustEmit:DustEmitter;
	public var trailEmit:TrailEmitter;
	public var objects:FlxGroup;
	public var bird:Bird;
	public var interactPopup:TextPopup;
	public var tapes:FlxTypedGroup<Tape>;
	public var hud:Hud;

	public var textbox:TextBox;
	public var textTriggers:FlxGroup;
	public var textpopups:FlxGroup;

	public var totalTapeCount:Int = 0;
	public var currentTapeCount:Int = 0;

	override public function create()
	{
		super.create();
		instance = this;

		cameras = [camera];
		FlxG.mouse.useSystemCursor = true;
		FlxG.camera.bgColor = 0xffa8e0f6;
		FlxG.camera.pixelPerfectRender = false;

		Input.control = new Input();
		Input.control.platformerSetup();

		dustEmit = new DustEmitter();
		trailEmit = new TrailEmitter();
		textTriggers = new FlxGroup();
		objects = new FlxGroup();
		tapes = new FlxTypedGroup<Tape>();
		hud = new Hud();
		interactPopup = new TextPopup(0, 0);
		interactPopup.setState(PopupState.Hidden);

		textbox = new TextBox(AssetPaths.textbox__png, UIPlacement.Top, UISize.XFill(22), 0.5, UIParent.Camera(camera));
		textbox.setPortrait(AssetPaths.portraits__png, true, 16, 16);
		textbox.setPortraitBorderImage(AssetPaths.portrait_border__png, UILayout.sides(1));
		textbox.addAnim("bird", [0]);
		textbox.addAnim("bluebird", [1]);
		textbox.addAnim("sprout", [2]);
		textbox.playAnim("bird");
		textbox.visible = false;
		textpopups = new FlxGroup();

		level = new TiledLevel(AssetPaths.getFile("level" + G.level, AssetPaths.LOC_DATA, "tmx"));
		tilemap = level.loadTileMap("tiles", "tiles", false);

		level.loadObjects("entities", loadObj);
		FlxG.camera.follow(bird, FlxCameraFollowStyle.PLATFORMER);

		add(dustEmit);
		add(trailEmit);
		add(tilemap);
		add(objects);
		add(interactPopup);
		add(tapes);
		add(bird.parcel);
		add(bird);
		add(textbox);
		add(textpopups);
		add(textTriggers);
		add(hud);

		/*if (FlxG.sound.music == null)
			{
				FlxG.sound.playMusic("lookingAround", 0);
			}
			if (!G.startInput)
			{
				FlxG.sound.music.pause();
		}*/

		fade(0.3, true, fadeOnComplete);
	}

	public function loadObj(pobj:TiledObject, px:Float, py:Float)
	{
		var pname:String = pobj.name;

		switch (pname)
		{
			case "bird":
				bird = new Bird(px, py);
			case "parcel":
				bird.parcel.setPosition(px, py);
			case "tape":
				tapes.add(new Tape(px, py));
			/*case "platform":
					platforms.add(new Platform(px, py));
				case "text":
					py += pobj.height;

					var type:String = pobj.properties.contains("type") ? pobj.properties.get("type") : "default";
					var textArray:Array<String> = Reflect.getProperty(TextConstants, type);
					addTextTrigger(px, py, pobj.width, pobj.height, type, textArray); */

			default:
				var textID:String = "debug";
				textID = pobj.properties.contains("text") ? pobj.properties.get("text") : "debug";
				var type:String = pobj.properties.contains("type") ? pobj.properties.get("type") : null;
				var unskippable:Bool = type == "unskippable";
				var portrait:String = pobj.properties.contains("portrait") ? pobj.properties.get("portrait") : "sprout";
				var obj:Object = null;

				if (pname != "text")
				{
					if (pname == "npc")
					{
						pname = pobj.properties.contains("type") ? pobj.properties.get("type") : "sprout";
					}
					var unique:String = pobj.properties.contains("name") ? pobj.properties.get("name") : null;
					if (unique != null)
					{
						// obj = uniqueNpcs.get(uniq	ue);
						if (obj == null)
						{
							obj = new Object(px, py, pname);
							obj.setUnique(unique);
							// uniqueNpcs.set(unique, obj);
						}
						else
						{
							obj.setup(px, py, pname);
						}
					}
					else
					{
						obj = new Object(px, py, pname);
					}

					pobj.flippedHorizontally ? obj.facing = FlxDirectionFlags.LEFT : obj.facing = FlxDirectionFlags.RIGHT;
					objects.add(obj);
				}

				if (textID != null)
				{
					if (pname == "text")
					{
						py += pobj.height;
					}

					var textNode:TextNode = Reflect.getProperty(TextConstants.instance, textID);
					if (textNode == null)
					{
						textNode = TextConstants.instance.error;
					}

					var txt = new TextTrigger(px - 8, py - 8, pobj.width + 16, pobj.height + 16, textID, textNode);
					txt.unskippable = unskippable;
					txt.setTypeSound("birdtype", 3);

					if (obj != null)
					{
						obj.textTrigger = txt;
					}
					textNode.portraits[0] = txt.animName = portrait;

					textTriggers.add(txt);
					if (unskippable)
					{
						return;
					}
					txt.addTextPopup(new TextPopup(px, py - 8));
					textpopups.add(txt.textpopup);
				}
		}
	}

	override public function update(elapsed:Float)
	{
		frameCount++;
		Input.control.update(elapsed);
		if (!fadeComplete)
			return;

		if (!G.startInput)
		{
			if (Input.control.any || Input.control.keys.get("select").pressed)
			{
				G.startInput = true;
				// FlxG.sound.music.fadeIn(1, 0, 0.5);
				// remove(title, true);
				// title.kill();
				/*if (Input.control.keys.get("select").justPressed)
					{
						G.playSound("birdtype0");
				}*/
			}
			if (!FlxG.overlap(textTriggers, bird, checkText))
			{
				textbox.hasMoreText = false;
				if (Input.control.keys.get("select").justPressed)
				{
					textbox.skipTyping();
				}
			}
			FlxG.collide(tilemap, bird);
			if (!bird.parcel.held)
			{
				FlxG.collide(tilemap, bird.parcel);
			}
			super.update(elapsed);
			// FlxG.overlap(textTriggers, bird, checkText);

			return;
		}
		FlxG.collide(tilemap, bird);
		if (bird.parcel.held)
		{
			tilemap.overlapsWithCallback(bird.parcel, dropParcel);
		}
		else
		{
			FlxG.collide(tilemap, bird.parcel);
			FlxG.overlap(bird.parcel, bird, pickupParcel);
		}
		FlxG.overlap(tapes, bird, tapePickup);
		// FlxG.collide(platforms, player, checkPlatform);
		if (!FlxG.overlap(textTriggers, bird, checkText))
		{
			textbox.hasMoreText = false;
			if (textbox.visible)
			{
				textbox.close();
			}
		}

		super.update(elapsed);

		if (Input.control.keys.get("restart").justPressed)
		{
			restart();
		}
	}

	public function dropParcel(tile:FlxObject, parcelobj:FlxObject):Bool
	{
		var parcel:Parcel = cast parcelobj;
		if (Math.abs(tile.x - parcel.x) < 3 && Math.abs(tile.y - parcel.y) < 3)
		{
			if (parcel.held)
			{
				hud.addHealth(-0.1);
				parcel.setHealth(hud.parcelHealth);
			}
			parcel.held = false;
			if (parcel.x > tile.x)
			{
				parcel.lastEdgeTouching = FlxDirectionFlags.LEFT;
				parcel.x = tile.x + tile.width;
			}
			if (parcel.x < tile.x)
			{
				parcel.lastEdgeTouching = FlxDirectionFlags.RIGHT;
				parcel.x = tile.x - parcel.width;
			}
			return true;
		}
		return false;
	}

	public function pickupParcel(pparcel:Parcel, pbird:Bird)
	{
		pparcel.onBird = true;
		interactPopup.setPos(pparcel.x, pparcel.y - 9);
		interactPopup.setState(PopupState.Show);
		if (Input.control.keys.get("select").justPressed)
		{
			if (pparcel.lastEdgeTouching == FlxDirectionFlags.LEFT)
			{
				pbird.x = pparcel.x + 3;
			}
			if (pparcel.lastEdgeTouching == FlxDirectionFlags.RIGHT)
			{
				pbird.x = pparcel.x + 1;
			}
			interactPopup.setState(PopupState.Hide);
			pparcel.held = true;
			if (currentTapeCount > 0)
			{
				hud.addHealth(0.01 * currentTapeCount);
				pparcel.setHealth(hud.parcelHealth);
				currentTapeCount = 0;
			}
			new FlxTimer().start(0.2, timer ->
			{
				bird.parcel.lastEdgeTouching = FlxDirectionFlags.NONE;
			});
		}
	}

	public function tapePickup(tape:Tape, pbird:Bird)
	{
		if (!tape.alive)
			return;
		tape.kill();
		dustEmit.x = tape.x + 2;
		dustEmit.y = tape.y + 2;
		dustEmit.tapePoof();
		G.playSound(AssetPaths.collect__ogg);

		totalTapeCount++;
		hud.tapeCount = totalTapeCount + "";
		if (bird.parcel.held)
		{
			hud.addHealth(0.01);
			bird.parcel.setHealth(hud.parcelHealth);
		}
		else
		{
			currentTapeCount++;
		}
	}

	public function playTrigger(trigger:TextTrigger)
	{
		var textToPlay:String = "";

		if (trigger.name == "ending")
		{
			if (!bird.parcel.held)
			{
				TextConstants.instance.ending.texts = ["Where is the parcel? Please go get it!"];
			}
			else if (hud.parcelHealth == 1.0)
			{
				TextConstants.instance.ending.texts = [
					"Thanks for delivering the parcel! It is in perfect condition! Great job!",
					"Thanks for playing! Press R to replay the game."
				];
			}
			else if (hud.parcelHealth > 0.75)
			{
				TextConstants.instance.ending.texts = [
					"Thanks for delivering the parcel! It's " + Math.round(hud.parcelHealth * 100) + "% intact. Nice job!",
					"Thanks for playing! Press R to replay the game."
				];
			}
			else if (hud.parcelHealth > 0.50)
			{
				TextConstants.instance.ending.texts = [
					"Thanks for delivering the parcel! It's ehh " + Math.round(hud.parcelHealth * 100) + "% intact. Good effort.",
					"Thanks for playing! Press R to replay the game."
				];
			}
			else if (hud.parcelHealth >= 0.25)
			{
				TextConstants.instance.ending.texts = [
					"Thanks for delivering the parcel! This parcel just together at " + Math.round(hud.parcelHealth * 100) + "%. Please be more careful.",
					"Thanks for playing! Press R to replay the game."
				];
			}
			else if (hud.parcelHealth < 0.25)
			{
				TextConstants.instance.ending.texts = [
					"The parcel is delivered... but it's totally destroyed and only " + Math.round(hud.parcelHealth * 100) + "% is left.",
					"Thanks for playing! Press R to replay the game."
				];
			}
			trigger.setTextNode(TextConstants.instance.ending);
		}
		textToPlay = trigger.getText();

		Bird.control = false;
		textbox.visible = true;
		trigger.setPopupState(PopupState.Open);
		textbox.playAnim(trigger.animName);

		textbox.hasMoreText = true;
		textbox.setStatus(TextBoxStatus.Skip);
		textbox.playText(textToPlay, trigger.typeSoundName, trigger.typeSoundRandomCount);

		if (trigger.state == TextTriggerState.Done)
		{
			textbox.hasMoreText = false;
		}
		else
		{
			trigger.state = TextTriggerState.Playing;
		}
	}

	public function checkText(trigger:TextTrigger, player:FlxObject)
	{
		if (overlapFrame == frameCount || !trigger.visible)
		{
			return;
		}
		trigger.onTrigger = true;
		if (!textbox.visible)
		{
			trigger.setPopupState(PopupState.Show);
		}

		switch (trigger.state)
		{
			case TextTriggerState.Ready:
				if (!Input.control.keys.get("select").justPressed && !trigger.unskippable)
				{
					return;
				}
				playTrigger(trigger);

			case TextTriggerState.Playing:
				if (Input.control.keys.get("select").justPressed)
				{
					if (textbox.isDoneTyping)
					{
						// trigger.state = TextTriggerState.Ready;
						textbox.setStatus(TextBoxStatus.Next);
						playTrigger(trigger);
					}
					else
					{
						textbox.skipTyping();
						textbox.setStatus(TextBoxStatus.Next);
					}
				}
				if (textbox.isDoneTyping)
				{
					textbox.setStatus(TextBoxStatus.Next);
				}
			case TextTriggerState.Done:
				if (textbox.isDoneTyping)
				{
					textbox.setStatus(TextBoxStatus.Done);
				}
				if (Input.control.keys.get("select").justPressed)
				{
					if (textbox.isDoneTyping)
					{
						Bird.control = true;
						textbox.visible = false;
						if (trigger.oneshot)
						{
							trigger.visible = false;
							return;
						}
						trigger.resetTrigger();
					}
					else
					{
						textbox.skipTyping();
					}
				}
		}
		overlapFrame = frameCount;
	}

	public function fade(pDuration:Float, pFadeIn:Bool = false, ?pCallback:Void->Void, ?pColor:Int)
	{
		if (pColor == null)
		{
			pColor = 0xffa8e0f6;
		}
		/*if (textbox.visible)
			{
				textbox.textCam.fade(pColor, pDuration, pFadeIn);
		}*/
		camera.fade(pColor, pDuration, pFadeIn, pCallback);
	}

	public function restart(fadeTime:Float = 0.3):Void
	{
		fade(fadeTime, false, refreshState);
		fadeComplete = false;
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(.3);
		}
	}

	public function fadeOnComplete():Void
	{
		fadeComplete = true;
	}

	public function refreshState():Void
	{
		G.startInput = false;
		FlxG.switchState(new PlayState());
	}
}
