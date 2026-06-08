package funkin.data.sound;

@:structInit
class BPMChange
{
  /**
   * The default BPM Change to use if none is applied.
   *
   * This is more of a fallback, do not depend on this!
   */
  public static final DEFAULT_BPM_CHANGE:BPMChange = new BPMChange(0, 100);

  /**
   * The time that this bpm change gets played on.
   */
  public var time:Float;

  /**
   * The new bpm when this change is hit.
   */
  public var bpm:Float;

  /**
   * The time signature to change to.
   */
  @:default({numerator: 4, denominator: 4})
  public var timeSignature:TimeSignature;

  /**
   * The time in beats.
   *
   * This is used internally to calculate beats after the change.
   */
  @:allow(funkin.sound.Conductor)
  @:jignored
  var beatTime:Float = 0;

  public function new(time:Float, bpm:Float, ?timeSignature:TimeSignature)
  {
    this.time = time;
    this.bpm = bpm;
    this.timeSignature = timeSignature ?? {numerator: 4, denominator: 4};
  }
}

@:structInit
class TimeSignature
{
  /**
   * The amount of beats in a measure.
   */
  @:default(4)
  public var numerator:Float;

  /**
   * The amount of steps in a beat.
   */
  @:default(4)
  public var denominator:Float;

  public function new(?numerator:Float, ?denominator:Float)
  {
    this.numerator = numerator ?? 4;
    this.denominator = denominator ?? 4;
  }
}
