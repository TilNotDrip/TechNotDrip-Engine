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

	static function get_TECHNOTDRIP_VERSION():String
	{
		return FlxG.stage.application.meta.get('version');
	}
}
