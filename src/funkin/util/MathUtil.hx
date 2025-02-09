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
	 * Centers B in A.
	 * @param A The thing that B will center in.
	 * @param B The thing that will be centered in A.
	 */
	public static function center(A:Float, B:Float)
	{
		return (A - B) / 2;
	}
}
