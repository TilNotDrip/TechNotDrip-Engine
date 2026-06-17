package funkin.play.hud;

import flixel.FlxBasic;
import funkin.play.hud.notes.Playfield;

class BaseHud extends FlxTypedGroup<FlxBasic>
{
  /**
   * The strumline playing fields on this HUD.
   */
  public var playfields:FlxTypedGroup<Playfield>;

  var path:String;

  public function new(id:String)
  {
    path = 'gameplay/hud/$id';

    super();

    playfields = new FlxTypedGroup<Playfield>();
    playfields.z = 500;
    add(playfields);
  }

  /**
   * Updates the tallies on the HUD.
   */
  public function updateTallies():Void {}

  /**
   * Creates a playfield.
   * @param data The strumline data to use.
   * @param conductor The conductor to use for calculations.
   * @return The playfield created.
   */
  public function createPlayfield(data:StrumlineData, conductor:Conductor):Playfield
  {
    final playfield:Playfield = new Playfield(data, conductor);
    return playfields.add(playfield);
  }
}
