package funkin.util;

class StringUtil
{
  /**
   * A list of memory units that should be used when formatting bytes.
   */
  public static final MEMORY_UNITS:Array<String> = ['B', 'kB', 'MB', 'GB', 'TB', 'PB'];

  /**
   * Formats a total amount of bytes to a fancy memory unit.
   * @param bytes The bytes.
   * @return The formatted string.
   */
  public static function formatBytes(bytes:Float):String
  {
    var curUnit:Int = 0;

    while (bytes >= 1024 && curUnit < MEMORY_UNITS.length - 1)
    {
      bytes /= 1024;
      curUnit++;
    }

    return bytes.round(2) + MEMORY_UNITS[curUnit];
  }
}
