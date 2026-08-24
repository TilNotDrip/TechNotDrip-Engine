package funkin.assets.asset;

class Text implements IFunkinAsset
{
  /**
   * The text asset.
   */
  public var data:Null<String> = null;

  /**
   * Loads the text into memory.
   * @param file The file to fetch text from.
   */
  public function load(file:FileEntry):Void
  {
    data = file.getText();
  }

  /**
   * Frees the asset from memory, synchronously.
   */
  public function dispose():Void
  {
    data = null;
  }

  /**
   * This function does nothing.
   */
  public function prePurge():Void {}
}
