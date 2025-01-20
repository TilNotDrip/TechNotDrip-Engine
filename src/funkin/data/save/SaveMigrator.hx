package funkin.data.save;

import flixel.util.FlxSave;
import funkin.structures.SaveStructure;

class SaveMigrator
{
	public static function migrateSave(saveData:Dynamic):Save
	{
		var version:Null<Version> = null;

		try
		{
			version = Version.stringToVersion(saveData?.version);
		}
		catch (e)
		{
			trace('[SAVE NOTICE] Migrating save data has an invalid version.');
			version = null;
		}

		if (version == null)
			return new Save();

		if (Save.SAVE_VERSION != version && version > Save.SAVE_VERSION)
		{
			var slot:Int = Save.saveToBackupSlot(saveData);
			SystemUtil.alert('Save Warning!',
				'The current save loaded is a higher version than what this game supports!\nThis may make unexpected things happen!\nJust in case, the game has put this save in ${Save.SAVE_NAME}$slot as a backup.');
		}

		if (version != Save.SAVE_VERSION && version.satisfies(Save.SAVE_VERSION_RULE))
		{
			trace('Old/New version ($version) compatible with new/old (${Save.SAVE_VERSION})');
			var defaultData:Dynamic = Save.getDefault();

			saveData = ReflectUtil.deepMerge(defaultData, saveData, false);

			saveData.version = Save.SAVE_VERSION;
		}

		return new Save(saveData);
	}

	/**
	 * Migrates your Chillin' Engine save for the 3 people that used it.
	 * @return The converted save file.
	 */
	public static function migrateChillinEngine():Save
	{
		var oldSave:FlxSave = new FlxSave();
		var newSave:SaveStructure = Save.getDefault();

		// HIGHSCORES
		oldSave.bind('scores', 'tilnotdrip');

		var songScores:Map<String, Int> = oldSave.data?.songScores ?? new Map<String, Int>();

		for (id in songScores.keys())
		{
			if (id.startsWith('week')) // week and weekend both start with week, must be like this
			{
				newSave.progress.highscores.storyMode.set(id, songScores.get(id));
				newSave.progress.storyMode.set(id, 0);
			}
			else
			{
				newSave.progress.highscores.freeplay.set(id, songScores.get(id));
			}
		}

		// CONTROLS
		// i think i mightve disabled saving for these, but its worth a shot
		oldSave.bind('controls', 'tilnotdrip');

		var controls:Map<String, Array<Array<Int>>> = oldSave.data?.controls ?? new Map<String, Array<Array<Int>>>();

		for (control in controls.keys())
		{
			var value:Array<Array<Int>> = controls.get(control);
			newSave.controls.set(control, {keyboard: value[0], gamepad: value[1]});
		}

		// OPTIONS
		var isLegacy:Bool = false;
		oldSave.bind('options', 'tilnotdrip');

		isLegacy = oldSave.isEmpty();

		if (isLegacy)
			oldSave.bind('settings', 'tilnotdrip');

		var options:Map<String, Dynamic> = null;

		if (isLegacy)
		{
			options = new Map<String, Dynamic>();

			var maps:Array<Map<String, Dynamic>> = [
				oldSave.data.displaySettings,
				oldSave.data.gameplaySettings,
				oldSave.data.flixelSettings,
				oldSave.data.otherSettings
			];
			for (map in maps)
			{
				for (key in map.keys())
				{
					options.set(key, map.get(key));
				}
			}
		}
		else
		{
			options = oldSave.data?.options;
		}

		newSave.options.fps = options.get('fps');
		newSave.options.fpsCounter = options.get('fpsCounter');
		newSave.options.fullscreen = options.get('fullscreen');
		newSave.options.antialiasing = options.get('antialiasing');
		newSave.options.flashingLights = options.get('flashingLights');
		newSave.options.autoPause = options.get('autoPause');
		newSave.options.systemCursor = options.get('systemCursor');
		newSave.options.safeMode = options.get('safeMode');
		newSave.options.devMode = options.get('devMode');

		return new Save(newSave);
	}
}
