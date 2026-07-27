package funkin;

import funkin.data.BPMChange;

/**
 * The conductor is an class that handles most of the music timing.
 */
class Conductor
{
  /**
   * Singleton instance of the Conductor.
   */
  public static var instance(get, never):Conductor;

  /**
   * Signal fired when this instance advances to a new step.
   */
  public var stepHit:Signal<Void->Void>;

  /**
   * Signal fired when this instance advances to a new beat.
   */
  public var beatHit:Signal<Void->Void>;

  /**
   * Signal fired when this instance advances to a new measure.
   */
  public var measureHit:Signal<Void->Void>;

  /**
   * The current step, but in decimal form.
   */
  public var curStepDecimal(get, never):Float;

  /**
   * The current step.
   */
  public var curStep(get, never):Int;

  /**
   * The current beat, but in decimal form.
   */
  public var curBeatDecimal(get, never):Float;

  /**
   * The current beat.
   */
  public var curBeat(get, never):Int;

  /**
   * The current section, but in decimal form.
   */
  public var curMeasureDecimal(get, never):Float;

  /**
   * The current measure.
   */
  public var curMeasure(get, never):Int;

  /**
   * Timestamp of the music that the conductor will follow.
   * Should be in miliseconds.
   */
  public var time(default, set):Float;

  /**
   * The bpm of the music that the conductor will follow.
   * Use changeBPM to set it!
   */
  public var bpm(get, null):Float;

  /**
   * The length between a beat, in miliseconds.
   */
  public var crochet(get, null):Float;

  /**
   * The length between a step, in miliseconds.
   */
  public var stepCrochet(get, null):Float;

  /**
   * The length between a section, in miliseconds.
   */
  public var sectionCrochet(get, null):Float;

  /**
   * The current BPM change.
   */
  public var currentBPMChange(get, never):BPMChange;

  inline function get_currentBPMChange():BPMChange
    return getBPMChangeFromMs(time);

  var bpmChanges:Array<BPMChange>;

  public function new()
  {
    stepHit = new Signal<Void->Void>();
    beatHit = new Signal<Void->Void>();
    measureHit = new Signal<Void->Void>();

    changeBPM(100);
    time = -1;
  }

  /**
   * Changes the bpm, along with a few other changes.
   * @param bpm The bpm to change it to.
   * @param timeSignature Optional time signature to change it to.
   * @param reset Should this reset all other BPM changes, or act as one?
   */
  public function changeBPM(bpm:Float, ?timeSignature:TimeSignature = null, ?reset:Bool = true):Void
  {
    if (reset)
    {
      final bpmChange:BPMChange = {
        time: 0,
        bpm: bpm,
        timeSignature: timeSignature ?? new TimeSignature()
      };

      bpmChanges = [bpmChange];
    }
    else
    {
      final bpmChange:BPMChange = {
        time: time,
        bpm: bpm,
        timeSignature: timeSignature ?? new TimeSignature()
      };

      bpmChanges.push(bpmChange);
    }

    recalculateBeatTimes();
  }

  /**
   * Fully resets BPM Changes.
   */
  public function resetBPMChanges():Void
  {
    setupBPMChanges([
      {
        bpm: currentBPMChange.bpm,
        time: 0,
        timeSignature: currentBPMChange.timeSignature
      }
    ]);
  }

  /**
   * Updates the current conductor time.
   * @param songTime The time to set it to. If not specified the FunkinSound.music time will be used instead.
   */
  public function update(?songTime:Float):Void
  {
    if (songTime != null)
    {
      time = songTime;
    }
    else if (FunkinSound.music != null)
    {
      time = FunkinSound.music.position * 1000;
    }
  }

  /**
   * Sets up the bpm changes for use.
   * @param bpmChanges The BPM Changes to set up.
   */
  public function setupBPMChanges(bpmChanges:Array<BPMChange>)
  {
    this.bpmChanges = bpmChanges.copy();
    recalculateBeatTimes();
  }

  function recalculateBeatTimes():Void
  {
    this.bpmChanges.sort((a, b) -> Std.int(a.time - b.time));

    var lastTime:Float = 0;
    var lastBeatTime:Float = 0;

    for (bpmChange in bpmChanges)
    {
      bpmChange.beatTime = (bpmChange.time - lastTime) / calculateCrochet(bpmChange.bpm);
      bpmChange.beatTime += lastBeatTime;

      lastTime = bpmChange.time;
      lastBeatTime = bpmChange.beatTime;
    }
  }

  /**
   * Cleans up this Conductor to the best of our abilities.
   */
  public function destroy():Void
  {
    stepHit.dispose();
    beatHit.dispose();
    measureHit.dispose();
  }

  /**
   * Gets the current step from a timestamp.
   * @param time The timestamp, in miliseconds.
   * @return The step.
   */
  public function getStepFromMs(time:Float):Float
  {
    final bpmChange:BPMChange = getBPMChangeFromMs(time);
    return getBeatFromMs(time) * bpmChange.timeSignature.denominator;
  }

  /**
   * Gets the timestamp of a step.
   * @param step The step.
   * @return The timestamp, in miliseconds.
   */
  public function getStepInMs(step:Float):Float
  {
    var toReturn:Float = 0;

    for (bpmChange in bpmChanges)
    {
      final stepTime:Float = bpmChange.beatTime * bpmChange.timeSignature.denominator;
      final stepsElapsed:Float = step - stepTime;

      if (stepsElapsed < 0)
        break;

      final beatsElapsed:Float = stepsElapsed / bpmChange.timeSignature.denominator;
      toReturn = (beatsElapsed * calculateCrochet(bpmChange.bpm)) + bpmChange.beatTime;
    }

    return toReturn;
  }

  /**
   * Gets the current beat from a timestamp.
   * @param time The timestamp, in miliseconds.
   * @return The beat.
   */
  public function getBeatFromMs(time:Float):Float
  {
    final bpmChange:BPMChange = getBPMChangeFromMs(time);
    return ((time - bpmChange.time) / calculateCrochet(bpmChange.bpm)) + bpmChange.beatTime;
  }

  /**
   * Gets the timestamp of a beat.
   * @param beat The beat.
   * @return The timestamp, in miliseconds.
   */
  public function getBeatInMs(beat:Float):Float
  {
    var toReturn:Float = 0;

    for (bpmChange in bpmChanges)
    {
      final beatsElapsed:Float = beat - bpmChange.beatTime;
      if (beatsElapsed < 0)
        break;

      toReturn = (beatsElapsed * calculateCrochet(bpmChange.bpm)) + bpmChange.beatTime;
    }

    return toReturn;
  }

  /**
   * Gets the current measure from a timestamp.
   * @param time The timestamp, in miliseconds.
   * @return The measure.
   */
  public function getMeasureFromMs(time:Float):Float
  {
    final bpmChange:BPMChange = getBPMChangeFromMs(time);
    return getBeatFromMs(time) / bpmChange.timeSignature.numerator;
  }

  /**
   * Gets the timestamp of a measure.
   * @param measure The measure.
   * @return The timestamp, in miliseconds.
   */
  public function getMeasureInMs(measure:Float):Float
  {
    var toReturn:Float = 0;

    for (bpmChange in bpmChanges)
    {
      final measureTime:Float = bpmChange.beatTime / bpmChange.timeSignature.numerator;
      final measuresElapsed:Float = measure - measureTime;

      if (measuresElapsed < 0)
        break;

      final beatsElapsed:Float = measuresElapsed * bpmChange.timeSignature.numerator;
      toReturn = (beatsElapsed * calculateCrochet(bpmChange.bpm)) + bpmChange.beatTime;
    }

    return toReturn;
  }

  /**
   * Gets a BPM Change from a timestamp.
   * @param time A timestamp, in miliseconds.
   * @return The BPM Change.
   */
  public function getBPMChangeFromMs(time:Float):BPMChange
  {
    time = Math.max(time, 0);

    for (i in 0...bpmChanges.length)
    {
      if (time >= bpmChanges[i].time && time < bpmChanges[i + 1]?.time)
        return bpmChanges[i];
    }

    return bpmChanges[bpmChanges.length - 1];
  }

  function set_time(value:Float):Float
  {
    final oldStep:Int = curStep;
    final oldBeat:Int = curBeat;
    final oldMeasure:Int = curMeasure;

    time = value;

    if (oldStep != curStep)
      stepHit.dispatch();

    if (oldBeat != curBeat)
      beatHit.dispatch();

    if (oldMeasure != curMeasure)
      measureHit.dispatch();

    return value;
  }

  inline function get_curStepDecimal():Float
    return getStepFromMs(time);

  inline function get_curBeatDecimal():Float
    return getBeatFromMs(time);

  inline function get_curMeasureDecimal():Float
    return getMeasureFromMs(time);

  inline function get_curStep():Int
    return Math.floor(curStepDecimal);

  inline function get_curBeat():Int
    return Math.floor(curBeatDecimal);

  inline function get_curMeasure():Int
    return Math.floor(curMeasureDecimal);

  function get_crochet():Float
  {
    return calculateCrochet(bpm);
  }

  function get_stepCrochet():Float
  {
    return crochet / currentBPMChange.timeSignature.denominator;
  }

  function get_sectionCrochet():Float
  {
    return crochet * currentBPMChange.timeSignature.numerator;
  }

  function get_bpm():Float
  {
    return currentBPMChange.bpm;
  }

  static var _instance:Conductor;

  static function get_instance():Conductor
  {
    if (_instance == null)
      _instance = new Conductor();

    return _instance;
  }

  /**
   * Calculate the crochet, which is the length between a beat.
   * @param bpm The bpm to use for calculating.
   * @return The crochet, in miliseconds.
   */
  static inline function calculateCrochet(bpm:Float):Float
  {
    return (60 / bpm) * 1000;
  }
}
