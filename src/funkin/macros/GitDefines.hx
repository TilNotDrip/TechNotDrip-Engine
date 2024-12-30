package funkin.macros;

#if !display
#if FUNKIN_GIT_DETAILS
import haxe.macro.Context;
import haxe.macro.Expr;

class GitDefines
{
	/**
	 * Get the SHA1 hash of the current Git commit.
	 * @return The current git repository hash.
	 */
	public static macro function gitCommitHash():ExprOf<String>
	{
		return macro $v{Context.definedValue('TND_GIT_HASH')};
	}

	/**
	 * Get the branch name of the current Git commit.
	 * @return The current git repository branch.
	 */
	public static macro function gitBranch():ExprOf<String>
	{
		return macro $v{Context.definedValue('TND_GIT_BRANCH')};
	}

	/**
	 * Get whether the local Git repository is modified or not.
	 * @return Is the git repository modified?
	 */
	public static macro function gitModified():ExprOf<Bool>
	{
		return macro $v{Context.defined('TND_GIT_MODIFIED')};
	}
}
#end
#end
