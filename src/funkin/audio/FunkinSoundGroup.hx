package funkin.audio;

class FunkinSoundGroup
{
  /**
   * The sounds inside this group.
   */
  public var sounds:Array<FunkinSound> = [];

  /**
   * The volume for this group
   */
  public var volume(default, set):Float;

  /**
   * Whether the sounds inside this group are muted or not.
   */
  public var muted(default, set):Bool;

  public function new(volume:Float = 1)
  {
    this.volume = volume;
  }

  /**
   * Adds a sound to this group.
   * @param sound The sound to be added to the group.
   * @return Whether the sound was added or not.
   */
  public function add(sound:FunkinSound):Bool
  {
    if (!sounds.contains(sound))
    {
      if (sound.group != null)
      {
        sound.group.sounds.remove(sound);
      }

      sounds.push(sound);
      sound.group = this;
      sound.updateTransform();
      return true;
    }

    return false;
  }

  /**
   * Removes a sound from this group.
   * @param sound The sound to be removed from the group.
   * @return Whether the sound was removed or not.
   */
  public function remove(sound:FunkinSound):Bool
  {
    if (sounds.contains(sound))
    {
      sound.group = null;
      sounds.remove(sound);
      sound.updateTransform();
      return true;
    }

    return false;
  }

  /**
   * Resumes playback of all sounds within this group.
   */
  public function resume():Void
  {
    for (sound in sounds)
    {
      sound.resume();
    }
  }

  /**
   * Pauses all playback from sounds within this group.
   */
  public function pause():Void
  {
    for (sound in sounds)
    {
      sound.pause();
    }
  }

  function set_volume(value:Float):Float
  {
    volume = value.clamp(0.0, 1.0);

    for (sound in sounds)
    {
      sound.updateTransform();
    }

    return volume;
  }

  function set_muted(value:Bool):Bool
  {
    muted = value;

    for (sound in sounds)
    {
      sound.updateTransform();
    }

    return muted;
  }
}
