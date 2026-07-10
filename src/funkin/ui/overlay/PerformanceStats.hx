package funkin.ui.overlay;

import h2d.Text;
import h3d.Engine;
import hxd.Timer;

class PerformanceStats extends Text
{
  /**
   * How long we should wait until we update the stats.
   */
  public static final UPDATE_INTERVAL:Float = 0.1;

  var updateTimer:Float;

  public function new()
  {
    super(hxd.res.DefaultFont.get());
    setPosition(5, 5);

    updateTimer = UPDATE_INTERVAL;
  }

  override function sync(ctx:RenderContext)
  {
    updateTimer -= ctx.elapsedTime;

    if (updateTimer > 0)
    {
      super.sync(ctx);
      return;
    }

    var fpsText:String = 'FPS: ' + getFPS();
    var memoryText:String = 'MEM: ' + getMemory();

    text = '$fpsText\n$memoryText';
    super.sync(ctx);

    updateTimer = UPDATE_INTERVAL;
  }

  function getFPS():Float
  {
    return Timer.fps().round(2);
  }

  function getMemory():String
  {
    final totalMemory:Float = Engine.getCurrent().mem.stats().totalMemory;
    return StringUtil.formatBytes(totalMemory);
  }
}
