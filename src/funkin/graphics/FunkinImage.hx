package funkin.graphics;

import h2d.Tile;

class FunkinImage extends Image
{
  override function toTile():Tile
  {
    getInfo();
    return FunkinTile.fromTexture(toTexture()).sub(0, 0, inf.width, inf.height);
  }
}
