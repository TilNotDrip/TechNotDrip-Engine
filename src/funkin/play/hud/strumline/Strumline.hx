package funkin.play.hud.strumline;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import funkin.data.song.SongData;
import funkin.data.strumline.StrumlineData;
import funkin.input.InputUtil;
import funkin.sound.Conductor;

class Strumline extends FlxSpriteGroup
{
  /**
   * The "size" of a strumline note.
   */
  public static final STRUMLINE_SIZE:Int = 104;

  /**
   * The spacing between strumline notes.
   */
  public static final NOTE_SPACING:Int = STRUMLINE_SIZE + 8;

  /**
   * Offset fix for newer strumline sprites.
   */
  public static final INITIAL_OFFSET:Float = -0.275 * STRUMLINE_SIZE;

  /**
   * Strumline Data.
   */
  public var data:StrumlineData;

  /**
   * The conductor to use.
   */
  public var conductorInUse:Conductor;

  /**
   * The notes shown for input.
   */
  public var strumlineNotes:FlxTypedSpriteGroup<StrumlineNote>;

  /**
   * The notes that are supposed to be hit.
   */
  public var notes:FlxTypedSpriteGroup<NoteSprite>;

  /**
   * The sustain notes that are supposed to be hit.
   */
  public var sustainNotes:FlxTypedSpriteGroup<SustainNoteSprite>;

  /**
   * The splashes that appear when you get the rating "Sick!" or higher.
   */
  public var noteSplashes:FlxTypedSpriteGroup<NoteSplash>;

  /**
   * The splashes that appear when you hold a note.
   */
  public var holdCovers:FlxTypedSpriteGroup<NoteHoldCover>;

  /**
   * The Note Data to use for spawning.
   */
  public var noteData:Array<NoteData> = [];

  /**
   * The Note Data left for spawning.
   */
  public var noteDataLeft:Array<NoteData> = [];

  /**
   * The scroll speed.
   */
  public var scrollSpeed:Float = 1;

  /**
   * Called when a Note gets hit.
   */
  public var onNoteHit:FlxTypedSignal<NoteSprite->Void> = new FlxTypedSignal<NoteSprite->Void>();

  /**
   * Used for figuring out if the note should be rendered or not.
   */
  var renderingSquare:FlxObject;

  var currentlyPressed:Array<Bool> = [];

  public function new(data:StrumlineData)
  {
    this.data = data;

    super();

    @:privateAccess
    {
      cast(scrollFactor, FlxCallbackPoint)._setXCallback = scrollFactorCallerback;
      cast(scrollFactor, FlxCallbackPoint)._setYCallback = scrollFactorCallerback;
      cast(scrollFactor, FlxCallbackPoint)._setXYCallback = scrollFactorCallerback;
    }

    renderingSquare = new FlxObject(0, 0, width, STRUMLINE_SIZE);

    strumlineNotes = new FlxTypedSpriteGroup<StrumlineNote>();
    add(strumlineNotes);

    for (i => direction in NoteDirection.allDirections)
    {
      var strumNote:StrumlineNote = new StrumlineNote(NOTE_SPACING * i, 0, direction);
      strumNote.head = this;
      strumlineNotes.add(strumNote);
      currentlyPressed[i] = false;
    }

    sustainNotes = new FlxTypedSpriteGroup<SustainNoteSprite>();
    add(sustainNotes);

    var sustainNote:SustainNoteSprite = new SustainNoteSprite();
    sustainNote.kill();
    sustainNotes.add(sustainNote);

    notes = new FlxTypedSpriteGroup<NoteSprite>();
    add(notes);

    var note:NoteSprite = new NoteSprite();
    note.kill();
    notes.add(note);

    noteSplashes = new FlxTypedSpriteGroup<NoteSplash>();
    add(noteSplashes);

    var noteSplash:NoteSplash = new NoteSplash();
    noteSplash.kill();
    noteSplashes.add(noteSplash);

    holdCovers = new FlxTypedSpriteGroup<NoteHoldCover>();
    add(holdCovers);

    var holdCover:NoteHoldCover = new NoteHoldCover();
    holdCover.kill();
    holdCovers.add(holdCover);
  }

  /**
   * Sets up notes for spawning.
   * @param chart The chart for this song.
   */
  public function setupNotes(chart:ChartArrayElement):Void
  {
    var filteredNotes:Array<NoteData> = chart.chart.filter((note:NoteData) ->
    {
      return note.strum == data.id;
    });

    noteData = filteredNotes;
    noteData.sort((a:NoteData, b:NoteData) ->
    {
      return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
    });

    scrollSpeed = chart.speed;

    noteDataLeft = noteData.copy();
  }

  public function noteHit(note:NoteSprite, showNoteSplash:Bool):Void
  {
    var strumlineNote:StrumlineNote = getStrumNoteForDirection(note.data.direction);

    onNoteHit.dispatch(note);

    if ((note.data?.length ?? 0) > 0)
      strumlineNote.playAnimation('confirm-hold', true);
    else
      strumlineNote.playAnimation('confirm', true);

    if (showNoteSplash)
    {
      var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash);
      noteSplash.setupNoteSplash(strumlineNote.x, strumlineNote.y, note.data.direction);
    }

    if ((note.data.length ?? 0) > 0)
    {
      var holdCover:NoteHoldCover = holdCovers.recycle(NoteHoldCover);
      holdCover.setupHoldCover(strumlineNote, note.data.direction);
      note.sustainSprite.holdCover = holdCover;
    }

    if (note.sustainSprite != null)
    {
      note.sustainSprite.parentWasHit = true;
      note.sustainSprite.currentlyHeld = true;
    }

    note.kill();
  }

  public function noteMiss(note:NoteSprite):Void
  {
    // TODO: when noteTypeData is done, uncomment this
    if (/*note.noteTypeData.playMissSfx*/ true)
      FlxG.sound.play(Paths.content.audio('gameplay/missnote' + FlxG.random.int(1, 3)));

    data.onNoteMiss.dispatch(note);

    note.kill();
  }

  public function sustainNoteMiss(sustainNote:SustainNoteSprite):Void
  {
    // TODO: when noteTypeData is done, uncomment this
    if (/*sustainNote.noteTypeData.playMissSfx*/ true)
      FlxG.sound.play(Paths.content.audio('gameplay/missnote' + FlxG.random.int(1, 3)));

    data.onSustainNoteMiss.dispatch(sustainNote);

    if (sustainNote.holdCover != null)
      sustainNote.holdCover.kill();

    sustainNote.kill();
  }

  override public function update(elapsed:Float):Void
  {
    while (noteDataLeft.length > 0)
    {
      renderingSquare.x = x;
      renderingSquare.y = calculateNoteYPos(noteDataLeft[0].time);

      if (!renderingSquare.isOnScreen())
        break;

      var noteSprite:NoteSprite = notes.recycle(NoteSprite);
      noteSprite.setupNoteSprite(noteDataLeft[0]);

      if ((noteDataLeft[0].length ?? 0) > 0)
      {
        var sustainNoteSprite:SustainNoteSprite = sustainNotes.recycle(SustainNoteSprite);
        sustainNoteSprite.setupSustainSprite(noteDataLeft[0], scrollSpeed);

        noteSprite.sustainSprite = sustainNoteSprite;
      }

      // FlxG.log.add('Rendered note at ${noteDataLeft[0].time}');
      noteDataLeft.shift();
    }

    if (noteDataLeft.length < 1)
    {
      // doesnt need to be used anymore!
      renderingSquare = FlxDestroyUtil.destroy(renderingSquare);
    }

    for (note in notes.members)
    {
      if (!note.alive)
        continue;

      var strumlineNote:StrumlineNote = getStrumNoteForDirection(note.data.direction);
      note.x = strumlineNote.x;
      note.y = strumlineNote.y + calculateNoteYPos(note.data.time);

      if (data.data.computerControlled)
      {
        if (note.data.time <= conductorInUse.time)
        {
          noteHit(note, true);
        }
      }
      else
      {
        // sustain missing is handled by sustains, duh
        if (note.data.time + InputUtil.MISS_THRESHOLD <= conductorInUse.time && (note.data.length ?? 0) <= 0)
        {
          noteMiss(note);
        }
      }
    }

    for (sustainNote in sustainNotes.members)
    {
      if (!sustainNote.alive)
        continue;

      var strumlineNote:StrumlineNote = getStrumNoteForDirection(sustainNote.data.direction);
      var strumlineMid:Float = strumlineNote.y + (STRUMLINE_SIZE / 2);

      sustainNote.x = strumlineNote.x;
      sustainNote.y = strumlineMid + calculateNoteYPos(sustainNote.data.time);

      if (data.data.computerControlled || currentlyPressed[sustainNote.data.direction])
        sustainNote.updateClip(conductorInUse.time);

      if (sustainNote.data.time + sustainNote.data.length <= conductorInUse.time
        && (data.data.computerControlled || currentlyPressed[sustainNote.data.direction]))
      {
        strumlineNote.playAnimation('static', true);
        sustainNote.kill();
        if (sustainNote.holdCover != null)
          sustainNote.holdCover.playAnimation('end', true);
        sustainNote.currentlyHeld = false;
      }

      if (!data.data.computerControlled)
      {
        // FIXME: this doesnt work how i want it to work: i want it to work like if it was a normal note
        if (sustainNote.data.time + (sustainNote.data.length - sustainNote.lengthLeft) + InputUtil.MISS_THRESHOLD <= conductorInUse.time)
        {
          sustainNoteMiss(sustainNote);
        }
      }
    }
    super.update(elapsed);
  }

  override function get_width():Float
  {
    return NoteDirection.allDirections.length * NOTE_SPACING;
  }

  /**
   * Gets the strumline note for direction.
   * @param direction The direction.
   * @return The strumline note.
   */
  public function getStrumNoteForDirection(direction:NoteDirection):StrumlineNote
  {
    for (strumlineNote in strumlineNotes)
    {
      if (strumlineNote.direction == direction)
      {
        return strumlineNote;
      }
    }

    return null;
  }

  /**
   * If there is a sustain currently in this direction.
   * @param direction The direction.
   * @return If there is or not.
   */
  public function isCurrentSustain(direction:NoteDirection):Bool
  {
    for (sustainNote in sustainNotes.members)
    {
      if (!sustainNote.alive)
        continue;

      if (sustainNote.data.time <= conductorInUse.time
        && sustainNote.data.time + sustainNote.data.length >= conductorInUse.time
        && sustainNote.data.direction == direction
        && sustainNote.currentlyHeld
        && sustainNote.parentWasHit)
      {
        trace('Is true!!');
        return true;
      }
    }

    return false;
  }

  /**
   * For a note's strumTime, calculate its Y position relative to the strumline.
   * @param strumTime The time to calculate for.
   * @param vwoosh If the notes should go offscreen.
   * @return Float
   */
  public function calculateNoteYPos(strumTime:Float):Float
  {
    // TODO: change false to downScroll
    return Constants.PIXELS_PER_MS * (conductorInUse.time - strumTime) * scrollSpeed * (false ? 1 : -1);
  }

  override function set_camera(Value:FlxCamera):FlxCamera
  {
    if (camera != Value && renderingSquare != null)
      renderingSquare.camera = Value;
    return super.set_camera(Value);
  }

  override function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera>
  {
    if (_cameras != Value && renderingSquare != null)
      renderingSquare.cameras = Value;
    return super.set_cameras(Value);
  }

  inline function scrollFactorCallerback(ScrollFactor:FlxPoint)
  {
    if (renderingSquare != null)
      renderingSquare.scrollFactor = ScrollFactor;
    scrollFactorCallback(ScrollFactor);
  }
}
