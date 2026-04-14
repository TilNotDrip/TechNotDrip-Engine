package funkin.ui;

import flixel.util.FlxStringUtil;
import openfl.display.Sprite;
import openfl.filters.DropShadowFilter;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * The performance stats TextField keeps track of FPS and Memory in-game.
 */
class PerformanceStats extends Sprite
{
  /**
   * How long we should wait until we update the text.
   */
  public static final TEXT_UPDATE_INTERVAL:Float = 0.1;

  /**
   * How many frames have passed since the last second.
   */
  public var framesPerSecond(default, null):Float;

  /**
   * The amount of RAM the application is currently using.
   */
  public var randomAccessMemory(get, null):Null<Float>;

  /**
   * The main text that shows FPS and RAM Usage.
   */
  var mainText:TextField;

  var textUpdateTimer:Float;

  public function new(x:Float = 5, y:Float = 5)
  {
    super();
    visible = true;

    mainText = new TextField();
    mainText.x = x;
    mainText.y = y;
    mainText.selectable = false;
    mainText.mouseEnabled = false;
    mainText.defaultTextFormat = new TextFormat(Paths.location.get("ui/fonts/vcr.ttf"), 12, 0xFFFFFF);

    // Outline
    var borderSize:Float = 1;
    mainText.filters = [
      new DropShadowFilter(borderSize, 0, 0, 1, 0, 0),
      new DropShadowFilter(borderSize, 90, 0, 1, 0, 0),
      new DropShadowFilter(borderSize, 180, 0, 1, 0, 0),
      new DropShadowFilter(borderSize, 270, 0, 1, 0, 0)
    ];

    addChild(mainText);

    textUpdateTimer = TEXT_UPDATE_INTERVAL;
  }

  /**
   * Update the counter.
   * @param elapsed The seconds elapsed since last call.
   */
  public function update(elapsed:Float):Void
  {
    if (elapsed <= 0)
      return;

    textUpdateTimer -= elapsed;

    var currentFPS:Float = 1 / elapsed;
    var smoothMult:Float = FlxMath.bound(elapsed / 0.5, 0.05, 1);

    framesPerSecond = framesPerSecond * (1 - smoothMult) + currentFPS * smoothMult;
    framesPerSecond = Math.min(framesPerSecond, FlxG.game.stage.frameRate);

    if (textUpdateTimer <= 0)
    {
      mainText.text = "FPS: " + FlxMath.roundDecimal(framesPerSecond, 2) + "\n" + getMemory();
      textUpdateTimer = TEXT_UPDATE_INTERVAL;
    }
  }

  function getMemory():String
  {
    var ram:Float = randomAccessMemory ?? 0;
    var formatted:String = FlxStringUtil.formatBytes(ram);

    if (ram > 0)
      formatted = 'MEM: ${formatted}';

    return formatted;
  }

  function get_randomAccessMemory():Null<Float>
  {
    #if cpp
    return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
    #elseif hl
    return hl.Gc.stats().currentMemory;
    #elseif (js && html5)
    // `window.performance.memory` is getting deprecated, and the only other memory checker is asynchronous.
    // Remove this soon?
    if (untyped __js__("(window.performance && window.performance.memory)"))
      return untyped __js__("window.performance.memory.usedJSHeapSize");
    #end

    return null;
  }
}
