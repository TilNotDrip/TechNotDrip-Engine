package funkin.util.tools;

import h2d.col.Matrix;

class MatrixTools
{
  /**
   * Applies rotation transform to `matrix` by given `angle`.
   * @param matrix The matrix to transform.
   * @param	angle The rotation angle.
   * @return The transformed `matrix`.
   */
  public static function rotate(matrix:Matrix, angle:Float):Matrix
  {
    final sin:Float = Math.sin(angle);
    final cos:Float = Math.cos(angle);

    var a1:Float = matrix.a * cos - matrix.b * sin;
    matrix.b = matrix.a * sin + matrix.b * cos;
    matrix.a = a1;

    var c1:Float = matrix.c * cos - matrix.d * sin;
    matrix.d = matrix.c * sin + matrix.d * cos;
    matrix.c = c1;

    var x1:Float = matrix.x * cos - matrix.y * sin;
    matrix.y = matrix.x * sin + matrix.y * cos;
    matrix.x = x1;

    return matrix;
  }
}
