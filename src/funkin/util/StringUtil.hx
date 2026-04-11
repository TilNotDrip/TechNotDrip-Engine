package funkin.util;

class StringUtil
{
  /**
   * Regular Expression for URL checking.
   * @see https://regexr.com/37i6s
   */
  public static final urlEx:EReg = new EReg("https?:\\/\\/?[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,4}\\b[-a-zA-Z0-9@:%_\\+.~#?&//=]*", "g");

  /**
   * A function for checking if a `String` is a URL.
   * @param allegedURL The `String` to check.
   * @return If `true`, the `String` is a URL.
   */
  public static function isURL(allegedURL:String):Bool
  {
    var match:Bool = urlEx.match(allegedURL);

    return match;
  }
}
