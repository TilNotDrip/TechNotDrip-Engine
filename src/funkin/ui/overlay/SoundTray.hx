package funkin.ui.overlay;

import h2d.Object;
import h2d.col.Bounds;
import hxd.Key;
import hxd.snd.Manager as SoundManager;

class SoundTray extends Object
{
  /**
   * Default scale for sound tray assets.
   */
  public static final GRAPHIC_SCALE:Float = 0.5;

  var barTiles:Array<FunkinTile>;
  var bar:FunkinSprite;
  var box:FunkinSprite;

  var lerpYPos:Float;
  var alphaTarget:Float;
  var timer:Float;

  final restingY:Float;
  final size:Bounds;

  public function new()
  {
    super();
    barTiles = [];

    for (i in 0...10)
    {
      final image:Image = Paths.content.image('ui/sound-tray/bars/${i + 1}');
      barTiles.push(cast image.toTile());
    }

    box = new FunkinSprite(null);
    box.loadTexture('ui/sound-tray/box');
    box.setScale(GRAPHIC_SCALE);
    addChild(box);

    var bgBar:FunkinSprite = new FunkinSprite();
    bgBar.tile = barTiles[9];
    bgBar.setPosition(30 * GRAPHIC_SCALE, 16 * GRAPHIC_SCALE);
    bgBar.setScale(GRAPHIC_SCALE);
    bgBar.alpha = 0.4;
    addChild(bgBar);

    bar = new FunkinSprite();
    bar.setPosition(30 * GRAPHIC_SCALE, 16 * GRAPHIC_SCALE);
    bar.setScale(GRAPHIC_SCALE);
    bar.visible = false;
    addChild(bar);

    size = getSize();
    y = -size.height - 10;

    lerpYPos = y;
    restingY = y;
    alphaTarget = 0;
    timer = Math.NaN;
  }

  override function sync(ctx:RenderContext):Void
  {
    updateInput();

    if (!Math.isNaN(timer))
      timer -= ctx.elapsedTime;

    if (timer <= 0)
    {
      lerpYPos = restingY;
      alphaTarget = 0;
      timer = Math.NaN;
    }

    y = MathUtil.smoothLerpPrecision(y, lerpYPos, ctx.elapsedTime, 0.768);
    alpha = MathUtil.smoothLerpPrecision(alpha, alphaTarget, ctx.elapsedTime, 0.307);
    super.sync(ctx);
  }

  function updateInput():Void
  {
    final soundManager:SoundManager = SoundManager.get();
    var volume:Float = soundManager.masterVolume;

    if (Key.isPressed(Key.NUMBER_0))
      volume = 0;
    else if (Key.isPressed(Key.QWERTY_MINUS))
      volume -= 0.1;
    else if (Key.isPressed(Key.QWERTY_EQUALS))
      volume += 0.1;

    if (volume != soundManager.masterVolume)
    {
      final variant:String =
        {
          if (volume >= 1)
            'max';
          else if (volume > soundManager.masterVolume)
            'up';
          else
            'down';
        };

      final sound:Sound = Paths.content.audio('ui/sound-tray/vol-$variant');
      soundManager.masterVolume = volume.clamp(0, 1);
      sound.play();

      final barVal:Int = Math.round(soundManager.masterVolume * 10);

      if (barVal > 0)
      {
        bar.tile = barTiles[barVal - 1];
        bar.visible = true;
      }
      else
        bar.visible = false;

      x = MathUtil.center(cast(parent, h2d.Scene)?.width, size.width);
      lerpYPos = 10;
      alphaTarget = 1;
      timer = 1;
    }
  }
}
