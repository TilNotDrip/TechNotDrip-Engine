package funkin;

import funkin.macros.GitDefines;

class Constants
{
	/**
	 * The version of TechNotDrip Engine.
	 */
	public static var TECHNOTDRIP_VERSION(get, never):String;

	/**
	 * The version of Friday Night Funkin' that TechNotDrip Engine is based off of.
	 */
	public static final FNF_VERSION:String = '0.5.3';

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

	/**
	 * How much space difficulties in Story Mode can have until they are sized down.
	 */
	public static final DIFFICULTY_SPACING:Float = 320;

	/**
	 * The vertical offset of the strumline from the top edge of the screen.
	 */
	public static final STRUMLINE_Y_OFFSET:Float = 50;

	/**
	 * A magic number used when calculating scroll speed and note distances.
	 */
	public static final PIXELS_PER_MS:Float = 0.45;

	/**
	 * Default Difficulties
	 */
	public static final DEFAULT_DIFFICULTIES:Array<String> = ['easy', 'normal', 'hard', 'erect', 'nightmare'];

	static function get_TECHNOTDRIP_VERSION():String
	{
		return FlxG.stage.application.meta.get('version');
	}
}
