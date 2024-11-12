package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.util.typeLimit.NextState;
import funkin.objects.ui.PerformanceStats;
import funkin.states.ui.TitleState;
import openfl.Assets;
import openfl.display.Sprite;

class Main extends Sprite
{
	var flxGameData:FlxGameInit = {
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

		var performanceStats:PerformanceStats = new PerformanceStats(5, 5, 0xFFFFFF);
		addChild(performanceStats);

		Assets.cache.enabled = false;

		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		FlxSprite.defaultAntialiasing = true;
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
