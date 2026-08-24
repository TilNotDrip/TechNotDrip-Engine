package funkin.assets;

import funkin.assets.asset.Image;
import funkin.assets.asset.Text;

class Resource
{
  /**
   * The key of this resource.
   */
  public final key:String;

  /**
   * The namespace of this resource.
   */
  public final namespace:Null<String>;

  public function new(key:String, ?namespace:String)
  {
    this.key = key;
    this.namespace = namespace;
  }

  /**
   * Fetches an image.
   * @return The image.
   */
  public function image():Image
  {
    return fetch(Image);
  }

  /**
   * Fetches a tile.
   * @return The tile.
   */
  public function tile():FunkinTile
  {
    return image().tile();
  }

  /**
   * Fetches a sound.
   * @return The sound.
   */
  public function sound():funkin.assets.asset.Sound
  {
    return fetch(funkin.assets.asset.Sound);
  }

  /**
   * Fetches text.
   * @return The text.
   */
  public function text():String
  {
    return fetch(Text).data ?? '';
  }

  /**
   * Checks if the resource exists.
   * @return If it exists, or not.
   */
  public function exists():Bool
  {
    return
    {
      if (namespace != null)
        Paths.tree.existsInNamespace(key, namespace);
      else
        Paths.tree.exists(key);
    };
  }

  function fetch<T:IFunkinAsset>(type:Class<T>):T
  {
    var asset:Null<T> =
      {
        if (namespace != null)
          Paths.cache.get(key, namespace, type);
        else
          Paths.cache.getFromPath(key, type);
      };

    if (asset == null)
    {
      var file:FileEntry =
        {
          if (namespace != null)
            Paths.tree.getFromNamespace(key, namespace);
          else
            Paths.tree.get(key);
        };

      asset = Type.createInstance(type, []);
      asset.load(file);

      Paths.cache.cache(key, namespace ?? Paths.tree.getNamespaceFromPath(key) ?? '', asset);
      Paths.cache.printInfo();

      trace('[WARNING] Loaded ${this} without caching!');
    }

    return asset;
  }

  public function toString():String
  {
    return
    {
      if (namespace != null)
        '$namespace:$key';
      else
      {
        var autoNamespace:Null<String> = Paths.tree.getNamespaceFromPath(key) ?? '';
        '$autoNamespace:$key';
      }
    }
  }
}
