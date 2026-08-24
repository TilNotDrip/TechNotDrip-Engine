package funkin.assets;

class Paths
{
  /**
   * The asset cache.
   */
  public static final cache:FunkinCache = new FunkinCache();

  /**
   * The asset tree.
   */
  public static final tree:AssetTree = new AssetTree();

  /**
   * Constructs a resource.
   * @param key The key for the resource.
   * @param namespace The optional namespace for the resource.
   * @param validate If the resource should be validated or not.
   * @return The resource
   */
  public static function build(key:String, ?namespace:String, ?validate:Bool = true):Resource
  {
    final resource:Resource = new Resource(key, namespace);

    if (validate && !resource.exists())
      trace('[WARNING] $resource does not exist!');

    return resource;
  }

  public static function file(key:String, ?namespace:String, ?validate:Bool = true):Resource
  {
    return build(key, namespace, validate);
  }

  public static function image(key:String, ?namespace:String, ?validate:Bool = true):Resource
  {
    return build('$key.png', namespace, validate);
  }

  public static function sound(key:String, ?namespace:String, ?validate:Bool = true):Resource
  {
    return build('$key.ogg', namespace, validate);
  }
}
