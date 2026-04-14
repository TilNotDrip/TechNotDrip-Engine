package funkin.play.hud;

import flixel.FlxBasic;
import funkin.data.strumline.StrumlineData;
import funkin.input.InputUtil;
import funkin.play.PlayState;
import funkin.play.hud.strumline.NoteSprite;
import funkin.play.hud.strumline.Strumline;
import funkin.play.hud.strumline.SustainNoteSprite;

class Hud extends FlxTypedGroup<FlxBasic>
{
  /**
   * The strumline data.
   */
  public var strumlineDatas:Array<StrumlineData> = [];

  /**
   * Strumlines.
   */
  public var strumlines:FlxTypedGroup<Strumline>;

  /**
   * Health Bar.
   */
  public var healthBar:HealthBar;

  /**
   * HUD Parameters.
   */
  public var params:HudParam;

  var parent:PlayState;

  public function new(params:HudParam)
  {
    this.params = params;
    super();
    parent = PlayState.instance;

    strumlines = new FlxTypedGroup<Strumline>();
    add(strumlines);

    healthBar = new HealthBar({
      ui: params.ui,
      downScroll: params.downScroll
    });
    healthBar.screenCenter(X);
    healthBar.y = FlxG.height * 0.9;
    add(healthBar);
  }

  /**
   * Generates the Strumlines.
   */
  public function generateStrumlines():Void
  {
    // TODO: change this Array to something from PlayState, so you can have more than 3 characters.
    for (strumlineID in ['player', 'opponent', 'spectator'])
    {
      var strumlineData:StrumlineData = new StrumlineData(strumlineID, parent.conductor);
      strumlineDatas.push(strumlineData);

      if (strumlineData.strumline != null)
      {
        var strumline:Strumline = strumlineData.strumline;
        strumline.setupNotes(parent.chart);
        strumlines.add(strumline);
      }

      strumlineData.onUpdateHealth.add((healthChange:Float) ->
      {
        healthBar.health += healthChange;
      });

      if (strumlineData.healthIcon != null)
        healthBar.iconGrp.add(strumlineData.healthIcon);
    }
  }

  override public function update(elapsed:Float)
  {
    for (i in strumlineDatas)
    {
      i.update();
    }

    super.update(elapsed);
  }
}

typedef HudParam =
{
  var ui:String;
  var downScroll:Bool;
}
