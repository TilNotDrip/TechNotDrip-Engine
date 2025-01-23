package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.util.typeLimit.NextState;
import funkin.Constants;
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

	final flxGameData:FlxGameInit = {
		width: 1280,
		height: 720,
		initState: TitleState.new,
		framerate: 144,
		showSplash: false,
		startFullscreen: false
	};

	public function new()
	{
		super();

		initGame();
	}

	function initGame():Void
	{
		var flxGame:FlxGame = new FlxGame(flxGameData.width, flxGameData.height, flxGameData.initState, flxGameData.framerate, flxGameData.framerate,
			!flxGameData.showSplash, flxGameData.startFullscreen);
		addChild(flxGame);

		performanceStats = new PerformanceStats(5, 5, 0xFFFFFF);
		addChild(performanceStats);

		Assets.cache.enabled = false;

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

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

typedef FlxGameInit =
{
	var width:Int;
	var height:Int;
	var initState:InitialState;
	var framerate:Int;
	var showSplash:Bool;
	var startFullscreen:Bool;
}
