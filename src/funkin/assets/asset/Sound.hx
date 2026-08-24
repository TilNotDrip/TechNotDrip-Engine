package funkin.assets.asset;

import hxd.res.Sound as SoundResource;
import hxd.snd.Channel;
import hxd.snd.Data as SoundData;
import hxd.snd.Mp3Data;
import hxd.snd.OggData;
import hxd.snd.WavData;

class Sound implements IFunkinAsset
{
  var _wrapper:Null<SoundWrapper> = null;
  var _data:Null<SoundData> = null;

  /**
   * Fetches the Heaps resource for this sound.
   * @return The resource, if possible.
   */
  public function resource():Null<SoundResource>
  {
    return _wrapper;
  }

  /**
   * Fetches data for this sound.
   * @return The sound data, if possible.
   */
  public function data():Null<SoundData>
  {
    return _data;
  }

  /**
   * Loads the sound into memory, synchronously.
   * @param file The audio file to use for loading.
   */
  public function load(file:FileEntry):Void
  {
    // TODO: Move to a different sound engine.
    // The Heaps Sound Engine has syncing issues,
    // which isn't the greatest for a rhythm game!

    final byte:Int = file.fetchBytes(0, 1).get(0);
    _data = switch (byte)
    {
      case 'R'.code:
        new WavData(file.getBytes());
      case 'I'.code, 255:
        new Mp3Data(file.getBytes());
      case 'O'.code:
        #if (hl || stb_ogg_sound)
        new OggData(file.getBytes());
        #else
        trace('OGG format is not supported.');
        null;
        #end
      default:
        trace('Unknown Format is not supported.');
        null;
    }

    _wrapper = new SoundWrapper(file, _data);
  }

  /**
   * Frees the sound from memory, synchronously.
   */
  public function dispose():Void
  {
    _wrapper = null;
    _data = null;
  }

  /**
   * This function does nothing.
   */
  public function prePurge():Void {}
}

private class SoundWrapper extends SoundResource
{
  public function new(file:FileEntry, data:SoundData)
  {
    super(file);
    this.data = data;
  }

  override public function getData():SoundData
  {
    return data;
  }

  override public function dispose():Void
  {
    data = null;
  }

  override public function stop():Void
  {
    throw 'Use `FunkinSound` instead.';
  }

  override public function play(?loop, ?volume, ?channelGroup, ?soundGroup):Channel
  {
    throw 'Use `FunkinSound` instead.';
  }

  override function watchCallb():Void {}
}
