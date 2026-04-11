package funkin.util;

class MathUtil
{
  public static function camLerpShit(lerp:Float):Float
  {
    return lerp * (FlxG.elapsed / (1 / 60));
  }

  public static function coolLerp(a:Float, b:Float, ratio:Float):Float
  {
    return FlxMath.lerp(a, b, camLerpShit(ratio));
  }

  /**
   * Centers `b` in `a`.
   * @param a The thing that `b` will center in.
   * @param b The thing that will be centered in `a`.
   */
  public static function center(a:Float, b:Float)
  {
    return (a - b) / 2;
  }
}
