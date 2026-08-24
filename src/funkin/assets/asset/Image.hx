package funkin.assets.asset;

import h3d.mat.Texture;
import hxd.Pixels;
import hxd.res.Image as HeapsImage;

@:access(h3d.mat.Texture)
class Image implements IFunkinAsset
{
  var _texture:Null<Texture> = null;
  var _tile:Null<FunkinTile> = null;

  /**
   * Fetches the texture for this image.
   * @return The texture, if possible.
   */
  public function texture():Null<Texture>
  {
    return _texture;
  }

  /**
   * Fetches a tile for this image.
   * @return The tile, if possible.
   */
  public function tile():Null<FunkinTile>
  {
    if (_texture != null && _tile == null)
      _tile = FunkinTile.fromTexture(_texture);

    return _tile;
  }

  /**
   * Loads the image into memory, synchronously.
   * @param file The image file to use for loading.
   */
  public function load(file:FileEntry):Void
  {
    // TODO: Do decoding ourselves.
    // `SDL_image` implementation for HashLink,
    // `js.html.Image` directly for JavaScript.
    final pixels:Pixels = new HeapsImage(file).getPixels();
    _texture = Texture.fromPixels(pixels, #if js Texture.nativeFormat #else pixels.format #end);
    pixels.dispose();

    // We handle disposing ourselves, so disable Auto Dispose.
    _texture.lastFrame = Texture.PREVENT_AUTO_DISPOSE;
  }

  /**
   * Frees the image from memory, synchronously.
   */
  public function dispose():Void
  {
    if (_tile != null)
      _tile.dispose();
    else if (_texture != null)
      _texture.dispose();

    _texture = null;
    _tile = null;
  }

  /**
   * Ready the image for cache purge.
   */
  public function prePurge():Void
  {
    // Before we purge, enable auto-dispose in case we need more memory.
    @:bypassAccessor _texture.lastFrame = -1;
  }
}
