package funkin.objects;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;
import flxanimate.FlxAnimate;
import funkin.structures.ObjectStructure;

/**
 * This is a sprite class that adds on to the already existing FlxSprite.
 */
class FunkinSprite extends FlxSprite
{
	/**
	 * Draws this `FunkinSprite`, but invisible.
	 * This is basically visible/alpha, but it doesn't lag when you make it visible again.
	 */
	public var doInvisibleDraw:Bool = false;

	/**
	 * The Animate Atlas Object if the animation is one.
	 */
	public var atlas:FlxAnimate;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
	}

	/**
	 * Loads or creates a texture and applies it to this sprite.
	 * @param path The asset path. (If `path` starts with a **#** then a color will be made instead and rectWidth + rectHeight will determine its size.)
	 * @param rectWidth If the path is a color then how big should it's width be?
	 * @param rectHeight If the path is a color then how big should it's height be?
	 * @return This `FunkinSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadTexture(path:String = '#000000', rectWidth:Int = 1, rectHeight:Int = 1):FunkinSprite
	{
		if (path.startsWith('#'))
		{
			makeGraphic(rectWidth, rectHeight, FlxColor.fromString(path));
		}
		else
		{
			loadGraphic(Paths.content.imageGraphic(path));
		}

		return this;
	}

	/**
	 * Loads frames and applies it to this sprite.
	 * @param path The path of where frames should load from.
	 * @return This `FunkinSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadFrames(path:String):FunkinSprite
	{
		if (atlas != null)
		{
			atlas.destroy();
			atlas = null;
		}

		if (Paths.location.exists(path + '.xml'))
		{
			frames = Paths.content.sparrowAtlas(path);
		}
		else if (Paths.location.exists(path + '/Animation.json'))
		{
			atlas = new FlxAnimate(0, 0, Paths.location.get(path), {
				ShowPivot: false
			});
		}

		return this;
	}

	override public function destroy():Void
	{
		if (atlas != null)
			atlas.destroy();

		super.destroy();
	}

	override public function draw():Void
	{
		var oldAlpha:Float = alpha;
		if (doInvisibleDraw)
			alpha = 0.0001;

		if (atlas != null)
		{
			updateAtlasDummy();
			atlas.draw();
		}
		else
		{
			super.draw();
		}

		if (doInvisibleDraw)
		{
			alpha = oldAlpha;

			if (atlas != null)
				atlas.alpha = alpha;
		}
	}

	override public function update(elapsed:Float):Void
	{
		if (atlas != null)
			atlas.update(elapsed);

		super.update(elapsed);
	}

	/**
	 * Updates the Atlas dummy's values, so it looks like it belongs to this sprite.
	 * @see The Original Code: https://github.com/CodenameCrew/CodenameEngine/blob/f6deda2c84984202effdfc5f6b577c2d956aa7b5/source/funkin/backend/FunkinSprite.hx#L209C2-L232C3
	 */
	@:privateAccess
	public function updateAtlasDummy():Void
	{
		atlas.cameras = cameras;
		atlas.scrollFactor = scrollFactor;
		atlas.scale = scale;
		atlas.offset = offset;
		atlas.x = x;
		atlas.y = y;
		atlas.angle = angle;
		atlas.alpha = alpha;
		atlas.visible = visible;
		atlas.flipX = flipX;
		atlas.flipY = flipY;
		atlas.shader = shader;
		atlas.antialiasing = antialiasing;
		atlas.colorTransform = colorTransform;
	}

	// ANIMATION BINDINGS

	/**
	 * The current playing animation.
	 */
	public var currentAnim(default, null):String = '';

	var animationStunned:Bool = false;

	/**
	 * Plays an animation.
	 * @param name The name of the animation to play.
	 * @param restart Should the animation restart if it's already playing?
	 * @param stunAnimations Should the animations be "stunned" until this one is finished?
	 * @param reversed Should the animation be reversed?
	 */
	public function playAnimation(name:String, ?restart:Bool = false, ?stunAnimations:Bool = false, ?reversed:Bool = false):Void
	{
		if (animationStunned)
			return;

		if (atlas != null)
			atlas.anim.play(name, restart, reversed);
		else
			animation.play(name, restart, reversed);

		animationStunned = stunAnimations;
		currentAnim = name;
	}

	/**
	 * Adds an Animation to the sprite.
	 * @param name The name of the animation to add.
	 * @param anim The actual animation name.
	 * @param indices The frame indices to use. (Optional)
	 * @param frameRate The Frame Rate of the animation. (Optional)
	 * @param looped Should the animation loop? (Optional)
	 */
	public function addAnimation(name:String, anim:String, ?indices:Array<Int> = null, ?frameRate:Float = 24, ?looped:Bool = true):Void
	{
		if (atlas != null)
		{
			if (indices != null && indices.length > 0)
				atlas.anim.addBySymbolIndices(name, anim + '\\', indices, frameRate, looped);
			else
				atlas.anim.addBySymbol(name, anim + '\\', frameRate, looped);
		}
		else
		{
			if (indices != null && indices.length > 0)
				animation.addByIndices(name, anim + '0', indices, '', frameRate, looped);
			else
				animation.addByPrefix(name, anim + '0', frameRate, looped);
		}
	}

	/**
	 * Is the current animation null?
	 */
	public var animationIsNull(get, never):Bool;

	function get_animationIsNull():Bool
	{
		return (atlas != null) ? atlas.anim.curSymbol == null : animation.curAnim == null;
	}

	/**
	 * Is the current animation finished?
	 */
	public var animFinished(get, never):Bool;

	function get_animFinished():Bool
	{
		if (animationIsNull)
			return false;

		return ((atlas != null) ? atlas.anim.finished : animation.curAnim.finished) ?? false;
	}

	/**
	 * Finishes the current animation playing.
	 */
	public function finishAnimation():Void
	{
		if (animationIsNull)
			return;

		if (atlas != null)
			atlas.anim.curFrame = atlas.anim.length - 1;
		else
			animation.curAnim.finish();
	}

	/**
	 * Is the current animation paused?
	 */
	public var animPaused(get, set):Bool;

	function get_animPaused():Bool
	{
		if (animationIsNull)
			return false;

		return ((atlas != null) ? atlas.anim.isPlaying : animation.curAnim.paused) ?? false;
	}

	function set_animPaused(value:Bool):Bool
	{
		if (animationIsNull)
			return value;

		if (atlas != null)
		{
			if (value)
				atlas.anim.pause();
			else
				atlas.anim.resume();
		}
		else
		{
			if (value)
				animation.curAnim.pause();
			else
				animation.curAnim.resume();
		}

		return value;
	}

	/**
	 * Checks if the animation specified exists.
	 * @param name The animation name to check for.
	 * @return If the animation exists.
	 */
	@:privateAccess
	public function animationExists(name:String):Bool
	{
		if (atlas != null)
			return atlas.anim.symbolDictionary.get(name) != null;
		else
			return animation?.exists(name) ?? false;
	}

	/**
	 * Called when an animation is finished.
	 */
	public var onAnimFinished(get, never):FlxTypedSignal<String->Void>;

	var _onAnimFinished:FlxTypedSignal<String->Void>;

	function get_onAnimFinished():FlxTypedSignal<String->Void>
	{
		if (_onAnimFinished == null)
		{
			_onAnimFinished = new FlxTypedSignal<String->Void>();

			if (atlas != null)
			{
				atlas.anim.onComplete.add(() ->
				{
					_onAnimFinished.dispatch(currentAnim);
				});
			}
			else
			{
				animation.onFinish.add((_) ->
				{
					_onAnimFinished.dispatch(currentAnim);
				});
			}
		}

		return _onAnimFinished;
	}
}

typedef FunkinSpriteGroup = FlxTypedSpriteGroup<FunkinSprite>
