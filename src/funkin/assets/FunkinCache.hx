package funkin.assets;

class FunkinCache
{
  // final permanent:Map<String, IFunkinAsset>;
  final current:Map<String, IFunkinAsset>;
  final previous:Map<String, IFunkinAsset>;

  public function new()
  {
    current = new Map<String, IFunkinAsset>();
    previous = new Map<String, IFunkinAsset>();
  }

  /**
   * Fetches an asset from the cache.
   * @param key The key of the asset.
   * @param namespace The namespace to use.
   * @param type The asset type to fetch.
   * @return The asset, if it exists.
   */
  public function get<T:IFunkinAsset>(key:String, namespace:String, type:Class<T>):Null<T>
  {
    return cast getAsset('$namespace:$key');
  }

  /**
   * Fetches an asset from the cache.
   * @param path The path of the asset.
   * @param type The asset type to fetch.
   * @return The asset, if it exists.
   */
  public function getFromPath<T:IFunkinAsset>(path:String, type:Class<T>):Null<T>
  {
    final namespace:Null<String> = Paths.tree.getNamespaceFromPath(path);
    if (namespace == null)
      return null;

    return cast getAsset('$namespace:$path');
  }

  /**
   * Registers an asset into the cache.
   * @param key The key of the asset.
   * @param namespace The namespace of the asset.
   * @param asset The asset to cache.
   */
  public function cache(key:String, namespace:String, asset:IFunkinAsset):Void
  {
    final cacheKey:String = '$namespace:$key';
    current.set(cacheKey, asset);
    previous.remove(cacheKey);
  }

  /**
   * Checks if an asset is contained in the cache.
   * @param key The key of the asset.
   * @param namespace The namespace of the asset.
   * @return If the asset exists, or not.
   */
  public function exists(key:String, namespace:String):Bool
  {
    final cacheKey:String = '$namespace:$key';
    return current.exists(cacheKey) || previous.exists(cacheKey);
  }

  /**
   * Checks if a path is contained in the cache.
   * @param path The path of the asset.
   * @return If the asset exists, or not.
   */
  public function existsPath(path:String):Bool
  {
    for (namespace in Paths.tree.getNamespaces())
    {
      final cacheKey:String = '$namespace:$path';
      if (current.exists(cacheKey) || previous.exists(cacheKey))
        return true;
    }

    return false;
  }

  function getAsset(key:String):Null<IFunkinAsset>
  {
    /*if (permanent.exists(key))
        return permanent.get(key);
      else */
    if (current.exists(key))
      return current.get(key);
    else if (previous.exists(key))
    {
      final asset:Null<IFunkinAsset> = previous.get(key);
      if (asset == null)
        throw 'how';

      current.set(key, asset);
      previous.remove(key);
      return asset;
    }

    return null;
  }

  /**
   * Prints info about the cache.
   */
  public function printInfo():Void
  {
    trace('------- Asset Cache Info! -------');

    final currentKeys:Array<String> = [for (i in current.keys()) i];
    trace('Current has ${currentKeys.length} keys:');
    for (i in currentKeys)
      trace('  $i');

    final previousKeys:Array<String> = [for (i in previous.keys()) i];
    trace('Previous has ${previousKeys.length} keys:');
    for (i in previousKeys)
      trace('  $i');

    trace('------- Asset Cache Info! -------');
  }
}
