package funkin.util.paths;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;

/**
 * A Paths class that helps returning objects or content based on stuff inside files.
 */
class PathsContent
{
	/**
	 * The main cache for this engine.
	 *
	 * Contains BitmapData, FlxGraphic, and Sound objects.
	 */
	public var cache:PathsCache = null;

	/**
	 * Initializes all variables for use with this class.
	 */
	public function new()
	{
		cache = new PathsCache();
	}

	/**
	 * Returns an Sound instance with `key`'s audio file information inside of it.
	 * @param key The audio key to use for returning information.
	 * @return Sound instance with the key's information inside of it.
	 */
	public function audio(key:String):Sound
	{
		var assetKey:String = Paths.location.audio(key);
		return cache.getAudio(assetKey);
	}

	/**
	 * Returns an BitmapData instance with `key`'s image file information inside of it.
	 * @param key The image key to use for returning information.
	 * @return BitmapData instance with the image's information inside of it.
	 */
	public function imageBitmap(key:String):BitmapData
	{
		var assetKey:String = Paths.location.image(key);
		return cache.getBitmapData(assetKey);
	}

	/**
	 * Returns an FlxGraphic instance with `key`'s image file information inside of it.
	 * @param key The image key to use for returning information.
	 * @return FlxGraphic instance with the image's information inside of it.
	 */
	public function imageGraphic(key:String):FlxGraphic
	{
		var assetKey:String = Paths.location.image(key);
		return cache.getFlxGraphic(assetKey);
	}

	/**
	 * Returns text from a json file.
	 * @param key The text key to use for returning the text inside.
	 * @return A string with text from a json file.
	 */
	public function json(key:String):String
	{
		var fileText:String = text(key + '.json');
		return fileText;
	}

	/**
	 * Returns an sparrow atlas information.
	 * @param key The image and xml key to use for returning information.
	 * @return Sparrow atlas into FlxFramesCollection with content inside of the image and xml.
	 */
	public function sparrowAtlas(key:String):FlxFramesCollection
	{
		return FlxAtlasFrames.fromSparrow(imageGraphic(key), xml(key));
	}

	/**
	 * Returns text from a file.
	 * @param key The text key to use for returning the text inside.
	 * @return A string with text from a file.
	 */
	public function text(key:String):String
	{
		var assetKey:String = Paths.location.get(key);
		return Assets.getText(assetKey);
	}

	/**
	 * Returns an xml object that is parsed from a file.
	 * @param key The xml key to use for returning the data inside.
	 * @return A Xml object parsed from text in a file.
	 */
	public function xml(key:String):Xml
	{
		var fileText:String = text(key + '.xml');
		return Xml.parse(fileText);
	}
}
