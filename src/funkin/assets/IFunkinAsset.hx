package funkin.assets;

interface IFunkinAsset
{
  /**
   * Loads the asset into memory, synchronously.
   * @param file The file to use for loading.
   */
  public function load(file:FileEntry):Void;

  /**
   * Frees the asset from memory, synchronously.
   */
  public function dispose():Void;

  /**
   * Loads the asset into memory, asynchronously.
   * @return A `Promise` that it loads successfully.
   */
  // public function loadAsync(file:FileEntry):Void;

  /**
   * Ready the asset for cache purge.
   */
  public function prePurge():Void;
}
