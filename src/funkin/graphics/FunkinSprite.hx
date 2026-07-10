package funkin.graphics;

import funkin.graphics.animation.FunkinAnimationController;
import funkin.graphics.animation.FunkinAtlasFrames;
import h2d.Tile;
import h2d.col.Matrix;

@:access(h2d.col.Matrix)
@:access(h2d.Tile)
class FunkinSprite extends h2d.Drawable
{
  /**
   * Collection of tiles to use for animations.
   */
  public var tiles:Array<FunkinTile> = [];

  /**
   * The animation controller.
   */
  public var animation:FunkinAnimationController;

  /**
   * The current tile being displayed.
   */
  public var tile(get, set):FunkinTile;

  /**
   * The tile index of the current animation.
   * Can be changed manually.
   */
  public var tileIndex(default, set):Int = 0;

  #if SHOW_BOUNDS
  var debugGfx:h2d.Graphics;
  #end

  public function new(?x:Float, ?y:Float)
  {
    super(null);

    animation = new FunkinAnimationController(this);
    this.x = x ?? 0;
    this.y = y ?? 0;

    #if SHOW_BOUNDS
    debugGfx = new h2d.Graphics();
    #end
  }

  /**
   * Load a static image as the sprite's texture.
   * @param key The key of the texture to load.
   * @return This sprite, for chaining.
   */
  public function loadTexture(key:String):FunkinSprite
  {
    final image:Image = Paths.content.image(key);
    tile = cast image.toTile();

    return this;
  }

  /**
   * Load an animated texture (Sparrow atlas spritesheet) as the sprite's texture.
   * @param key The key of the texture to load.
   * @return This sprite, for chaining.
   */
  public function loadSparrow(key:String):FunkinSprite
  {
    final image:Image = Paths.content.image(key);

    final xmlText:String = Paths.content.text('$key.xml');
    final xml:Xml = Xml.parse(xmlText);

    tiles = FunkinAtlasFrames.fromSparrow(image, xml);
    return this;
  }

  /**
   * Load an animated texture (Packer atlas spritesheet) as the sprite's texture.
   * @param key The key of the texture to load.
   * @return This sprite, for chaining.
   */
  public function loadPacker(key:String):FunkinSprite
  {
    final image:Image = Paths.content.image(key);
    final text:String = Paths.content.text('$key.txt');

    final tiles:Array<FunkinTile> = FunkinAtlasFrames.fromPacker(image, text);
    tile = tiles[0];

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
    #if SHOW_BOUNDS
    debugGfx.clear();
    debugGfx.lineStyle(1, 0xFFFF0000);
    debugGfx.moveTo(tile.dx, tile.dy);
    debugGfx.lineTo(tile.dx + tile.width, tile.dy);
    debugGfx.lineTo(tile.dx + tile.width, tile.dy + tile.height);
    debugGfx.lineTo(tile.dx, tile.dy + tile.height);
    debugGfx.lineTo(tile.dx, tile.dy);
    debugGfx.endFill();
    #end

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
    #if SHOW_BOUNDS debugGfx.sync(ctx); #end
    super.sync(ctx);
  }

  override function draw(ctx:RenderContext):Void
  {
    this.emitTile(ctx, tile);
  }

  override function calcAbsPos():Void
  {
    // We don't really calculate the position here anymore.
  }

  var _mat:Null<Matrix> = null;

  override function emitTile(ctx:RenderContext, tile:Tile):Void
  {
    final tile:FunkinTile = cast tile;

    if (_mat == null)
      _mat = new Matrix();
    _mat.identity();

    final offsetX:Float = ((tile.width * scaleX) - tile.width) / 2;
    final offsetY:Float = ((tile.height * scaleY) - tile.height) / 2;

    final centerX:Float = tile.width / 2;
    final centerY:Float = tile.height / 2;

    _mat.translate(-centerX, -centerY);
    // _mat.translate(tile.dx, tile.dy);
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
    super.emitTile(ctx, tile);

    #if SHOW_BOUNDS
    debugGfx.matA = matA;
    debugGfx.matB = matB;
    debugGfx.matC = matC;
    debugGfx.matD = matD;
    debugGfx.absX = absX;
    debugGfx.absY = absY;
    debugGfx.draw(ctx);
    #end
  }
}
