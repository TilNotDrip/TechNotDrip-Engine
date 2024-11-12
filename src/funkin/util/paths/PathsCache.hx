package funkin.util.paths;

import flixel.graphics.FlxGraphic;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;

/**
 * A caching system for PathsContent.
 *
 * This caches content like audios and images for faster returning rather than taking a long time each time.
 */
class PathsCache
{
	/**
	 * The content that doesn't get wiped from a cache clean.
	 *
	 * You should only put something here if you use it on a daily basis.
	 */
	final removeExcludeKeys:Array<String> = [
		'assets/ui/fonts/alphabet/bold.' + Paths.IMAGE_EXT,
		'assets/ui/fonts/alphabet/default.' + Paths.IMAGE_EXT,
		'assets/ui/menu/freakyMenu.' + Paths.AUDIO_EXT
	];

	var cachedAudioKeys:Array<String>;
	var cachedImageKeys:Array<String>;

	var cachedAudio:Map<String, Sound>;
	var cachedBitmapData:Map<String, BitmapData>;
	var cachedFlxGraphic:Map<String, FlxGraphic>;

	/**
	 * Initializes all variables for use with this class.
	 */
	public function new()
	{
		cachedAudioKeys = [];
		cachedImageKeys = [];

		cachedAudio = new Map<String, Sound>();
		cachedBitmapData = new Map<String, BitmapData>();
		cachedFlxGraphic = new Map<String, FlxGraphic>();
	}

	/**
	 * Caches and returns an Sound instance.
	 * @param key Audio key to cache and return.
	 * @return Sound Instance from cache.
	 */
	public function getAudio(key:String):Sound
	{
		if (cachedAudio.get(key) == null)
		{
			var audio:Sound = null;

			try
			{
				audio = Assets.getSound(key, false);
			}
			catch (e:Exception)
			{
				trace('[WARNING]: Audio could not be loaded! ($key) More details: ${e.message}');
				return null;
			}

			cachedAudio.set(key, audio);

			if (!cachedAudioKeys.contains(key))
				cachedAudioKeys.push(key);
		}

		return cachedAudio.get(key);
	}

	// TODO: Maybe add gpu caching to images when we get options?

	/**
	 * Caches and returns an BitmapData instance.
	 * @param key Image key to cache and return.
	 * @return BitmapData Instance from cache.
	 */
	public function getBitmapData(key:String):BitmapData
	{
		if (cachedBitmapData.get(key) == null)
		{
			var bitmapData:BitmapData = null;

			try
			{
				bitmapData = Assets.getBitmapData(key, false);
			}
			catch (e:Exception)
			{
				trace('[WARNING]: Image could not be loaded! ($key) More details: ${e.message}');
				return null;
			}

			cachedBitmapData.set(key, bitmapData);

			if (!cachedImageKeys.contains(key))
				cachedImageKeys.push(key);
		}

		return cachedBitmapData.get(key);
	}

	/**
	 * Caches and returns an FlxGraphic instance.
	 * @param key Image key to cache and return.
	 * @return FlxGraphic Instance from cache.
	 */
	public function getFlxGraphic(key:String):FlxGraphic
	{
		if (cachedFlxGraphic.get(key) == null)
		{
			var flxGraphic:FlxGraphic = null;
			var bitmapData:BitmapData = null;

			try
			{
				bitmapData = getBitmapData(key);
			}
			catch (e:Exception)
			{
				return null;
			}

			flxGraphic = FlxGraphic.fromBitmapData(bitmapData, false, key, false);
			flxGraphic.persist = true;
			flxGraphic.destroyOnNoUse = false;

			cachedFlxGraphic.set(key, flxGraphic);

			if (!cachedImageKeys.contains(key))
				cachedImageKeys.push(key);
		}

		return cachedFlxGraphic.get(key);
	}

	/**
	 * Clears out the cached objects inside of this instance.
	 * @param runGarbageCollecter Whether to run the garbage collector after clearing all objects.
	 * @param bypassExcludeKeys Whether to remove the objects even if it's inside of the exclude list.
	 */
	public function clear(?runGarbageCollecter:Bool = true, ?bypassExcludeKeys:Bool = false):Void
	{
		clearImages(false, bypassExcludeKeys);
		clearAudios(false, bypassExcludeKeys);

		if (runGarbageCollecter)
			System.gc();
	}

	/**
	 * Clears out the cached audios inside of this instance.
	 * @param runGarbageCollecter Whether to run the garbage collector after clearing all audios.
	 * @param bypassExcludeKeys Whether to remove the audios even if it's inside of the exclude list.
	 */
	public function clearAudios(?runGarbageCollecter:Bool = true, ?bypassExcludeKeys:Bool = false):Void
	{
		for (audio in cachedAudioKeys)
		{
			removeAudio(audio, bypassExcludeKeys);
		}

		if (runGarbageCollecter)
			System.gc();
	}

	/**
	 * Clears out the cached images inside of this instance.
	 * @param runGarbageCollecter Whether to run the garbage collector after clearing all images.
	 * @param bypassExcludeKeys Whether to remove the images even if it's inside of the exclude list.
	 */
	public function clearImages(?runGarbageCollecter:Bool = true, ?bypassExcludeKeys:Bool = false):Void
	{
		for (image in cachedImageKeys)
		{
			removeImage(image, bypassExcludeKeys);
		}

		FlxG.bitmap.reset(); // Flixel likes to cache all texts and transitions, nothing wrong with it but this is a graphic clear.

		if (runGarbageCollecter)
			System.gc();
	}

	/**
	 * Removes and destroys an audio inside the audio cache.
	 * @param key The audio key you want to remove.
	 * @param bypassExcludeKeys Whether to remove the audio even if it's inside of the exclude list.
	 * @return Whether an object was successfully removed or not.
	 */
	public function removeAudio(key:String, ?bypassExcludeKeys:Bool = false):Bool
	{
		if (removeExcludeKeys.contains(key) && !bypassExcludeKeys)
			return false;

		var wasRemoved:Bool = false;

		if (cachedAudio.get(key) != null)
		{
			cachedAudio.remove(key);

			wasRemoved = true;
		}

		cachedAudioKeys.remove(key);

		return wasRemoved;
	}

	/**
	 * Removes and destroys an image inside the audio cache.
	 * @param key The image key you want to remove.
	 * @param bypassExcludeKeys Whether to remove the image even if it's inside of the exclude list.
	 * @return Whether an object was successfully removed or not.
	 */
	public function removeImage(key:String, ?bypassExcludeKeys:Bool = false):Bool
	{
		if (removeExcludeKeys.contains(key) && !bypassExcludeKeys)
			return false;

		var wasRemoved:Bool = false;

		if (cachedBitmapData.get(key) != null)
		{
			var bitmapData:BitmapData = cachedBitmapData.get(key);
			bitmapData.dispose();
			cachedBitmapData.remove(key);

			wasRemoved = true;
		}

		if (cachedFlxGraphic.get(key) != null)
		{
			var flxGraphic:FlxGraphic = cachedFlxGraphic.get(key);
			flxGraphic.persist = false;
			flxGraphic.destroyOnNoUse = true;
			cachedFlxGraphic.remove(key);

			if (FlxG.bitmap.checkCache(key))
				FlxG.bitmap.remove(flxGraphic);

			if (flxGraphic != null)
				flxGraphic.destroy();

			wasRemoved = true;
		}

		cachedImageKeys.remove(key);

		return wasRemoved;
	}
}
