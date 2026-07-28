package funkin;

import funkin.resource.FunkinContent;
import funkin.resource.FunkinFileSystem;
import hxd.fs.EmbedFileSystem;

/**
 * This is a paths class mostly used for getting content from files.
 *
 * `content` = Returning content / Content cache.
 * `location` = Getting path locations.
 */
class Paths
{
  /**
   * The extension used for audio files.
   */
  public static inline final AUDIO_EXT:String = 'ogg';

  /**
   * The extenstion used for image files.
   */
  public static inline final IMAGE_EXT:String = 'png';

  /**
   * The helper for returning content and objects from files.
   */
  public static final content:FunkinContent = new FunkinContent();

  /**
   * The current file system.
   */
  public static final fileSystem:FunkinFileSystem = new FunkinFileSystem();

  /**
   * The embedded assets file system.
   */
  public static final embedFileSystem:FunkinFileSystem = new FunkinFileSystem();

  /**
   * (Re)initializes the File System.
   */
  public static function init():Void
  {
    // TODO: This is very temporary, and looks very awful!
    fileSystem.child = new hxd.fs.LocalFileSystem('../../../assets', null);

    embedFileSystem.child = EmbedFileSystem.create('../../../assets/embed');
  }
}
