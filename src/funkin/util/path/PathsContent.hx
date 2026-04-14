package funkin.util.path;

import animate.FlxAnimateFrames;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;

/**
 * A Paths class that helps returning objects or content based on stuff inside files.
 */
@:access(animate.FlxAnimateFrames)
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
   * Returns animate atlas information.
   * @param key The folder key to use for the information.
   * @return Animate Frames with information about the atlas.
   */
  public function animateAtlas(key:String, settings:FlxAnimateSettings):Null<FlxAnimateFrames>
  {
    var path:String = Path.removeTrailingSlashes(key);

    var hasAnimation:Bool = Paths.location.exists('${path}/Animation.json');
    if (!hasAnimation)
    {
      trace('[ERROR] No Animation.json file found for ${key}!');
      return null;
    }

    var animation:String = text('${path}/Animation.json');
    var spritemaps:Array<SpritemapInput> = [];

    var isInlined:Bool = !Paths.location.exists('${path}/metadata.json');
    var metadata:Null<String> = null;

    var libraryList:Null<Array<String>> = null;

    if (!isInlined)
    {
      metadata = text('${path}/metadata.json');
      libraryList = Paths.location.scan('${path}/LIBRARY', '.json', true, FILE, false);
    }

    for (spritemap in Paths.location.scan(path, '.json', true, FILE, false))
    {
      if (!spritemap.startsWith('spritemap'))
        continue;

      spritemaps.push({
        source: imageGraphic('${path}/${spritemap}'),
        json: text('${path}/${spritemap}.json')
      });
    }

    if (spritemaps.length < 1)
    {
      trace('[ERROR] No spritemaps found for ${key}!');
      return null;
    }

    var frames:FlxAnimateFrames = FlxAnimateFrames._fromAnimateInput(animation, spritemaps, metadata, path, isInlined, libraryList, settings);
    FlxAnimateFrames._cachedAtlases.remove(path);
    return frames;
  }

  /**
   * Returns text from a file.
   * @param key The text key to use for returning the text inside.
   * @return A string with text from a file.
   */
  public function text(key:String):String
  {
    var assetKey:String = Paths.location.get(key);
    return rawText(assetKey);
  }

  /**
   * Returns text from a file.
   * @param path The path to use for returning the text inside.
   * @return A string with text from a file.
   */
  public function rawText(path:String):String
  {
    var text:String = FlxG.assets.getText(path, false);
    text = text.replace(String.fromCharCode(0xFEFF), "");
    return text;
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
