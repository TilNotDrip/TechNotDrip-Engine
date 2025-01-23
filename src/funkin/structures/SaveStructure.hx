package funkin.structures;

import funkin.util.Controls.ControlMappings;

typedef SaveStructure =
{
	/**
	 * Flixel Volume.
	 */
	var volume:Float;

	/**
	 * Flixel Mute.
	 */
	var mute:Bool;

	/**
	 * The version of Save this is.
	 */
	var version:String;

	/**
	 * PlayState Progress.
	 */
	var progress:ProgressStructure;

	/**
	 * Options.
	 */
	var options:OptionStructure;

	/**
	 * Controls.
	 */
	var controls:ControlMappings;
}

typedef ProgressStructure =
{
	/**
	 * This is used for saving story mode progress, in case you close the game during the game.
	 * Int is in songs completed, it will reset once the week is completed.
	 */
	var storyMode:Map<String, Int>;

	/**
	 * Story Mode and Freeplay Highscores.
	 */
	var highscores:HighscoreStructures;
}

typedef HighscoreStructures =
{
	/**
	 * Story Mode Highscores.
	 *
	 * Week ID => Highscore.
	 */
	var storyMode:Map<String, Int>;

	/**
	 * Freeplay Highscores.
	 *
	 * Song ID => Highscore.
	 */
	var freeplay:Map<String, Int>;
};

typedef OptionStructure =
{
	/**
	 * The frames-per-second that the game will run at.
	 */
	var fps:Int;

	/**
	 * If the FPS Counter is visible.
	 */
	var showFps:Bool;

	/**
	 * Should the game be fullscreen?
	 */
	var fullscreen:Bool;

	/**
	 * If antialiasing should be enabled.
	 */
	var antialiasing:Bool;

	/**
	 * If flashing lights are enabled.
	 */
	var flashingLights:Bool;

	/**
	 * If auto pause is on.
	 * Auto pause pauses the game when you tab out.
	 */
	var autoPause:Bool;

	/**
	 * If the game should use the system cursor instead of using the default flixel one.
	 */
	var systemCursor:Bool;

	/**
	 * If the engine should block potentially malicious processes.
	 */
	var safeMode:Bool;

	/**
	 * If the game should enable debug logs, key combos, etc.
	 */
	var devMode:Bool;
}
