package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import funkin.data.save.Save;
import funkin.objects.ui.PerformanceStats;
import funkin.states.ui.TitleState;
import openfl.Assets;
import openfl.display.Sprite;
#if FUNKIN_DISCORD_RPC
import funkin.api.DiscordRPC;
#end

class Main extends Sprite
{
	/**
	 * The FPS and Memory overlay at the top left of the screen.
	 */
	public static var performanceStats:PerformanceStats;

	public function new()
	{
		super();

		var flxGame:FlxGame = new FlxGame(1280, // height
			720, // width
			TitleState.new, // initial state
			60, // framerate
			60, // draw framerate
			true, // skip splash?
			false // start full-screen?
		);
		addChild(flxGame);

		performanceStats = new PerformanceStats();
		addChild(performanceStats);

		Assets.cache.enabled = false;

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;
		#end

		FlxG.fixedTimestep = false;

		FlxSprite.defaultAntialiasing = true;

		Save.instance.setOptionValues();

		#if FUNKIN_DISCORD_RPC
		DiscordRPC.loadDiscordConfig();
		DiscordRPC.initialize();
		DiscordRPC.largeImageText = 'Version: ' + Constants.TECHNOTDRIP_VERSION;
		#end
	}
}
