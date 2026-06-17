package funkin.play.hud.notes;

import flixel.FlxObject;
import funkin.data.song.SongFormat;

class Playfield extends FlxSpriteGroup
{
  /**
   * The offset of the playing field from the top edge of the screen.
   */
  public static final STRUMLINE_Y_OFFSET:Float = 24;

  /**
   * A magic number for the size of a note, in pixels.
   */
  public static final NOTE_SIZE:Int = 104;

  /**
   * The spacing between notes on the playing field, in pixels.
   */
  public static final NOTE_SPACING:Int = NOTE_SIZE + 8;

  /**
   * The Strumline Data.
   */
  public final data:StrumlineData;

  /**
   * The condudctor to use for calculations.
   */
  public final conductor:Conductor;

  /**
   * Scroll speed.
   */
  public var speed:Float = 1;

  /**
   * The group containing the static notes.
   */
  public var strumlineNotes:FunkinSpriteGroup;

  /**
   * The group containing all current rendered notes.
   *
   * It is also used for pooling.
   */
  public var notes:FlxTypedSpriteGroup<NoteSprite>;

  var renderCheck:FlxObject;

  public function new(data:StrumlineData, conductor:Conductor)
  {
    this.data = data;
    this.conductor = conductor;

    super();

    strumlineNotes = new FunkinSpriteGroup();
    add(strumlineNotes);

    notes = new FlxTypedSpriteGroup<NoteSprite>();
    add(notes);

    renderCheck = new FlxObject();
    renderCheck.setSize(NOTE_SIZE, NOTE_SIZE);

    for (i in 0...data.strumlineLength)
    {
      var strumNote:FunkinSprite = new FunkinSprite(NOTE_SPACING * i);

      // TODO: make this configurable.
      strumNote.loadFrames('gameplay/hud/funkin-default/notes');
      strumNote.addAnimation('idle', [
        'Notes/Static Arrows/Left',
        'Notes/Static Arrows/Down',
        'Notes/Static Arrows/Up',
        'Notes/Static Arrows/Right'
      ][i]);
      strumNote.playAnimation('idle');

      strumNote.scale.set(0.7, 0.7);
      strumNote.updateHitbox();

      strumlineNotes.add(strumNote);
    }

    this.x = ((data?.playfieldPosition ?? 0) * FlxG.width) - (this.width / 2);
    this.y = STRUMLINE_Y_OFFSET;
  }

  override public function update(elapsed:Float):Void
  {
    updateNotes();
    super.update(elapsed);
  }

  function updateNotes():Void
  {
    notes.forEachAlive(note ->
    {
      // TODO: follow strumline note
      note.y = this.y + getNoteY(conductor, note.data, speed);
    });
  }

  /**
   * Constructs a note for rendering.
   * @param data The note data.
   * @return The constructed note sprite.
   */
  public function constructNote(data:SongNote):NoteSprite
  {
    final sprite:NoteSprite = notes.recycle(null, () -> new NoteSprite(this.data.strumlineLength));
    sprite.setup(data);

    // TODO: follow strumline note
    sprite.x = this.x + sprite.data.direction * NOTE_SPACING;
    sprite.y = this.y + getNoteY(conductor, data, speed);

    return sprite;
  }

  /**
   * Hits a note.
   * @param noteSprite The note to hit.
   */
  public function hit(noteSprite:NoteSprite):Void
  {
    noteSprite.kill();
  }

  /**
   * Misses a note.
   * @param noteSprite The note to miss.
   */
  public function miss(noteSprite:NoteSprite):Void
  {
    noteSprite.kill();
  }

  /**
   * Checks if a specific note would be visible on this playing field.
   * @param note The song note to use.
   * @return If it would be visible.
   */
  public function isNoteOnScreen(note:SongNote):Bool
  {
    renderCheck.x = this.width / 2;
    renderCheck.y = getNoteY(conductor, note, speed);

    return renderCheck.isOnScreen(getDefaultCamera());
  }

  override function get_width():Float
  {
    return (data.strumlineLength * NOTE_SPACING) * scale.y;
  }

  override function get_height():Float
  {
    return NOTE_SIZE * scale.y;
  }

  /**
   * Gets the Y position of a note.
   * @param conductor The conductor to use for calculations.
   * @param note The song note to use.
   * @param speed The scroll speed.
   * @return The Y Position.
   */
  public static function getNoteY(conductor:Conductor, note:SongNote, speed:Float):Float
  {
    final strumTime:Float = note.getTime(conductor);
    return -Constants.PIXELS_PER_MS * (conductor.time - strumTime) * speed;
  }
}
