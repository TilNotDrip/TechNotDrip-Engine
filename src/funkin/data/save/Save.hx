package funkin.data.save;

import flixel.util.FlxSave;
import funkin.structures.SaveStructure;
import funkin.util.Controls;

class Save
{
	/**
	 * The path of which saves are loaded from. Usually the company name.
	 */
	public static final SAVE_PATH:String = 'TilNotDrip';

	/**
	 * The name of which saves are loaded from. Usually the name of the application.
	 */
	public static final SAVE_NAME:String = 'TechNotDrip';

	/**
	 * The current version of save file.
	 */
	public static final SAVE_VERSION:String = '1';

	public static var instance(get, never):Save;
	static var _instance:Null<Save> = null;

	static function get_instance():Save
	{
		if (_instance == null)
		{
			return _instance = loadFromSaveSlot(1);
		}
		return _instance;
	}

	public var data:SaveStructure = null;

	public function new(?data:SaveStructure)
	{
		if (data == null)
			this.data = getDefault();
		else
			this.data = data;

		#if debug
		registerConsoleFunctions();
		#end
	}

	function registerConsoleFunctions():Void
	{
		FlxG.console.registerFunction("setControlByName", function(name:String, keyboard:Array<Int>, ?gamepad:Array<Int>)
		{
			var controlValue:Null<{keyboard:Array<Int>, gamepad:Array<Int>}> = getControls().get(name);

			if (keyboard != null)
				controlValue.keyboard = keyboard;

			if (gamepad != null)
				controlValue.gamepad = gamepad;

			getControls().set(name, controlValue);
			flush();
		});
	}

	/**
	 * Gets the Saved Controls.
	 * @return The Controls.
	 */
	public function getControls():ControlMappings
	{
		var controls:ControlMappings = data.controls;

		if (controls == null)
		{
			controls = getDefault().controls;
			flush();
		}

		return controls;
	}

	/**
	 * Options for the game
	 */
	public var options(get, set):OptionStructure;

	function set_options(value:OptionStructure):OptionStructure
	{
		data.options = value;
		flush();
		return data.options;
	}

	function get_options():OptionStructure
	{
		return data.options;
	}

	/**
	 * idk what to put here
	 */
	public function setOptionValues():Void
	{
		FlxG.updateFramerate = FlxG.drawFramerate = options.fps;

		if (Main.performanceStats != null)
			Main.performanceStats.visible = options.fpsCounter;

		FlxG.fullscreen = options.fullscreen;

		FlxSprite.defaultAntialiasing = options.antialiasing;

		FlxG.autoPause = options.autoPause;

		#if FLX_MOUSE
		FlxG.mouse.useSystemCursor = options.systemCursor;
		#end
	}

	/**
	 * Flushes the save data.
	 */
	public function flush():Void
	{
		data.volume = FlxG.sound.volume;
		data.mute = FlxG.sound.muted;

		FlxG.save.mergeData(data, true);
	}

	public static function getDefault():SaveStructure
	{
		return {
			version: SAVE_VERSION,

			volume: 1.0,
			mute: false,
			progress: {
				storyMode: new Map<String, Int>(),
				highscores: {
					storyMode: new Map<String, Int>(),
					freeplay: new Map<String, Int>(),
				}
			},
			options: {
				fps: 60,
				fpsCounter: true,
				fullscreen: false,
				antialiasing: true,
				autoPause: true,
				systemCursor: false,
				safeMode: true,
				devMode: false
			},
			controls: Controls.getDefaultMappings()
		};
	}

	static function loadFromSaveSlot(slot:Int):Save
	{
		FlxG.log.add('[SAVE] Loading save from slot $slot [${SAVE_NAME + slot}]');
		FlxG.save.bind(SAVE_NAME + slot, SAVE_PATH);

		switch (FlxG.save.status)
		{
			case EMPTY:
				FlxG.log.add('[SAVE] No save data found, binding new...');

			case ERROR(msg):
				FlxG.log.add('[SAVE] Error loading save! More info: $msg');

			case BOUND(_, _):
				FlxG.log.add('[SAVE] Found bounded save!');
				var gameSave:Save = SaveMigrator.migrateSave(FlxG.save.data);
				FlxG.save.mergeData(gameSave.data, true);

				return gameSave;
		}

		return null;
	}
}
