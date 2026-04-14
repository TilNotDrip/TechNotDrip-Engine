package funkin.play.hud.strumline;

import flixel.system.macros.FlxMacroUtil;
import flixel.util.FlxSort;

enum abstract NoteDirection(Int) to Int from Int
{
  public static var toStringMap(default, null):Map<NoteDirection, String> = FlxMacroUtil.buildMap("funkin.play.hud.strumline.NoteDirection", true, []);
  public static var allDirections(get, never):Array<NoteDirection>;

  var LEFT = 0;
  var DOWN = 1;
  var UP = 2;
  var RIGHT = 3;

  public var name(get, never):String;
  public var color(get, never):String;

  // TODO: make these softcoded
  function get_name():String
  {
    return switch (abstract)
    {
      default:
        (toStringMap.get(abstract) ?? '').toLowerCase();
    }
  }

  function get_color():String
  {
    return switch (abstract)
    {
      case LEFT:
        'purple';
      case DOWN:
        'blue';
      case UP:
        'green';
      case RIGHT:
        'red';
    }
  }

  static function get_allDirections():Array<NoteDirection>
  {
    var toReturn:Array<NoteDirection> = [];

    for (direction in toStringMap.keys())
      toReturn.push(direction);

    toReturn.sort((a:NoteDirection, b:NoteDirection) ->
    {
      return FlxSort.byValues(FlxSort.ASCENDING, a, b);
    });

    return toReturn;
  }
}
