package funkin.play.hud.strumline;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import funkin.data.song.SongData.NoteData;
import openfl.display.BitmapData;
import openfl.geom.Point;

class SustainNoteSprite extends FunkinSprite
{
  /**
   * The note data for this sustain note.
   */
  public var data:NoteData;

  /**
   * Current scroll speed.
   */
  public var scrollSpeed:Float;

  /**
   * Hold Cover used for this sustain. Used by `Strumline` for organizing sakes.
   */
  public var holdCover:NoteHoldCover;

  /**
   * If this sustain note is being currently held.
   */
  public var currentlyHeld:Bool = false;

  /**
   * The length left on the sustain note. Used for missing.
   */
  public var lengthLeft:Float = 0;

  /**
   * If the parent note was hit already.
   */
  public var parentWasHit:Bool = false;

  /**
   * Sets up sustain sprite for use.
   * @param data The note data for this sustain note.
   * @param scrollSpeed Current scroll speed.
   */
  public function setupSustainSprite(data:NoteData, scrollSpeed:Float)
  {
    this.data = data;
    this.scrollSpeed = scrollSpeed;
    lengthLeft = data.length;

    loadGraphic(generateSprite(data, scrollSpeed));
    setGraphicSize(Std.int(width * 0.7));
    updateHitbox();
    centerOffsets();
    offset.x += MathUtil.center(width, Strumline.STRUMLINE_SIZE) + 1;
  }

  /**
   * Updates the clipping based on current time.
   * @param currentTime The current time.
   */
  public function updateClip(currentTime:Float)
  {
    if (clipRect == null)
      clipRect = new FlxRect(0, 0, width / 0.7, height / 0.7);

    if (data.time <= currentTime)
    {
      clipRect.set(0, 0, width / 0.7, height / 0.7);

      clipRect.y = height - sustainHeight((data.time + data.length) - currentTime, scrollSpeed);
      clipRect.y /= 0.7;

      clipRect = clipRect;

      lengthLeft = (data.time + data.length) - currentTime;
    }
  }

  override public function revive():Void
  {
    if (clipRect != null)
    {
      clipRect = FlxDestroyUtil.put(clipRect);
    }

    currentlyHeld = false;

    super.revive();
  }

  // THIS ASSUMES YOU WILL SCALE IT BY 0.7!!
  static function generateSprite(data:NoteData, scrollSpeed:Float):BitmapData
  {
    var noteFrames:FlxFramesCollection = Paths.content.sparrowAtlas('gameplay/hud/funkin/strumline/notes');
    var holdPiece:FlxFrame = noteFrames.getAllByPrefix('${cast (data.direction, NoteDirection).color} hold piece')[0];
    var holdEnd:FlxFrame = noteFrames.getAllByPrefix('${cast (data.direction, NoteDirection).color} hold end')[0];
    var toReturn:BitmapData = new BitmapData(Std.int(Math.max(holdPiece.sourceSize.x, holdEnd.sourceSize.x)),
      Std.int(sustainHeight(data.length, scrollSpeed) / 0.7), true, 0);

    var holdPieceLeft:Int = Std.int(toReturn.height - holdEnd.frame.height);
    var yPos:Int = 0;
    while (yPos < holdPieceLeft)
    {
      holdPiece.paint(toReturn, new Point(0, yPos), false, false);
      yPos += Math.floor(holdPiece.sourceSize.y) - 1;
    }

    holdEnd.paint(toReturn, new Point(0, holdPieceLeft), false, false);

    return toReturn;
  }

  /**
   * Calculates height of a sustain note for a given length (milliseconds) and scroll speed.
   * @param length The length of the sustain note in milliseconds.
   * @param scroll The current scroll speed.
   * @return Sustain Height.
   */
  public static inline function sustainHeight(length:Float, scroll:Float):Float
  {
    return (length * Constants.PIXELS_PER_MS * scroll);
  }
}
