package funkin.sound;

import flixel.sound.FlxSoundGroup;
import openfl.media.Sound;

// I can't figure out what to call Voices/Vocals, so you'll see a lot of switching around.
// I'm sorry in advance.

/**
 * A group used to handle voices/vocals.
 */
class VoicesGroup extends FlxSoundGroup
{
  var strumlines:Map<String, FlxSound>;
  var combined:Null<FlxSound>;
  var audioPath:String;

  public function new(audioPath:String)
  {
    this.strumlines = [];
    this.audioPath = audioPath;

    super();

    final combinedPath:String = '$audioPath/voices';
    if (Paths.location.exists('$combinedPath.${Paths.AUDIO_EXT}'))
    {
      combined = FlxG.sound.load(Paths.content.audio(combinedPath));
      this.add(combined);
    }
  }

  /**
   * Registers a Strumline ID into the group, loading it if it exists.
   * @param id The Strumline ID.
   */
  public function registerStrumline(id:String):Void
  {
    if (combined != null)
      return;

    final path:String = '$audioPath/voices-$id';
    if (!Paths.location.exists('$path.${Paths.AUDIO_EXT}'))
      return;

    var sound:FlxSound = FlxG.sound.load(Paths.content.audio(path));
    strumlines.set(id, sound);
    this.add(sound);
  }

  /**
   * Gets the sound instance for a strumline.
   * @param id The Strumline ID to look for.
   * @return The sound instance. Will be `null` if it doesnt exist.
   */
  public function getStrumline(id:String):Null<FlxSound>
  {
    if (combined != null)
      return combined;

    return strumlines.get(id);
  }

  /**
   * Trace useful info about the vocals.
   */
  public function traceInfo():Void
  {
    var type:String = 'None Found';

    if (combined != null)
      type = 'Paired';
    else if (this.sounds.length > 0)
      type = 'Seperated';

    trace('[INFO] Voices Type for "$audioPath": $type');
  }

  /**
   * Call this function to play the sound - also works on paused sounds.
   *
   * @param forceRestart Whether to start the sound over or not. Default value is false.
   * @param startTime At which point to start playing the sound, in milliseconds.
   * @param endTime At which point to stop playing the sound, in milliseconds. If not set / `null`, the sound completes normally.
   *
   * @see `FlxSound.play`
   */
  public function play(forceRestart:Bool = false, startTime:Float = 0.0, ?endTime:Float):Void
  {
    for (sound in sounds)
    {
      sound.play(forceRestart, startTime, endTime);
    }
  }

  /**
   * This function is for resyncing vocals. Please call sparingly, ideally for every music section only.
   */
  public function tryResync():Void
  {
    for (sound in sounds)
      syncVocals(sound);
  }

  function syncVocals(vocals:Null<FlxSound>):Void
  {
    if (vocals == null)
      return;

    // maybe even log time difference
    // -silver984

    // Sure why not
    // -Til

    var timeDif:Float = vocals.time - FlxG.sound.music.time;
    // in milliseconds
    var delayThreshold:Float = 10;
    if (Math.abs(timeDif) >= delayThreshold)
    {
      vocals.time = FlxG.sound.music.time;
      trace('[WARNING] Vocals member resynced: abs($timeDif) >= $delayThreshold');
    }
  }
}
