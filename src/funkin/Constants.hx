package funkin;

#if FUNKIN_GIT_DETAILS
import funkin.util.macro.GitDefines;
#end

class Constants
{
  /**
   * The version of TechNotDrip Engine.
   */
  public static var TECHNOTDRIP_VERSION(get, never):String;

  /**
   * The version of Friday Night Funkin' that TechNotDrip Engine is based off of.
   */
  public static final FNF_VERSION:String = '0.8.5';

  #if FUNKIN_GIT_DETAILS
  /**
   * The current Git Commit Hash.
   */
  public static final GIT_HASH:String = GitDefines.gitCommitHash();

  /**
   * The current Git Commit Hash but shortened.
   */
  public static final GIT_HASH_SPLICED:String = GitDefines.gitCommitHash().substr(0, 7);

  /**
   * The current Git Branch.
   */
  public static final GIT_BRANCH:String = GitDefines.gitBranch();

  /**
   * If there is local changes to the git branch.
   */
  public static final GIT_MODIFIED:Bool = GitDefines.gitModified();
  #end

  /**
   * Default Difficulties
   */
  public static final DEFAULT_DIFFICULTIES:Array<String> = ['easy', 'normal', 'hard', 'erect', 'nightmare'];

  /**
   * Default Difficulty
   */
  public static final DEFAULT_DIFFICULTY:String = 'normal';

  /**
   * How much space difficulties in Story Mode can have until they are sized down.
   */
  public static final DIFFICULTY_SPACING:Float = 320;

  /**
   * The value that the players health can be maxed out to in PlayState.
   */
  public static final HEALTH_MAXIMUM:Float = 2.0;

  /**
   * The value that the players health starts out at in PlayState.
   */
  public static final HEALTH_DEFAULT:Float = 1.0;

  /**
   * The value that the player can go down to before they die in PlayState.
   */
  public static final HEALTH_MINIMUM:Float = 0.0;

  /**
   * A magic number used when calculating scroll speed and note distances.
   */
  public static final PIXELS_PER_MS:Float = 0.45;

  /**
   * The vertical offset of the strumline from the top edge of the screen.
   */
  public static final STRUMLINE_Y_OFFSET:Float = 50;

  /**
   * The atlas font that should be used when no font is supplied.
   */
  public static final DEFAULT_ATLAS_FONT:String = 'default';

  static function get_TECHNOTDRIP_VERSION():String
  {
    return FlxG.stage.application.meta.get('version');
  }
}
