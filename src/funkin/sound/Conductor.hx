package funkin.sound;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import funkin.data.song.SongData.BPMChangeData;

/**
 * The conductor is an class that handles most of the music timing.
 */
class Conductor implements IFlxDestroyable
{
  /**
   * Signal fired when this instance advances to a new step.
   */
  public var stepHit:FlxSignal;

  /**
   * Signal fired when this instance advances to a new beat.
   */
  public var beatHit:FlxSignal;

  /**
   * Signal fired when this instance advances to a new section.
   */
  public var sectionHit:FlxSignal;

  /**
   * The current step.
   */
  public var curStep:Int;

  /**
   * The current beat.
   */
  public var curBeat:Int;

  /**
   * The current section.
   */
  public var curSection:Int;

  /**
   * The current step, but in decimal form.
   */
  public var curStepDecimal:Float;

  /**
   * The current beat, but in decimal form.
   */
  public var curBeatDecimal:Float;

  /**
   * The current section, but in decimal form.
   */
  public var curSectionDecimal:Float;

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

  var bpmChanges:Array<BPMChangeData>;
  var bpmChangesLeft:Array<BPMChangeData>;

  public function new()
  {
    stepHit = new FlxSignal();
    beatHit = new FlxSignal();
    sectionHit = new FlxSignal();

    setupBPMChanges([
      {
        time: 0,
        bpm: 100,
        timeSignature: {
          numerator: 4,
          denominator: 4
        }
      }
    ]);

    // doing it here because time isnt initialized yet
    bpmChangesLeft = bpmChanges.copy();

    time = 0;
  }

  /**
   * Changes the bpm, along with a few other changes.
   * @param bpm The bpm to change it to.
   * @param timeSignature Optional time signature to change it to.
   * @param recalculate If disabled, it will act as a normal bpm change.
   */
  public function changeBPM(bpm:Float, ?timeSignature:{numerator:Float, denominator:Float} = null, ?recalculate:Bool = true):Void
  {
    if (timeSignature == null)
      timeSignature = {numerator: 4, denominator: 4};

    var bpmChangeToAdd:BPMChangeData = {
      time: time,
      bpm: bpm,
      timeSignature: timeSignature,
      beatTime: 0
    };

    if (recalculate)
      bpmChangeToAdd.beatTime = time / calculateCrochet(bpm);

    if (bpmChangesLeft[0].time == time)
    {
      var oldBPMChange:BPMChangeData = bpmChangesLeft.shift();
      bpmChanges.remove(oldBPMChange);
    }

    bpmChanges.push(bpmChangeToAdd);

    bpmChanges.sort((a:BPMChangeData, b:BPMChangeData) ->
    {
      return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
    });

    recalculateBPMChangeCache();
  }

  /**
   * Fully resets BPM Changes.
   */
  public function resetBPMChanges():Void
  {
    var currentBPM:Float = bpmChangesLeft[0].bpm;
    var currentTimeSignature:{numerator:Float, denominator:Float} = bpmChangesLeft[0].timeSignature;
    setupBPMChanges([
      {
        bpm: currentBPM,
        time: 0,
        timeSignature: currentTimeSignature
      }
    ]);
  }

  /**
   * Updates the current conductor time.
   * @param songTime The time to set it to. If not specified the FlxG.sound.music time will be used instead.
   */
  public function update(?songTime:Float):Void
  {
    if (songTime != null)
    {
      time = songTime;
    }
    else
    {
      time = FlxG.sound.music.time ?? 0.0;
    }
  }

  /**
   * Sets up the bpm changes for use.
   * @param bpmChangeArray The BPM Changes to set up.
   */
  public function setupBPMChanges(bpmChangeArray:Array<BPMChangeData>)
  {
    bpmChanges = bpmChangeArray;

    bpmChanges.sort((a:BPMChangeData, b:BPMChangeData) ->
    {
      return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
    });

    // haxe 4.3 syntax my goat
    for (bpmChange in bpmChanges)
      bpmChange.beatTime ??= 0;

    recalculateBPMChangeCache();
  }

  /**
   * Cleans up this Conductor to the best of our abilities.
   */
  public function destroy():Void
  {
    stepHit.destroy();
    beatHit.destroy();
    sectionHit.destroy();
  }

  function set_time(value:Float):Float
  {
    var oldTime:Float = time;
    var oldStep:Int = curStep;
    var oldBeat:Int = curBeat;
    var oldSection:Int = curSection;

    time = value;

    // in case we went back for some reason
    if (oldTime > time)
      recalculateBPMChangeCache();

    if (bpmChangesLeft[1] != null && time >= bpmChangesLeft[1].time)
    {
      bpmChangesLeft.shift();

      FlxG.log.notice('New BPM Change!');

      if (bpmChangesLeft[0].beatTime == 0)
        bpmChangesLeft[0].beatTime = curBeatDecimal;
    }

    curBeatDecimal = bpmChangesLeft[0].beatTime + ((time - bpmChangesLeft[0].time) / crochet);
    curStepDecimal = curBeatDecimal * bpmChangesLeft[0].timeSignature.denominator;
    curSectionDecimal = curBeatDecimal / bpmChangesLeft[0].timeSignature.numerator;

    curStep = Math.floor(curStepDecimal);
    curBeat = Math.floor(curBeatDecimal);
    curSection = Math.floor(curSectionDecimal);

    #if FLX_DEBUG
    FlxG.watch.addQuick('curStep', curStep);
    FlxG.watch.addQuick('curBeat', curBeat);
    FlxG.watch.addQuick('curSection', curSection);
    FlxG.watch.addQuick('BPM', bpmChangesLeft[0].bpm);
    #end

    if (oldStep != curStep)
      stepHit.dispatch();

    if (oldBeat != curBeat)
      beatHit.dispatch();

    if (oldSection != curSection)
      sectionHit.dispatch();

    return value;
  }

  function get_crochet():Float
  {
    return calculateCrochet(bpm);
  }

  function get_stepCrochet():Float
  {
    return bpmChangesLeft[0].timeSignature.denominator;
  }

  function get_sectionCrochet():Float
  {
    return crochet * bpmChangesLeft[0].timeSignature.numerator;
  }

  function get_bpm():Float
  {
    return bpmChangesLeft[0].bpm;
  }

  /**
   * Resets the BPM Change cache.
   */
  public function recalculateBPMChangeCache():Void
  {
    bpmChangesLeft = bpmChanges.copy();

    while (true)
    {
      if (bpmChangesLeft[1] != null && time >= bpmChangesLeft[1].time)
        bpmChangesLeft.shift();
      else
        break;
    }
  }

  /**
   * Calculate the crochet, which is the length between a beat.
   * @param bpm The bpm to use for calculating.
   * @return The crochet, in miliseconds.
   */
  static inline function calculateCrochet(bpm:Float):Float
  {
    return ((60 / bpm) * 1000);
  }
}
