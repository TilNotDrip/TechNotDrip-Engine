package funkin.play.hud.strumline;

import flixel.math.FlxPoint;

class NoteHoldCover extends FunkinSprite
{
  /**
   * Strumline Note that this hold cover is rendering above.
   */
  public var strumlineNote:StrumlineNote;

  public function new()
  {
    super();
    loadNoteHoldCover();

    #if FLX_DEBUG
    FlxG.console.registerClass(NoteHoldCover);
    #end
  }

  // NOTE TO SELF: YOU CAN USE THESE WITH THE FLIXEL DEBUGGER!

  /**
   * Hold Cover Offset.
   */
  public static var HOLD_COVER_OFFSET:Float = -35;

  /**
   * Hold Cover End Offset.
   */
  public static var HOLD_COVER_END_OFFSET:FlxPoint = new FlxPoint(8, 16);

  public function setupHoldCover(strumlineNote:StrumlineNote, direction:NoteDirection):Void
  {
    this.strumlineNote = strumlineNote;
    setPosition(strumlineNote.x, strumlineNote.y);

    playAnimation('start');

    x += Strumline.STRUMLINE_SIZE / 2;
    x -= width / 2;
    x += 2;

    y += Strumline.INITIAL_OFFSET;
    y += Strumline.STRUMLINE_SIZE / 2;
    y += HOLD_COVER_OFFSET; // (insert crushers fuck you voice)
  }

  public function loadNoteHoldCover():Void
  {
    // TODO: make this softcoded
    loadFrames('gameplay/hud/funkin/strumline/sustainCover');

    addAnimation('start', 'sustain cover pre', null, 24, false);
    addAnimation('loop', 'sustain cover', null, 24, true);
    addAnimation('end', 'sustain cover end', null, 24, false);

    onAnimFinished.add(onAnimationFinished);
  }

  override public function playAnimation(name:String, ?restart:Bool = false, ?stunAnimations:Bool = false, ?reversed:Bool = false):Void
  {
    super.playAnimation(name, restart, stunAnimations, reversed);
    centerOffsets();

    switch (name)
    {
      case 'end':
        offset.subtractPoint(HOLD_COVER_END_OFFSET);
    }
  }

  function onAnimationFinished(anim:String):Void
  {
    switch (anim)
    {
      case 'start':
        playAnimation('loop', true);
      case 'end':
        kill();
    }
  }
}
