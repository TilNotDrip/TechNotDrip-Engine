package funkin;

import funkin.macros.Git;

class Constants
{
	/**
	 * The version of TechNotDrip Engine.
	 */
	public static final VERSION:String = '0.1';

	/**
	 * The version of Friday Night Funkin' that TechNotDrip Engine is based off of.
	 */
	public static final FNF_VERSION:String = '0.4';

	/**
	 * The current Git Commit Hash.
	 */
	public static final GIT_HASH:String = Git.getGitCommitHash();

	/**
	 * The current Git Branch.
	 */
	public static final GIT_BRANCH:String = Git.getGitBranch();

	/**
	 * If there is local changes to the git branch.
	 */
	public static final GIT_LOCAL_CHANGES:Bool = Git.getGitHasLocalChanges();
}
