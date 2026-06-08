package funkin.play.hud.strumline;

import funkin.data.song.SongFormat;

// import funkin.shaders.gameplay.RGBShader;
class NoteSprite extends FunkinSprite
{
  /**
   * The time of this note, in miliseconds.
   */
  public var time:Float = 0;

  /**
   * The length of this note, in miliseconds.
   */
  public var length:Float = 0;

  /**
   * Data for the current note.
   */
  public var data:SongNote;

  /**
   * The sustain note, if it exists.
   */
  public var sustainSprite:SustainNoteSprite;

  /**
   * The current rgb shader.
   */
  // public var rgbShader:RGBShader;

  public function new()
  {
    super();
    loadNoteFrames();
  }

  public function setupNoteSprite(data:SongNote):Void
  {
    this.data = data;
    playAnimation(data.direction.name);
  }

  public function loadNoteFrames():Void
  {
    // TODO: make this softcoded
    loadFrames('gameplay/hud/funkin/strumline/notes');
    setGraphicSize(Std.int(width * 0.7));
    updateHitbox();
    centerOffsets();
    offset.add(MathUtil.center(width, Strumline.STRUMLINE_SIZE), MathUtil.center(height, Strumline.STRUMLINE_SIZE));

    for (direction in NoteDirection.allDirections)
      addAnimation(direction.name, direction.color);
  }
}
