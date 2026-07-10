package funkin.util;

class MathUtil
{
  /**
   * Linear interpolation.
   *
   * @param base The starting value, when `alpha = 0`.
   * @param target The ending value, when `alpha = 1`.
   * @param alpha The percentage of the interpolation from `base` to `target`. Forms a "line" intersecting the two.
   *
   * @return The interpolated value.
   */
  public static function lerp(base:Float, target:Float, alpha:Float):Float
  {
    if (alpha == 0)
      return base;
    if (alpha == 1)
      return target;
    return base + alpha * (target - base);
  }

  /**
   * Exponential decay interpolation.
   *
   * Framerate-independent because the rate-of-change is proportional to the difference, so you can
   * use the time elapsed since the last frame as `deltaTime` and the function will be consistent.
   *
   * Equivalent to `smoothLerpPrecision(base, target, deltaTime, halfLife, 0.5)`.
   *
   * @param base The starting or current value.
   * @param target The value this function approaches.
   * @param deltaTime The change in time along the function in seconds.
   * @param halfLife Time in seconds to reach halfway to `target`.
   *
   * @see https://twitter.com/FreyaHolmer/status/1757918211679650262
   *
   * @return The interpolated value.
   */
  public static function smoothLerpDecay(base:Float, target:Float, deltaTime:Float, halfLife:Float):Float
  {
    if (deltaTime == 0)
      return base;
    if (base == target)
      return target;
    return lerp(target, base, exp2(-deltaTime / halfLife));
  }

  /**
   * Exponential decay interpolation.
   *
   * Framerate-independent because the rate-of-change is proportional to the difference, so you can
   * use the time elapsed since the last frame as `deltaTime` and the function will be consistent.
   *
   * Equivalent to `smoothLerpDecay(base, target, deltaTime, -duration / logBase(2, precision))`.
   *
   * @param base The starting or current value.
   * @param target The value this function approaches.
   * @param deltaTime The change in time along the function in seconds.
   * @param duration Time in seconds to reach `target` within `precision`, relative to the original distance.
   * @param precision Relative target precision of the interpolation. Defaults to 1% distance remaining.
   *
   * @see https://twitter.com/FreyaHolmer/status/1757918211679650262
   *
   * @return The interpolated value.
   */
  public static function smoothLerpPrecision(base:Float, target:Float, deltaTime:Float, duration:Float, precision:Float = 1 / 100):Float
  {
    if (deltaTime == 0)
      return base;
    if (base == target)
      return target;
    return lerp(target, base, Math.pow(precision, deltaTime / duration));
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

  /**
   * Get the base-2 exponent of a value.
   * @param x value
   * @return `2^x`
   */
  public static function exp2(x:Float):Float
  {
    return Math.pow(2, x);
  }
}
