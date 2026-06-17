package funkin.play.hud.notes;

import funkin.data.song.SongFormat.SongNote;

class NoteSprite extends FunkinSprite
{
  /**
   * The underlying Note Data.
   */
  public var data:Null<SongNote>;

  /**
   * The time this note should be hit, in miliseconds.
   */
  public var time:Null<Float>;

  public function new(strumlineLength:Int)
  {
    super();

    // TODO: make this configurable
    loadFrames('gameplay/hud/funkin-default/notes');

    for (i in 0...strumlineLength)
    {
      addAnimation('direction_$i', [
        'Notes/Default Color/Left',
        'Notes/Default Color/Down',
        'Notes/Default Color/Up',
        'Notes/Default Color/Right'
      ][i]);
    }

    scale.set(0.7, 0.7);
  }

  /**
   * Sets up this note for rendering.
   * @param data The new note data.
   */
  public function setup(data:SongNote):Void
  {
    this.data = data;
    this.revive();

    playAnimation('direction_${data.direction}', true);
    updateHitbox();
  }

  override public function kill():Void
  {
    super.kill();

    this.data = null;
    this.time = null;
  }
}
