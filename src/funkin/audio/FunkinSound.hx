package funkin.audio;

import hxd.snd.Channel;
import hxd.snd.Manager;

@:access(hxd.snd.Channel)
class FunkinSound
{
  /**
   * The main volume applied to all sounds within the game
   */
  public static var masterVolume(default, set):Float = 1.0;

  /**
   * The optional music currently playing.
   */
  public static var music:Null<FunkinSound>;

  static var _soundList:Array<FunkinSound> = [];

  /**
   * Whether the sound should be automatically disposed once the sound is finished.
   * @default true
   */
  public var autoDispose:Bool = true;

  /**
   * The group that this sound is attached to.
   */
  public var group:Null<FunkinSoundGroup>;

  /**
   * The current position of the sound playing in seconds.
   */
  public var time(get, set):Float;

  /**
   * The time that the sound will start playing at.
   * @default 0.0
   */
  public var startTime:Float = 0.0;

  /**
   * The time that the sound will stop playing at.
   */
  public var endTime:Null<Float>;

  /**
   * The length of the sound in seconds.
   */
  public var length(get, never):Float;

  /**
   * Whether the sound should loop on end or not.
   * @default false
   */
  public var looped:Bool = false;

  /**
   * The amount of times the sound has looped.
   */
  public var loopCount(default, null):Int = 0;

  /**
   * The amount of loops it'll take until the sound stops looping.
   *
   * If the value is set to -1 then the sound will loop forever.
   * @default -1
   */
  public var loopUntil:Int = -1;

  /**
   * The time that the sound will start at once it loops.
   */
  public var loopTime:Null<Float>;

  /**
   * Whether the sound is currently playing or not.
   */
  public var playing(get, never):Bool;

  /**
   * How loud the sound will be while being played.
   * @default 1.0
   */
  public var volume(default, set):Float = 1.0;

  /**
   * A callback for once the sound is complete.
   */
  public var onComplete:Null<() -> Void> = null;

  var _paused:Bool = false;

  var currentSound:Null<Sound>;
  var currentChannel:Null<Channel>;

  public function new(path:String)
  {
    currentSound = Paths.content.audio(path);

    Main.instance.preUpdate.add(update);

    _soundList.push(this);
  }

  public function update(dt:Float):Void
  {
    if (endTime != null && time >= endTime)
    {
      stopSound();
    }
  }

  public function dispose():Void
  {
    Main.instance.preUpdate.remove(update);
    _soundList.remove(this);
    group?.remove(this);

    stop();
    currentSound = null;
    currentChannel = null;
  }

  /**
   * Play the loaded sound. Also works as an alternative to `resume()`
   * @param restart Whether the sound should be restarted or not.
   * @param startTime What time in seconds should the sound start at?
   * @param endTime What time in seconds should the sound end at?
   * @return This instance of `FunkinSound`
   */
  public function play(restart:Bool = false, ?startTime:Float, ?endTime:Float):FunkinSound
  {
    if (startTime != null)
    {
      this.startTime = startTime;
    }

    if (endTime != null)
    {
      this.endTime = endTime;
    }

    if (restart)
    {
      stop();
    }

    if (_paused)
    {
      resume();
    }
    else
    {
      startSound(startTime);
    }

    return this;
  }

  /**
   * Resume the currently paused sound.
   * @return This instance of `FunkinSound`
   */
  public function resume():FunkinSound
  {
    if (_paused && currentChannel != null)
    {
      currentChannel.pause = false;
    }

    return this;
  }

  /**
   * Pauses the currently playing sound.
   * @return This instance of `FunkinSound`
   */
  public function pause():FunkinSound
  {
    if (currentChannel != null)
    {
      currentChannel.pause = true;
    }

    _paused = true;

    return this;
  }

  /**
   * Stops the currently playing sound.
   * @return This instance of `FunkinSound`
   */
  public function stop():FunkinSound
  {
    currentChannel?.stop();
    return this;
  }

  function startSound(startTime:Float = 0):Void
  {
    currentChannel = Manager.get().play(currentSound);
    currentChannel.onEnd = stopSound;
    time = startTime;
    _paused = false;
    updateTransform();
  }

  function stopSound():Void
  {
    if (onComplete != null)
    {
      onComplete();
    }

    if (looped && (loopUntil == -1 || loopUntil > loopCount))
    {
      loopCount++;
      startSound(loopTime ?? startTime);
    }
    else if (autoDispose)
    {
      dispose();
    }
  }

  @:allow(funkin.audio.FunkinSoundGroup)
  function updateTransform():Void
  {
    if (currentChannel == null)
    {
      return;
    }

    if (group?.muted)
    {
      currentChannel.volume = 0;
      return;
    }

    final grpVolume:Float = group?.volume ?? 1;
    currentChannel.volume = masterVolume * grpVolume * volume;
  }

  function get_length():Float
  {
    return currentChannel?.duration ?? 0.0;
  }

  function get_time():Float
  {
    return currentChannel?.position ?? 0.0;
  }

  function set_time(value:Float):Float
  {
    value = value.clamp(0.0, (endTime ?? currentChannel?.duration) ?? 0.0);
    currentChannel.position = value;
    return currentChannel?.position ?? 0.0;
  }

  function get_playing():Bool
  {
    return !currentChannel?.pause ?? false;
  }

  function set_volume(value:Float):Float
  {
    volume = value.clamp(0.0, 1.0);
    updateTransform();
    return volume;
  }

  /**
   * Plays a music track.
   * @param path The location of the audio to play.
   * @param looped Whether the music should be looped after it's finished or not.
   * @param volume The volume of the music.
   * @return The music instance of `FunkinSound`. (Alternatively you can also use `funkin.audio.FunkinSound.music`)
   */
  public static function playMusic(path:String, ?looped:Bool, ?vol:Float = 1.0):FunkinSound
  {
    music?.stop();
    music?.dispose();

    music = new FunkinSound(path);
    music.play();
    music.looped = looped;
    music.volume = vol ?? 1.0;

    return music;
  }

  /**
   * Plays a sound once then destroys it.
   * @param path The location of the audio to play
   * @param volume The volume of the sound
   * @param onComplete The callback to play once the sound is completed
   * @return The instance of the once played `FunkinSound`.
   */
  public static function playOnce(path:String, ?volume:Float = 1.0, ?onComplete:Void->Void):Null<FunkinSound>
  {
    var sound:FunkinSound = new FunkinSound(path);
    sound.autoDispose = true;
    sound.volume = volume ?? 1.0;

    if (onComplete != null)
    {
      sound.onComplete = onComplete;
    }

    sound.play();

    return sound;
  }

  static function set_masterVolume(value:Float):Float
  {
    masterVolume = value.clamp(0.0, 1.0);

    for (sound in _soundList)
    {
      sound.updateTransform();
    }

    return masterVolume;
  }
}
