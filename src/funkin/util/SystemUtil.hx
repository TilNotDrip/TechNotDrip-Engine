package funkin.util;

/**
 * A class related to messing around with the system but not maliciously.
 */
class SystemUtil
{
	/**
	 * Opens a URL in the user's browser.
	 * @param url The URL Link to open.
	 */
	public static function openURL(url:String):Void
	{
		#if Linux
		Sys.command('/usr/bin/xdg-open $url &');
		#else
		FlxG.openURL(url);
		#end
	}
}
