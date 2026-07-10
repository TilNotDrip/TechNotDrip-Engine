package funkin.resource;

import haxe.io.Path as PathTools;

class FunkinContent
{
  public function new() {}

  /**
   * Returns an Sound instance with `key`'s audio file information inside of it.
   * @param key The audio key to use for returning information.
   * @return Sound instance with the key's information inside of it.
   */
  public function audio(key:String):Sound
  {
    final path:String = PathTools.withExtension(key, Paths.AUDIO_EXT);
    final entry:FileEntry = Paths.fileSystem.get(path);

    // TODO: Cache this instead of creating a new one every time.
    return new Sound(entry);
  }

  /**
   * Returns an Image instance with `key`'s image file information inside of it.
   * @param key The image key to use for returning information.
   * @return BitmapData instance with the image's information inside of it.
   */
  public function image(key:String):Image
  {
    final path:String = PathTools.withExtension(key, Paths.IMAGE_EXT);
    final entry:FileEntry = Paths.fileSystem.get(path);

    // TODO: Cache this instead of creating a new one every time.
    return new funkin.graphics.FunkinImage(entry);
  }

  /**
   * Returns text from a file.
   * @param key The text key to use for returning the text inside.
   * @return A string with text from a file.
   */
  public function text(key:String):String
  {
    final entry:FileEntry = Paths.fileSystem.get(key);

    // Hey Crusher, should I cache texts? -Til
    return entry.getText();
  }
}
