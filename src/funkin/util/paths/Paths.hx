package funkin.util.paths;

/**
 * I wanted to name this FunkinPath but that would mess up my muscle memory.
 */
class Paths
{
	/**
	 * The extension used for audio files.
	 *
	 * @default ogg (mp3 For web)
	 */
	public static inline final AUDIO_EXT:String = #if web 'mp3' #else 'ogg' #end;

	/**
	 * The extenstion used for image files.
	 *
	 * @default png
	 */
	public static inline final IMAGE_EXT:String = 'png';

	/**
	 * The extension used for scripting files.
	 *
	 * We don't have scripting support yet nor an idea on what haxelib we use for it.
	 *
	 * @default hx
	 */
	public static inline final SCRIPT_EXT:String = 'hx';

	/**
	 * The helper for returning content and objects from files.
	 */
	public static var content:PathsContent = new PathsContent();

	/**
	 * The helper for returning strings of locations.
	 */
	public static var location:PathsLocation = new PathsLocation();
}
