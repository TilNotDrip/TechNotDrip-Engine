package funkin.util;

#if js
import js.Browser;
#end

/**
 * A class related to messing around with the system but not maliciously.
 */
class SystemUtil
{
	/**
	 * Shows an alert to the user.
	 * @param title The title of the alert, if supported.
	 * @param content The content of the message.
	 */
	public static function alert(title:String, content:String):Void
	{
		#if desktop
		FlxG.stage.application.window.alert(content, title);
		#elseif js
		Browser.window.alert(content);
		#end
	}

	/**
	 * Closes the game.
	 */
	public static function close():Void
	{
		#if desktop
		FlxG.stage.application.window.close();
		#elseif js
		Browser.window.close();
		#end
	}

	/**
	 * Opens a URL in the user's browser.
	 * @param url The URL Link to open.
	 */
	public static function openURL(url:String):Void
	{
		#if linux
		Sys.command('/usr/bin/xdg-open $url &');
		#else
		FlxG.openURL(url);
		#end
	}
}
