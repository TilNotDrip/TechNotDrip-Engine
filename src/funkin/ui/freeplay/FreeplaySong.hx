package funkin.ui.freeplay;

import funkin.data.song.Song;
import funkin.data.song.SongFormat.SongFreeplayData;

class FreeplaySong
{
  /**
   * The internal song.
   */
  public final song:Song;

  final parent:FreeplayState;

  public function new(song:Song, parent:FreeplayState)
  {
    this.song = song;
    this.parent = parent;
  }

  /**
   * All difficulties.
   */
  public var difficulties(get, never):Array<String>;

  function get_difficulties():Array<String>
  {
    return song.getDifficulties(null);
  }

  /**
   * Display Name of this song.
   */
  public var displayName(get, never):String;

  function get_displayName():String
  {
    return song.getDisplayName(curVariation);
  }

  /**
   * Freeplay Icon of this song
   */
  public var freeplayIcon(get, never):String;

  function get_freeplayIcon():String
  {
    var freeplayData:Null<SongFreeplayData> = song.getFreeplayData(curVariation);
    return freeplayData?.icon;
  }

  /**
   * The current variation.
   * This is based off of the current difficulty.
   */
  public var curVariation(get, never):String;

  function get_curVariation():String
  {
    for (variation in song.variations)
    {
      final difficulties:Array<String> = song.getDifficulties(variation);

      if (difficulties.contains(parent.curDifficulty))
        return variation;
    }

    return Constants.DEFAULT_VARIATION;
  }

  /**
   * If the song has the current difficulty or not.
   */
  public var hasDifficulty(get, never):Bool;

  function get_hasDifficulty():Bool
  {
    return difficulties.contains(parent.curDifficulty);
  }
}
