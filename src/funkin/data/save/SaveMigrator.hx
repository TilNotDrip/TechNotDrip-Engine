package funkin.data.save;

import flixel.util.FlxSave;
import funkin.structures.SaveStructure;

class SaveMigrator
{
	public static function migrateSave(saveData:Dynamic):Save
	{
		var version:Null<String> = saveData.version;

		if (version == null)
			return new Save();

		switch (version)
		{
			default:
				return new Save(saveData);
		}
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
		newSave.options.autoPause = options.get('autoPause');
		newSave.options.systemCursor = options.get('systemCursor');
		newSave.options.safeMode = options.get('safeMode');
		newSave.options.devMode = options.get('devMode');

		return new Save(newSave);
	}
}
