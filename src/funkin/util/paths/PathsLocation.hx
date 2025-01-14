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
		if (key.startsWith('https://'))
			return get(key);

		return get(key + '.' + Paths.AUDIO_EXT);
	}

	/**
	 * Returns a path with the image extenstion at the end.
	 * @param key The path to get.
	 * @return assets/`key`.`Paths.IMAGE_EXT`
	 */
	public function image(key:String):String
	{
		if (key.startsWith('https://'))
			return get(key);

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
		// TODO: Better Link Detection system, this will do for the short run though.
		if (key.startsWith('https://'))
			return key;

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

	/**
	 * Scans an entire path and returns all assets found.
	 * @param key The path to scan.
	 * @param ext If specified, will only return files that ends with `ext`.
	 * @param recursive Recursively search through the game?
	 * @param returnType Which type of paths do u want returned? (with assets/key/file, key/file, or just file).
	 * @param returnExt Whether the extenstion of the file should be returned with it.
	 * @return Array full of assets found inside of `key`.
	 */
	public function scan(key:String, ?ext:String = '', ?recursive:Bool = true, ?returnType:ScanReturnType = ASSETS_PATH_FILE,
			?returnExt:Bool = true):Array<String>
	{
		var foundAssets:Array<String> = [];
		var openflList:Array<String> = Assets.list();

		if (!key.endsWith('/'))
			key += '/';

		if (ext != '' && !ext.startsWith('.'))
			ext = '.' + ext;

		for (asset in openflList)
		{
			var assetKey:String = 'assets/' + key;

			if ((!asset.startsWith(assetKey) || !asset.endsWith(ext)) || (!recursive && asset.split(assetKey)[1].contains('/')))
				continue;

			var assetToPush:String = switch (returnType)
			{
				case ASSETS_PATH_FILE:
					asset;

				case PATH_FILE:
					asset.split('assets/')[1];

				case FILE:
					var assetSplit:Array<String> = asset.split('/');
					assetSplit[assetSplit.length - 1];
			}

			if (!returnExt)
				assetToPush = assetToPush.split('.')[0];

			// Avoid duplicates especially if your removing all extentions.
			if (!foundAssets.contains(assetToPush))
				foundAssets.push(assetToPush);
		}

		return foundAssets;
	}
}

enum ScanReturnType
{
	ASSETS_PATH_FILE;
	PATH_FILE;
	FILE;
}
