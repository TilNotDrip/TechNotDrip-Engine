package funkin;

import funkin.macros.Git;

class Constants
{
	/**
	 * The version of TechNotDrip Engine.
	 */
	public static final TECHNOTDRIP_VERSION:String = '0.1';

	/**
	 * The version of Friday Night Funkin' that TechNotDrip Engine is based off of.
	 */
	public static final FNF_VERSION:String = '0.5.3';

	/**
	 * The current Git Commit Hash.
	 */
	public static final GIT_HASH:String = Git.gitCommitHash();

	/**
	 * The current Git Commit Hash but shortened.
	 */
	public static final GIT_HASH_SPLICED:String = Git.gitCommitHash().substr(0, 7);

	/**
	 * The current Git Branch.
	 */
	public static final GIT_BRANCH:String = Git.gitBranch();

	/**
	 * If there is local changes to the git branch.
	 */
	public static final GIT_MODIFIED:Bool = Git.gitModified();
}
