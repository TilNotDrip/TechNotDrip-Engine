package funkin.graphics;

import h2d.Tile;
import h3d.mat.Texture;

class FunkinTile extends Tile
{
  /**
   * The name of this tile, useful if this originated from a texture atlas.
   */
  public var name:String;

  /**
    The rotation angle of this tile, in radians.
  **/
  public var rotation:Float;

  public function new(tex:h3d.mat.Texture, x:Float, y:Float, w:Float, h:Float, dx:Float = 0, dy:Float = 0)
  {
    super(tex, x, y, w, h, dx, dy);
    this.rotation = 0;
    this.name = '';
  }

  override function setTexture(tex:Texture):Void
  {
    // need to figure out how to get the width and height working for any angle.
    super.setTexture(tex);
  }

  override public function sub(x:Float, y:Float, w:Float, h:Float, dx = 0., dy = 0.):Tile
  {
    return new FunkinTile(innerTex, this.x + x, this.y + y, w, h, dx, dy);
  }

  /**
   * Create new Tile from provided Texture instance.
   */
  public static function fromTexture(t:h3d.mat.Texture):FunkinTile
  {
    return new FunkinTile(t, 0, 0, t.width, t.height);
  }
}
