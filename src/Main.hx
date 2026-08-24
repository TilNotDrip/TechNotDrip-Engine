package;

import funkin.ui.overlay.FunkinOverlay;
import funkin.util.Signal;
import h3d.Engine;
import hxd.App;
import hxd.Window;

class Main extends App
{
  public static var instance:Main = null;

  public static function main():Void
  {
    instance = new Main();
  }

  /**
   * The overlay on top of everything.
   */
  public var overlay:Null<FunkinOverlay> = null;

  public var preUpdate(default, null):Signal<(dt:Float) -> Void> = new Signal<(dt:Float) -> Void>();

  public var postUpdate(default, null):Signal<(dt:Float) -> Void> = new Signal<(dt:Float) -> Void>();

  public function new()
  {
    super();
  }

  override function loadAssets(onLoaded:() -> Void):Void
  {
    // TODO: This is very temporary, and looks very awful!
    #if hl
    funkin.assets.Paths.tree.add('funkin', new hxd.fs.LocalFileSystem('../../../assets', null));
    #else
    funkin.assets.Paths.tree.add('funkin', hxd.fs.EmbedFileSystem.create('assets', null));
    #end

    onLoaded();
  }

  override function init():Void
  {
    setScene(new funkin.ui.title.TitleScene());
    overlay = new FunkinOverlay();
  }

  override function update(dt:Float):Void
  {
    preUpdate.dispatch(dt);

    overlay.setElapsedTime(dt);
    super.update(dt);

    postUpdate.dispatch(dt);
  }

  override function render(e:Engine)
  {
    super.render(e);

    if (overlay != null)
      overlay.render(e);
  }
}
