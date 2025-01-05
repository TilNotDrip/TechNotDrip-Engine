package funkin.objects.ui.freeplay;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import funkin.shaders.ui.GaussianBlurShader;

class FreeplayCapsule extends FlxSpriteGroup
{
	/**
	 * If the capsule should show selecting.
	 */
	public var selected(default, set):Bool = false;

	var capsule:FunkinSprite;
	var capsuleText:FreeplayCapsuleText;
	var icon:PixelIcon;

	var realScaled:Float = 0.8;

	/**
	 * The pos you want the capsule to lerp to.
	 */
	public var lerpPos:FlxPoint = FlxPoint.get();

	/**
	 * Lerp position.
	 */
	public var doLerp:Bool = true;

	public function new()
	{
		super();

		capsule = new FunkinSprite().loadFrames('ui/freeplay/capsule/default');
		capsule.addAnimation('selected', 'mp3 capsule w backing0', null, 24);
		capsule.addAnimation('unselected', 'mp3 capsule w backing NOT SELECTED', null, 24);
		capsule.scale.set(realScaled, realScaled);
		add(capsule);

		capsuleText = new FreeplayCapsuleText(capsule.width * 0.26, 45, 'Random', Std.int(40 * realScaled));
		add(capsuleText);

		icon = new PixelIcon(160, 35);
		add(icon);

		updateSelected();
	}

	/**
	 * "Initializes" the capsule.
	 * @param name The name of the capsule.
	 * @param icon The icon. Can be null.
	 */
	public function init(name:String, ?iconID:Null<String> = null):Void
	{
		capsuleText.text = name;

		if (icon != null)
			icon.setCharacter(iconID);
	}

	function set_selected(value:Bool):Bool
	{
		selected = value;
		updateSelected();
		return selected;
	}

	function updateSelected():Void
	{
		capsuleText.alpha = selected ? 1 : 0.6;
		capsuleText.textBlur.visible = selected ? true : false;
		capsule.offset.x = selected ? 0 : -5;
		capsule.animation.play(selected ? "selected" : "unselected");

		if (capsuleText.tooLong)
			capsuleText.resetText();

		if (selected && capsuleText.tooLong)
			capsuleText.initMove();
	}

	override public function update(elapsed:Float):Void
	{
		if (doLerp)
		{
			x = MathUtil.coolLerp(x, lerpPos.x, 0.3);
			y = MathUtil.coolLerp(y, lerpPos.y, 0.4);
		}

		super.update(elapsed);
	}

	/**
	 * Get the y position to show in Freeplay.
	 * @param index The freeplay position.
	 * @return The y position.
	 */
	public function intendedY(index:Int):Float
	{
		return (index * ((height * realScaled) + 10)) + 120;
	}
}

private class FreeplayCapsuleText extends FlxSpriteGroup
{
	/**
	 * The text shown on the capsule.
	 */
	public var text(default, set):String;

	/**
	 * At what width to clip the text at.
	 */
	public var clipWidth(default, set):Int = 255;

	/**
	 * What color this capsule should glow.
	 */
	public var glowColor(default, set):FlxColor = 0xFF00CCFF;

	/**
	 * Blurred Text.
	 */
	public var textBlur:FlxText;

	/**
	 * White Text.
	 */
	public var textWhite:FlxText;

	/**
	 * If the song is clipped or not.
	 */
	public var tooLong:Bool = false;

	var moveTimer:FlxTimer;
	var moveTween:FlxTween;

	public function new(x:Float, y:Float, text:String, size:Float)
	{
		moveTimer = new FlxTimer();

		super(x, y);

		textBlur = initText(text, size);
		textBlur.shader = new GaussianBlurShader(1);
		textBlur.color = glowColor;
		add(textBlur);

		textWhite = initText(text, size);
		textWhite.color = 0xFFFFFFFF;
		add(textWhite);

		this.text = text;
	}

	function initText(text:String, size:Float):FlxText
	{
		var text:FlxText = new FlxText(0, 0, 0, text, Std.int(size));
		text.font = Paths.location.get("ui/fonts/5by7.ttf");
		return text;
	}

	/**
	 * Checks if the text if it's too long, and clips if it is.
	 */
	public function checkClipWidth()
	{
		tooLong = textWhite.width > clipWidth;

		if (textWhite.width > clipWidth)
		{
			textBlur.clipRect = new FlxRect(0, 0, clipWidth, textBlur.height);
			textWhite.clipRect = new FlxRect(0, 0, clipWidth, textWhite.height);
		}
		else
		{
			textBlur.clipRect = null;
			textWhite.clipRect = null;
		}
	}

	function set_text(value:String):String
	{
		if (value == null)
			return value;

		textBlur.text = value;
		textWhite.text = value;
		changeWhiteGlow(glowColor);
		checkClipWidth();

		return value;
	}

	function set_clipWidth(value:Int):Int
	{
		resetText();
		clipWidth = value;
		checkClipWidth();
		return clipWidth;
	}

	function set_glowColor(value:FlxColor):FlxColor
	{
		textBlur.color = value;
		changeWhiteGlow(value);
		return value;
	}

	function changeWhiteGlow(color:FlxColor):Void
	{
		textWhite.textField.filters = [
			new openfl.filters.GlowFilter(color, 1, 5, 5, 210, openfl.filters.BitmapFilterQuality.MEDIUM),
		];
	}

	/**
	 * Resets text position.
	 */
	public function resetText():Void
	{
		if (moveTween != null)
			moveTween.cancel();

		if (moveTimer != null)
			moveTimer.cancel();

		textWhite.offset.x = 0;
		textWhite.clipRect = new FlxRect(textWhite.offset.x, 0, clipWidth, textWhite.height);
		textBlur.clipRect = new FlxRect(textBlur.offset.x, 0, clipWidth, textBlur.height);
	}

	/**
	 * Initializes the text moving if clipped.
	 */
	public function initMove():Void
	{
		moveTimer.start(0.6, (timer) ->
		{
			moveText();
		});
	}

	function moveText(?resetPos:Bool = false):Void
	{
		var distToMove:Float = textWhite.width - clipWidth;

		if (resetPos)
			distToMove = 0;

		moveTween = FlxTween.tween(textWhite.offset, {x: distToMove}, 2, {
			onUpdate: (_) ->
			{
				textWhite.clipRect = new FlxRect(textWhite.offset.x, 0, clipWidth, textWhite.height);
				textBlur.offset = textWhite.offset;
				textBlur.clipRect = new FlxRect(textWhite.offset.x, 0, clipWidth, textBlur.height);
			},
			onComplete: (_) ->
			{
				moveTimer.start(0.3, (timer) ->
				{
					moveText(!resetPos);
				});
			},
			ease: FlxEase.sineInOut
		});
	}

	/**
	 * Flickers the text.
	 * Used when selecting the song.
	 */
	public function flickerText():Void
	{
		resetText();

		var flickerState:Bool = false;
		new FlxTimer().start(1 / 24, (_) ->
		{
			if (flickerState)
			{
				textWhite.blend = ADD;
				textBlur.blend = ADD;
				textBlur.color = 0xFFFFFFFF;
				textWhite.color = 0xFFFFFFFF;
				changeWhiteGlow(0xFFFFFF);
			}
			else
			{
				textBlur.color = glowColor;
				textWhite.color = 0xFFDDDDDD;
				changeWhiteGlow(0xDDDDDD);
			}
			flickerState = !flickerState;
		}, 19);
	}
}
