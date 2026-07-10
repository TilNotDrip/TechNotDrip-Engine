package funkin.audio;

import hxd.snd.Channel;
import hxd.snd.Manager;

class FunkinSound
{
  /**
   * The optional music currently playing.
   */
  public static var music:Null<Channel>;

  public static function playMusic(path:String, ?looped:Bool, ?volume:Float):Void
  {
    music?.stop();

    final sound:Sound = Paths.content.audio(path);
    music = sound.play(looped ?? false, volume ?? 1);
  }
}
