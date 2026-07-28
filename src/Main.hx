package;

import funkin.Paths;
import funkin.graphics.FunkinImage;
import funkin.ui.overlay.FunkinOverlay;
import h3d.Engine;
import hxd.App;
import hxd.Window;

class Main extends App
{
  public static function main():Void
  {
    new Main();
  }

  /**
   * The overlay on top of everything.
   */
  public var overlay:Null<FunkinOverlay> = null;

  public function new()
  {
    super();
  }

  override function loadAssets(onLoaded:() -> Void):Void
  {
    funkin.Paths.init();
    onLoaded();
  }

  override function init():Void
  {
    setScene(new funkin.ui.title.TitleScene());
    overlay = new FunkinOverlay();

    Window.getInstance().setIcon(new FunkinImage(Paths.embedFileSystem.get('icons/iconOG.png')).toBitmap());
  }

  override function update(dt:Float)
  {
    overlay.setElapsedTime(dt);
    super.update(dt);
  }

  override function render(e:Engine)
  {
    super.render(e);

    if (overlay != null)
      overlay.render(e);
  }
}
