package funkin.util.paths;

import openfl.Assets;

/**
 * A Paths class that helps returning strings of paths.
 */
class PathsLocation
{
	/**
	 * This just ensures that the paths existence is here.
	 *
	 * There is no variables that need to be initialized however u will need to call this to be able to call functions from this class otherwise its null.
	 */
	public function new()
	{
		//
	}

	/**
	 * Returns a path with the audio extenstion at the end.
	 * @param key The path to get.
	 * @return assets/`key`.`Paths.AUDIO_EXT`
	 */
	public function audio(key:String):String
	{
		return get(key + '.' + Paths.AUDIO_EXT);
	}

	/**
	 * Returns a path with the image extenstion at the end.
	 * @param key The path to get.
	 * @return assets/`key`.`Paths.IMAGE_EXT`
	 */
	public function image(key:String):String
	{
		return get(key + '.' + Paths.IMAGE_EXT);
	}

	/**
	 * Returns a path with the script extenstion at the end.
	 * @param key The path to get.
	 * @return assets/`key`.`Paths.SCRIPT_EXT`
	 */
	public function script(key:String):String
	{
		return get(key + '.' + Paths.SCRIPT_EXT);
	}

	/**
	 * Returns a path that adds `.xml` to the end.
	 * @param key The path to get
	 * @return assets/`key`.xml
	 */
	public function xml(key:String):String
	{
		return get(key + '.xml');
	}

	/**
	 * Returns a path. Only returns assets/ + key since theres no mod support (yet.)
	 * @param key The path to get.
	 * @return assets/`key`
	 */
	public function get(key:String):String
	{
		return 'assets/' + key;
	}

	/**
	 * Checks to see if a file exists inside the game.
	 * @param key The path to check the existence on.
	 * @return True if the file exists inside the game.
	 */
	public function exists(key:String):Bool
	{
		var path:String = get(key);

		if (Assets.exists(path))
		{
			return true;
		}

		return false;
	}
}
