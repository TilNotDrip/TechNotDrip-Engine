package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.util.typeLimit.NextState;
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

		final gameData:GameData = {
			screenWidth: 1280,
			screenHeight: 720,
			initState: TitleState.new,
			framerate: 60,
			isSkipSplash: true,
			isStartFullscreen: false
		};

		var flxGame:FlxGame = new FlxGame(
			gameData.screenWidth,
			gameData.screenHeight,
			gameData.initState,
			gameData.framerate,
			gameData.framerate,
			gameData.isSkipSplash,
			gameData.isStartFullscreen
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

typedef GameData =
{
	var screenWidth:Int;
	var screenHeight:Int;
	var initState:InitialState;
	var framerate:Int;
	var isSkipSplash:Bool;
	var isStartFullscreen:Bool;
}
