package funkin.play.hud;

import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import funkin.sound.Conductor;

class HealthBar extends FlxSpriteGroup
{
  /**
   * The players current health.
   */
  public var health(default, set):Float;

  /**
   * The health that gets displayed on the health bar.
   */
  public var healthLerp(default, set):Float;

  public var ui(default, set):String = 'funkin';
  public var iconGrp:FlxTypedSpriteGroup<HealthIcon>;
  public var downScroll(default, set):Bool = false; // TODO: you know i know we know

  /**
   * This toggles the easter egg whether the player can hit 9 during a song and iconP1 switches to their old icon.
   */
  public var easterEgg:Bool = true;

  var conductor:Conductor = null;

  var bg:FlxSprite;
  var bar:FlxBar;

  var initialized:Bool = false;

  public function new(?params:HealthBarParams)
  {
    if (params == null)
    {
      params = {
        ui: 'funkin',
        downScroll: false // TODO: you know i know we know
      };
    }

    super(0, 0, 0);

    ui = params.ui;
    downScroll = params.downScroll;
    easterEgg = params?.easterEgg ?? true;

    conductor = PlayState.instance.conductor;
    conductor.beatHit.add(bop);

    bg = new FlxSprite().loadGraphic(Paths.content.imageGraphic('gameplay/hud/$ui/healthBar'));
    add(bg);

    bar = new FlxBar(4, 4, RIGHT_TO_LEFT, Std.int(bg.width - 8), Std.int(bg.height - 8), null, null, 0, 2, false);
    bar.createFilledBar(0xFFFF0000, 0xFF00FF00);
    add(bar);

    iconGrp = new FlxTypedSpriteGroup<HealthIcon>();
    add(iconGrp);

    healthLerp = health = 1; // Constants.HEALTH_STARTING;

    initialized = true;
  }

  override public function update(elapsed:Float):Void
  {
    var easterEggToggle:Bool = false;
    #if FLX_KEYBOARD easterEggToggle = FlxG.keys.justPressed.NINE; #end
    if (easterEgg && easterEggToggle)
    {
      for (spr in iconGrp.members)
      {
        if (spr.direction == RIGHT)
        {
          spr.swapOldIcon();
        }
      }
    }

    healthLerp = FlxMath.lerp(healthLerp, health, 0.15);

    super.update(elapsed);
  }

  /**
   * The function used to make the icons bop every beat.
   * Can be overriden by setting it like a regular variable.
   */
  public dynamic function bop():Void
  {
    var crochetTime:Float = (conductor.crochet / 1000);
    var startUpTime:Float = crochetTime * 0.05;
    var resetTime:Float = crochetTime - startUpTime;

    for (spr in iconGrp.members)
    {
      if (spr == null || !spr.canBop)
        continue;

      FlxTween.cancelTweensOf(spr.iconScale);
      FlxTween.cancelTweensOf(spr.iconScale);

      FlxTween.tween(spr.iconScale, {x: 1.3, y: 1.3}, startUpTime, {ease: FlxEase.cubeIn});
      FlxTween.tween(spr.iconScale, {x: 1, y: 1}, resetTime, {ease: FlxEase.cubeOut, startDelay: startUpTime});
    }
  }

  function set_health(value:Float):Float
  {
    health = FlxMath.bound(value, bar.min, bar.max);

    for (spr in iconGrp.members)
    {
      if (spr != null)
      {
        spr.updateIconAnimation(FlxMath.remapToRange(health, 0, 2, 100, 0));
      }
    }

    return health;
  }

  function set_healthLerp(value:Float):Float
  {
    healthLerp = bar.value = value;

    for (spr in iconGrp.members)
    {
      if (spr == null)
        continue;

      spr.y = bar.y - (spr.height / 2);

      if (spr.direction == RIGHT)
        spr.x = bar.x + (bar.width * (FlxMath.remapToRange(healthLerp, 0, 2, 100, 0) * 0.01) - 26);
      else
        spr.x = bar.x + (bar.width * (FlxMath.remapToRange(healthLerp, 0, 2, 100, 0) * 0.01)) - (spr.width - 26);
    }

    return healthLerp;
  }

  function set_ui(value:String):String
  {
    ui = value;
    return ui;
  }

  function set_downScroll(value:Bool):Bool
  {
    downScroll = value;

    y = FlxG.height * 0.9;
    y = FlxG.height - y - height; // beautiful code so everything is 1-1

    return downScroll;
  }
}

typedef HealthBarParams =
{
  var ui:String;
  var downScroll:Bool;
  var ?easterEgg:Bool;
}
