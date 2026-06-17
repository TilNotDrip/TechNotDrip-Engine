package funkin.play.hud;

import funkin.play.hud.components.HealthBar;

class FunkinHud extends BaseHud
{
  /**
   * The Health Bar.
   */
  public var healthBar:HealthBar;

  public function new(?id:Null<String>)
  {
    super(id ?? 'funkin-default');

    healthBar = new HealthBar('$path/healthBar');
    healthBar.screenCenter(X);
    healthBar.y = FlxG.height * 0.9;
    add(healthBar);
  }
}
