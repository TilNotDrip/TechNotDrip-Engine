package funkin.ui.freeplay.dj;

import flixel.util.FlxSignal;

/*
  TODO: MAKE THIS LESS HARDCODED!
 */
class FreeplayDJ extends FunkinSprite
{
  /**
   * Represents the sprite's current status.
   */
  public var currentState(default, null):FreeplayDJState = Intro;

  /**
   * Called when intro done.
   */
  public var introDone:FlxSignal = new FlxSignal();

  public function new(id:String)
  {
    super(0, 0);

    atlasSettings = {
      swfMode: true,
      filterQuality: HIGH
    };

    // todo: softcode this
    switch (id)
    {
      case 'bf':
        loadFrames('ui/freeplay/freeplay-boyfriend');
        applyStageMatrix = true;

        addAnimation('idle', 'Idle', 24, false);
        addAnimation('confirm', 'Confirm', 24, false);
        addAnimation('intro', 'Intro', 24, false);
    }

    onAnimFinished.add(onFinishAnim);
  }

  /**
   * Called when animation is finished.
   * @param anim The finished animation.
   */
  public function onFinishAnim(anim:String)
  {
    switch (currentState)
    {
      case Intro:
        currentState = Idle;
        introDone.dispatch();

      default:
    }
  }

  /**
   * Called on new beat.
   */
  public function beatHit():Void
  {
    if (currentState == Idle)
    {
      playAnimation('idle');
    }
  }

  /**
   * Called when enter gets hit in Freeplay.
   * @return Void
   */
  public function confirm():Void
  {
    currentState = Confirm;
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    switch (currentState)
    {
      case Intro:
        if (currentAnim != 'intro')
        {
          playAnimation('intro');
        }

      case Idle:
        if (currentAnim != 'idle')
        {
          playAnimation('idle');
          animPaused = true;
        }

      case Confirm:
        if (currentAnim != 'confirm')
        {
          playAnimation('confirm');
        }

      default:
    }

    #if (debug && FLX_KEYBOARD)
    var move:Int = FlxG.keys.pressed.SHIFT ? 10 : 1;

    if (FlxG.keys.justPressed.J)
      offset.x += move;

    if (FlxG.keys.justPressed.K)
      offset.y -= move;

    if (FlxG.keys.justPressed.I)
      offset.y += move;

    if (FlxG.keys.justPressed.L)
      offset.x -= move;
    #end
  }
}

enum FreeplayDJState
{
  /**
   * Character enters the frame and transitions to Idle.
   */
  Intro;

  /**
   * Character loops in idle.
   */
  Idle;

  /**
   * Plays an easter egg animation after a period in Idle, then reverts to Idle.
   */
  IdleEasterEgg;

  /**
   * Plays an elaborate easter egg animation. Does not revert until another animation is triggered.
   */
  Cartoon;

  /**
   * Player has selected a song.
   */
  Confirm;

  /**
   * Character preps to play the fist pump animation; plays after the Results screen.
   * The actual frame label that gets played may vary based on the player's success.
   */
  FistPumpIntro;

  /**
   * Character plays the fist pump animation.
   * The actual frame label that gets played may vary based on the player's success.
   */
  FistPump;

  /**
   * Plays an animation to indicate that the player has a new unlock in Character Select.
   * Overrides all idle animations as well as the fist pump. Only Confirm and CharSelect will override this.
   */
  NewUnlock;

  /**
   * Plays an animation to transition to the Character Select screen.
   */
  CharSelect;
}
