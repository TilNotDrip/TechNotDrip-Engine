package funkin.ui.story;

import flixel.FlxState;
import funkin.data.song.Song;
import funkin.data.week.Week;
import funkin.play.PlayState;
import funkin.ui.story.StoryModeState;

/**
 * Story Mode Handler for `PlayState`.
 */
class StoryModeHandler
{
  /**
   * The current week for this Story Mode session.
   */
  public var week:Week;

  /**
   * The song queue for this Story Mode session.
   * Based off of `week.songs`.
   */
  public var songQueue:Array<Song> = [];

  /**
   * The current difficulty for this Story Mode session.
   * If the current difficulty doesn't exist or is `null`, `Constants.DEFAULT_DIFFICULTY` is used.
   * If `Constants.DEFAULT_DIFFICULTY` isn't available, songs will be skipped until a song with this difficulty is available.
   */
  public var difficulty:Null<String> = null;

  /**
   * Creates a Story Mode Handler.
   * @param week The week to use for this Story Mode session.
   * @param difficulty The difficulty to use for this Story Mode Session. See `difficulty` for more information.
   */
  public function new(week:Week, ?difficulty:Null<String> = null)
  {
    this.week = week;
    this.difficulty = difficulty;
    songQueue = week.songs;
  }

  /**
   * Generates a `PlayState` based on the next song in queue.
   * To be used as the parameter for `FlxG.switchState`
   * @return `FlxState`
   */
  public function nextState():FlxState
  {
    var foundSong:Song = null;
    var difficultyToUse:String = difficulty;

    while (foundSong == null)
    {
      foundSong = songQueue.shift();
      if (foundSong == null)
        break;

      var difficulties:Array<String> = foundSong.getDifficulties();

      if (difficulties.contains(difficulty))
      {
        difficultyToUse = difficulty;
        break;
      }

      if (difficulties.contains(Constants.DEFAULT_DIFFICULTY))
      {
        difficultyToUse = Constants.DEFAULT_DIFFICULTY;
        break;
      }

      foundSong = null;
    }

    if (foundSong == null)
    {
      FlxG.sound.music.onComplete = null;
      FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
      return new StoryModeState();
    }

    return new PlayState({
      variation: 'default',
      song: foundSong,
      difficulty: difficultyToUse
    });
  }
}
