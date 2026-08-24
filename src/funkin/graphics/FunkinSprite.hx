package funkin.graphics;

import funkin.graphics.animation.FunkinAnimationController;
import funkin.graphics.animation.FunkinAtlasFrames;
import h2d.col.Matrix;
import hxd.res.Image;

@:access(h2d.col.Matrix)
@:access(h2d.Tile)
class FunkinSprite extends h2d.Drawable
{
  /**
   * The animation controller.
   */
  public var animation:FunkinAnimationController;

  /**
   * Collection of tiles to use for animations.
   */
  public var tiles:Array<FunkinTile> = [];

  /**
   * The current tile being displayed.
   */
  public var tile(get, set):FunkinTile;

  /**
   * The tile index of the current animation.
   * Can be changed manually.
   */
  public var tileIndex(default, set):Int = 0;

  public function new(?x:Float, ?y:Float)
  {
    super(null);

    animation = new FunkinAnimationController(this);
    this.x = x ?? 0;
    this.y = y ?? 0;
  }

  /**
   * Load a static image as the sprite's texture.
   * @param key The key of the texture to load.
   * @return This sprite, for chaining.
   */
  public function loadTexture(key:String):FunkinSprite
  {
    tile = Paths.image(key).tile();

    return this;
  }

  /**
   * Load an animated texture (Sparrow atlas spritesheet) as the sprite's texture.
   * @param key The key of the texture to load.
   * @return This sprite, for chaining.
   */
  public function loadSparrow(key:String):FunkinSprite
  {
    final tile:FunkinTile = Paths.image(key).tile();

    final xmlText:String = Paths.file('$key.xml').text();
    final xml:Xml = Xml.parse(xmlText);

    tiles = FunkinAtlasFrames.fromSparrow(tile, xml);
    return this;
  }

  /**
   * Load an animated texture (Packer atlas spritesheet) as the sprite's texture.
   * @param key The key of the texture to load.
   * @return This sprite, for chaining.
   */
  public function loadPacker(key:String):FunkinSprite
  {
    final tile:FunkinTile = Paths.image(key).tile();
    final text:String = Paths.file('$key.txt').text();

    tiles = FunkinAtlasFrames.fromPacker(tile, text);
    return this;
  }

  override function getBoundsRec(relativeTo:h2d.Object, out:h2d.col.Bounds, forSize:Bool):Void
  {
    super.getBoundsRec(relativeTo, out, forSize);
    if (tile == null)
      return;

    addBounds(relativeTo, out, tile.dx, tile.dy, tile.width * scaleX, tile.height * scaleY);
  }

  function set_tile(tile:FunkinTile):FunkinTile
  {
    if (this.tile == tile)
      return tile;

    if (!tiles.contains(tile))
    {
      this.tiles = [tile];
      this.tileIndex = 0;
    }

    return tile;
  }

  function get_tile():FunkinTile
  {
    return tiles[tileIndex];
  }

  function set_tileIndex(value:Int):Int
  {
    if (tileIndex != value)
    {
      tileIndex = value;
      onContentChanged();
    }

    return tileIndex;
  }

  override function sync(ctx:RenderContext):Void
  {
    animation.update(ctx.elapsedTime);
    super.sync(ctx);
  }

  override function draw(ctx:RenderContext):Void
  {
    this.emitTile(ctx, tile);
  }

  var _mat:Null<Matrix> = null;

  override function calcAbsPos():Void
  {
    if (_mat == null)
      _mat = new Matrix();
    _mat.identity();

    if (tile == null)
      return;

    final offsetX:Float = ((tile.width * scaleX) - tile.width) / 2;
    final offsetY:Float = ((tile.height * scaleY) - tile.height) / 2;

    final centerX:Float = tile.width / 2;
    final centerY:Float = tile.height / 2;

    _mat.translate(-centerX, -centerY);
    _mat.rotate(tile.rotation);

    if (tile.xFlip)
    {
      _mat.scale(-1, 1);
      _mat.translate(tile.width, 0);
    }

    if (tile.yFlip)
    {
      _mat.scale(1, -1);
      _mat.translate(0, tile.height);
    }

    _mat.scale(scaleX, scaleY);
    _mat.rotate(rotation);
    _mat.translate(x + offsetX, y + offsetY);

    _mat.translate(centerX, centerY);

    if (parent != null)
    {
      Matrix.tmp.a = parent.matA;
      Matrix.tmp.b = parent.matB;
      Matrix.tmp.c = parent.matC;
      Matrix.tmp.d = parent.matD;
      Matrix.tmp.x = parent.absX;
      Matrix.tmp.y = parent.absY;
      _mat.multiply(_mat, Matrix.tmp);
    }

    matA = _mat.a;
    matB = _mat.b;
    matC = _mat.c;
    matD = _mat.d;
    absX = _mat.x;
    absY = _mat.y;
  }
}
