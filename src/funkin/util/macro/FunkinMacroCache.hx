package funkin.util.macro;

#if macro
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

/**
 * Pretty much a save file for macros.
 * Lets you keep values for later compiles.
 */
class FunkinMacroCache
{
  /**
   * The macro cache.
   * You can save things here for later compiles.
   */
  public static var cache(get, set):StringMap<Dynamic>;

  static var _cache:Null<StringMap<Dynamic>>;

  static function get_cache():StringMap<Dynamic>
  {
    if (_cache == null)
      load();

    return _cache;
  }

  static function set_cache(value:StringMap<Dynamic>):StringMap<Dynamic>
  {
    _cache = value;
    return _cache;
  }

  /**
   * Loads the cache from the repository.
   */
  public static function load():Void
  {
    if (!FileSystem.exists('.macrocache'))
    {
      _cache = new StringMap<Dynamic>();
      return;
    }

    var unserializer:Unserializer = new Unserializer(File.getContent('.macrocache'));
    _cache = unserializer.unserialize();

    Context.onAfterGenerate(flush);
  }

  /**
   * Flushes the cache into the repository.
   */
  public static function flush():Void
  {
    var serializer:Serializer = new Serializer();
    serializer.serialize(_cache);

    File.saveContent('.macrocache', serializer.toString());
  }
}
#end
