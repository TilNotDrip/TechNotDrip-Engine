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
  /**
   * The Song ID used for getting Voices.
   */
  public var songID:String;

  /**
   * The opponent vocals, if they exist.
   * @see `getOpponent()`
   */
  var opponent:Null<FlxSound>;

  /**
   * The player vocals, if they exist.
   * @see `getPlayer()`
   */
  var player:Null<FlxSound>;

  /**
   * The combined vocals, if they exist.
   *
   * For better context, this is a fallback to `Voices.ogg`
   * @see `getOpponent()`
   * @see `getPlayer()`
   */
  var combined:Null<FlxSound>;

  public function new(songID:String)
  {
    var songPath:String = 'gameplay/songs/${songID}';
    this.songID = songID;

    var opponentSound:Null<Sound> = null;
    var playerSound:Null<Sound> = null;
    var combinedSound:Null<Sound> = null;

    super();

    // TODO: when character IDs are available, search through those too.

    if (opponentSound == null && Paths.location.exists('${songPath}/Voices-Opponent.${Paths.AUDIO_EXT}'))
      opponentSound = Paths.content.audio('${songPath}/Voices-Opponent');

    if (playerSound == null && Paths.location.exists('${songPath}/Voices-Player.${Paths.AUDIO_EXT}'))
      playerSound = Paths.content.audio('${songPath}/Voices-Player');

    if (opponentSound == null && playerSound == null)
    {
      if (Paths.location.exists('${songPath}/Voices.${Paths.AUDIO_EXT}'))
      {
        combinedSound = Paths.content.audio('${songPath}/Voices');

        // Invalidate all other sounds, if they exist.
        opponentSound = null;
        playerSound = null;
      }
    }

    if (combinedSound != null)
    {
      combined = FlxG.sound.load(combinedSound);
      this.add(combined);
    }

    if (opponentSound != null)
    {
      opponent = FlxG.sound.load(opponentSound);
      this.add(opponent);
    }

    if (playerSound != null)
    {
      player = FlxG.sound.load(playerSound);
      this.add(player);
    }
  }

  /**
   * Trace useful info about the vocals.
   */
  public function traceInfo():Void
  {
    if (opponent != null && player != null)
    {
      trace('[INFO] Voices Type for "${songID}": Opponent and Player seperated');
    }
    else if (combined != null)
    {
      trace('[INFO] Voices Type for "${songID}": Opponent and Player pair');
    }
    else
    {
      trace('[INFO] Voices Type for "${songID}": None found');
    }
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
    if (combined != null)
    {
      syncVocals(combined);
      return;
    }

    syncVocals(player);
    syncVocals(opponent);
  }

  // maybe even log time difference
  // -silver984
  private function syncVocals(vocals:Null<FlxSound>):Void
  {
    if (vocals != null)
    {
      var timeDif:Float = vocals.time - FlxG.sound.music.time;
      // in milliseconds
      var delayThreshold:Float = 10;
      if (Math.abs(timeDif) >= delayThreshold)
      {
        vocals.time = FlxG.sound.music.time;
      }
    }
  }

  /**
   * Gets the player vocals, if they exist.
   * @return A `FlxSound` instance containing the vocals. If it's `null`, they do not exist.
   */
  public function getPlayer():Null<FlxSound>
  {
    if (combined != null)
      return combined;

    return player;
  }

  /**
   * Gets the opponent vocals, if they exist.
   * @return A `FlxSound` instance containing the vocals. If it's `null`, they do not exist.
   */
  public function getOpponent():Null<FlxSound>
  {
    if (combined != null)
      return combined;

    return opponent;
  }
}
