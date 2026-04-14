package funkin.play.hud.strumline;

class StrumlineNote extends FunkinSprite
{
  /**
   * The head of this strumline note.
   */
  public var head:Strumline;

  /**
   * Direction of this strumline note.
   */
  public var direction:NoteDirection;

  /**
   * Set this flag to `true` to disable performance optimizations that cause
   * the Strumline note sprite to ignore `velocity` and `acceleration`.
   */
  public var forceActive:Bool = false;

  /**
   * Hold cover over this strumline note. 
   * This is never used internally, but is used by Strumline to find it.
   */
  // public var holdCover:NoteHoldCover;

  public function new(?x:Float, ?y:Float, direction:NoteDirection)
  {
    this.direction = direction;
    super(x, y);

    // TODO: make this softcoded
    loadFrames('gameplay/hud/funkin/strumline/noteStrumline');
    setGraphicSize(Std.int(width * 0.7));
    updateHitbox();

    addAnimation('static', 'arrow ${direction.name}', null, 24, false);
    addAnimation('press', '${direction.name} press', null, 24, false);
    addAnimation('confirm', '${direction.name} confirm', null, 24, false);
    addAnimation('confirm-hold', '${direction.name} confirm hold', null, 24, false);
    playAnimation('static');
    onAnimFinished.add(onAnimationFinished);
  }

  function onAnimationFinished(anim:String):Void
  {
    switch (anim)
    {
      case 'confirm':
        if (head.data.data.computerControlled)
          playAnimation('static', true);
    }
  }

  override public function playAnimation(name:String, ?restart:Bool = false, ?stunAnimations:Bool = false, ?reversed:Bool = false):Void
  {
    this.active = (forceActive || isAnimationDynamic(name));
    super.playAnimation(name, restart, stunAnimations, reversed);
    centerOffsets();
    centerOrigin();

    offset.add(MathUtil.center(width, Strumline.STRUMLINE_SIZE), MathUtil.center(height, Strumline.STRUMLINE_SIZE));
  }
}
