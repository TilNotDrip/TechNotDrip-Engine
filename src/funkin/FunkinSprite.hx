package funkin;

import animate.FlxAnimate;
import animate.FlxAnimateFrames;
import flixel.animation.FlxAnimation;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.util.FlxSignal.FlxTypedSignal;

using funkin.util.FlxAnimateUtil;

/**
 * This is a sprite class that adds on to the already existing FlxSprite.
 */
class FunkinSprite extends FlxAnimate
{
  /**
   * Draws this `FunkinSprite`, but invisible.
   * This is basically visible/alpha, but it doesn't lag when you make it visible again.
   */
  public var doInvisibleDraw:Bool = false;

  /**
   * Settings to use when initializing texture atlases.
   */
  public var atlasSettings:FlxAnimateSettings = {};

  public function new(x:Float = 0, y:Float = 0)
  {
    super(x, y);
  }

  /**
   * Loads or creates a texture and applies it to this sprite.
   * @param path The asset path of the texture.
   * @param width What should the width of the sprite be?
   * @param height What should the height of the sprite be?
   * @return This `FunkinSprite` instance (nice for chaining stuff together, if you're into that).
   */
  public function loadTexture(path:String = '#000000', width:Int = 0, height:Int = 0):FunkinSprite
  {
    var rectColor:Null<FlxColor> = FlxColor.fromString(path);

    var graphic:FlxGraphic =
      {
        if (rectColor != null)
          FlxG.bitmap.create(1, 1, rectColor, false);
        else
          Paths.content.imageGraphic(path);
      }

    loadGraphic(graphic);
    setGraphicSize(width, height);
    updateHitbox();

    return this;
  }

  /**
   * Loads frames and applies it to this sprite.
   * @param path The path of where frames should load from.
   * @param forcedType Which type to force. If null, it will be determined automatically.
   * @return This `FunkinSprite` instance (nice for chaining stuff together, if you're into that).
   */
  public function loadFrames(path:String, ?forcedType:Null<String>):FunkinSprite
  {
    if (Paths.location.exists(path + '.xml'))
    {
      frames = Paths.content.sparrowAtlas(path);
    }
    else if (Paths.location.exists(path + '/Animation.json'))
    {
      frames = Paths.content.animateAtlas(path, atlasSettings);
    }

    return this;
  }

  override public function draw():Void
  {
    var oldAlpha:Float = alpha;
    if (doInvisibleDraw)
      alpha = 0.0001;

    super.draw();

    if (doInvisibleDraw)
    {
      alpha = oldAlpha;
    }
  }

  #if FLX_DEBUG
  override public function drawDebug():Void
  {
    if (doInvisibleDraw)
      return;

    super.drawDebug();
  }
  #end

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
    var atlasAnimList:Array<String> = super.getAnimateAnimations();

    if (atlasAnimList.contains(anim))
    {
      super.addAnimateAtlasAnimation(name, anim, indices, frameRate, looped);
      return;
    }

    if (indices != null && indices.length > 0)
      animation.addByIndices(name, anim + '0', indices, '', frameRate, looped);
    else
      animation.addByPrefix(name, anim + '0', frameRate, looped);
  }

  /**
   * Is the current animation null?
   */
  public var animationIsNull(get, never):Bool;

  function get_animationIsNull():Bool
  {
    return animation.curAnim == null;
  }

  /**
   * Is the current animation finished?
   */
  public var animFinished(get, never):Bool;

  function get_animFinished():Bool
  {
    return animation?.curAnim?.finished ?? false;
  }

  /**
   * Finishes the current animation playing.
   */
  public function finishAnimation():Void
  {
    if (animationIsNull)
      return;

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

    return animation?.curAnim?.paused ?? false;
  }

  function set_animPaused(value:Bool):Bool
  {
    if (animationIsNull)
      return value;

    if (value)
      animation.curAnim.pause();
    else
      animation.curAnim.resume();

    return value;
  }

  /**
   * Checks if the animation specified exists.
   * @param name The animation name to check for.
   * @return If the animation exists.
   */
  public function animationExists(name:String):Bool
  {
    var atlasAnimList:Array<String> = super.getAnimateAnimations();
    if (atlasAnimList.contains(name))
      return true;

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
      animation.onFinish.add((_) -> _onAnimFinished.dispatch(currentAnim));
    }

    return _onAnimFinished;
  }

  /**
   * @param id The animation ID to check.
   * @return Whether the animation is dynamic (has multiple frames). `false` for static, one-frame animations.
   */
  public function isAnimationDynamic(id:String):Bool
  {
    if (animationIsNull)
      return false;

    var animData:Null<FlxAnimation> = animation.getByName(id);
    if (animData == null)
      return false;

    return animData.numFrames > 1;
  }
}

typedef FunkinSpriteGroup = FlxTypedSpriteGroup<FunkinSprite>
