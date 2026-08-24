package funkin.graphics.animation;

import haxe.xml.Access;
import hxd.res.Image;

class FunkinAtlasFrames
{
  public static function fromSparrow(tile:FunkinTile, xml:Xml):Array<FunkinTile>
  {
    final frames:Array<FunkinTile> = [];

    var data:Access = new Access(xml.firstElement());
    for (texture in data.nodes.SubTexture)
    {
      if (!texture.has.width && texture.has.w)
        throw "This parser does not support Sparrow v1. Use Sparrow v2 instead.";

      final name:String = texture.att.name;
      final trimmed:Bool = texture.has.frameX;
      final rotated:Bool = texture.has.rotated && texture.att.rotated == "true";
      final flipX:Bool = texture.has.flipX && texture.att.flipX == "true";
      final flipY:Bool = texture.has.flipY && texture.att.flipY == "true";

      final x:Float = Std.parseFloat(texture.att.x);
      final y:Float = Std.parseFloat(texture.att.y);
      final width:Float = Std.parseFloat(texture.att.width);
      final height:Float = Std.parseFloat(texture.att.height);

      final offsetX:Float = trimmed ? Std.parseFloat(texture.att.frameX) : 0;
      final offsetY:Float = trimmed ? Std.parseFloat(texture.att.frameY) : 0;

      var tile:FunkinTile = cast tile.sub(x, y, width, height, -offsetX, -offsetY);
      tile.rotation = hxd.Math.degToRad(rotated ? 270 : 0);
      tile.xFlip = flipX;
      tile.yFlip = flipY;
      tile.name = name;
      frames.push(tile);
    }

    return frames;
  }

  public static function fromPacker(tile:FunkinTile, data:String):Array<FunkinTile>
  {
    final frames:Array<FunkinTile> = [];

    for (anim in data.trim().split('\n'))
    {
      final name:String = anim.substring(0, anim.indexOf('=')).trim();
      final frameData:Array<Float> = anim.substring(anim.indexOf('=') + 1).split(',').map(v -> Std.parseFloat(v.trim()));

      final tile:FunkinTile = cast tile.sub(frameData[0], frameData[1], frameData[2], frameData[3]);
      tile.name = name;
      frames.push(tile);
    }

    return frames;
  }
}
