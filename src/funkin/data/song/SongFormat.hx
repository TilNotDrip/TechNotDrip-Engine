package funkin.data.song;

import funkin.data.sound.BPMChange;
import funkin.sound.Conductor;

@:structInit
class SongChart
{
  /**
   * The latest version of this chart data.
   */
  public static final LATEST_VERSION:String = '1.0.0';

  /**
   * The current version of this chart data.
   */
  @:optional
  public var version:Null<String>;

  /**
   * A map of each `difficultyID` to its `SongDifficulty` object,
   * containing the chart and scroll speed.
   *
   * ```haxe
   * [difficultyID => chart]
   * ```
   */
  public var difficulties:Map<String, SongDifficulty>;

  /**
   * This is used for telling what this chart was exported from.
   * It has no real purpose.
   */
  @:optional
  public var generatedBy:Null<String>;

  public function new(difficulties:Map<String, SongDifficulty>)
  {
    this.difficulties = difficulties;

    this.version = SongChart.LATEST_VERSION;
    this.generatedBy = Constants.TECHNOTDRIP_VERSION; // TODO: make a proper generatedBy message
  }
}

@:structInit
class SongDifficulty
{
  /**
   * The scroll speed of this difficulty.
   */
  public var speed:Float;

  /**
   * The notes in this difficulty.
   *
   * ```haxe
   * [strumlineID => notes]
   * ```
   */
  public var notes:SongNotesMap;

  public function new(notes:SongNotesMap)
  {
    this.notes = notes;
    this.speed = 1.0;
  }
}

typedef SongNotesMap = Map<String, Array<SongNote>>;

@:structInit
class SongNote
{
  /**
   * The step of this note.
   */
  public var step:Float;

  /**
   * The direction of this Note.
   */
  public var direction:Int;

  /**
   * The sustain length of this note, in steps.
   * @default `0`
   */
  @:default(0)
  public var length:Float;

  /**
   * The notekind of this note.
   * @default `null`
   */
  @:default(null)
  public var kind:Null<String>;

  public function new(step:Float, direction:Int, ?length:Float, ?kind:String)
  {
    this.step = step;
    this.direction = direction;

    this.length = length ?? 0;
    this.kind = kind;
  }

  /**
   * Gets the time of this note, in miliseconds.
   * @param conductor Conductor to use for this calculation.
   * @return Milisecond Time.
   */
  public function getTime(conductor:Conductor):Float
  {
    return conductor.getStepInMs(this.step);
  }

  /**
   * Gets the sustain length of this note, in miliseconds.
   * @param conductor Conductor to use for this calculation.
   * @return Milisecond Length Amount.
   */
  public function getLengthMs(conductor:Conductor):Float
  {
    final startTime:Float = conductor.getStepInMs(this.step);
    final endTime:Float = conductor.getStepInMs(this.step + this.length);
    return endTime - startTime;
  }
}

@:structInit
class SongMetadata
{
  /**
   * The readable name of this song.
   */
  public var name:String;

  /**
   * The list of difficulties available.
   * The sorting is important!
   */
  public var difficulties:Array<String>;

  /**
   * Data used when actually playing the song.
   */
  public var playData:SongPlayData;

  /**
   * Freeplay specific data for this song.
   */
  public var freeplayData:SongFreeplayData;

  /**
   * Credits Data for this song.
   */
  @:default({})
  public var credits:Null<SongCredits>;

  /**
   * The BPM Changes in this song.
   */
  @:default([funkin.data.sound.BPMChange.DEFAULT_BPM_CHANGE])
  public var bpmChanges:Array<BPMChange>;
}

@:structInit
class SongPlayData
{
  /**
   * The characters used by this song.
   *
   * ```haxe
   * [strumlineID => characterID]
   * ```
   */
  public var characters:Map<String, String>;

  /**
   * The stage used by this song.
   */
  public var stage:String;

  /**
   * The HUD used for this song.
   */
  public var hud:String;
}

@:structInit
class SongFreeplayData
{
  /**
   * Difficulty Ratings for this song.
   */
  public var ratings:Map<String, Int>;

  /**
   * The album that this song belongs to.
   */
  public var album:String;

  /**
   * Icon to use in Freeplay.
   * Otherwise, the first opponent will be used.
   */
  @:default(null)
  public var icon:Null<String>;

  /**
   * The start and end times of the song preview.
   */
  public var preview:SongPreview;
}

@:structInit
class SongPreview
{
  /**
   * The start of the song preview, as a percentage.
   * @default `0`
   */
  @:default(0)
  public var start:Float;

  /**
   * The end of the song preview, as a percentage.
   * @default `0.2`
   */
  @:default(0.2)
  public var end:Float;
}

@:structInit
class SongCredits
{
  /**
   * The artist of this song.
   */
  @:default(null)
  public var artist:Null<String>;

  /**
   * The charter of this song.
   */
  @:default(null)
  public var charter:Null<String>;

  public function new(?artist:String, ?charter:String)
  {
    this.artist = artist;
    this.charter = charter;
  }
}

@:structInit
class SongEvent
{
  /**
   * The ID of this event.
   */
  public var id:String;

  /**
   * The step of this event.
   */
  public var step:Float;

  /**
   * The step of this event.
   */
  public var params:Map<String, Dynamic>;

  public function new(id:String, step:Float, params:Map<String, Dynamic>)
  {
    this.id = id;
    this.step = step;
    this.params = params;
  }
}

typedef SongEvents = Array<SongEvent>;
