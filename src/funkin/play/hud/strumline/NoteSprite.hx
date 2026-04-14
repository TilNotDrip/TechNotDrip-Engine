package funkin.play.hud.strumline;

import funkin.data.song.SongData;

// import funkin.shaders.gameplay.RGBShader;
class NoteSprite extends FunkinSprite
{
  /**
   * Data for the current note.
   */
  public var data:NoteData;

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

  public function setupNoteSprite(data:NoteData):Void
  {
    this.data = data;

    playAnimation(cast(data.direction, NoteDirection).name);
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
