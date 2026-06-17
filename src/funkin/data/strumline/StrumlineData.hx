package funkin.data.strumline;

import json2object.JsonParser;

class StrumlineData
{
  /**
   * Loads in strumline data from a ID.
   * @param id The ID mentioned above.
   * @return Strumline Data
   */
  public static function load(id:String):Null<StrumlineData>
  {
    var contents:String = Paths.content.json('gameplay/strumline/$id');

    var parser:JsonParser<StrumlineData> = new JsonParser<StrumlineData>();
    var data:Null<StrumlineData> = parser.fromJson(contents);

    if (data != null)
      data.id = id;

    return data;
  }

  /**
   * The ID of this Strumline.
   */
  @:jignored
  public var id:String;

  /**
   * If this Strumline is controlled by a Computer or not.
   */
  public var computerControlled:Bool;

  /**
   * If the actual playing field should be shown to the player or not.
   */
  @:default(true)
  public var showPlayfield:Bool;

  /**
   * The position of the strumline, as a percentage.
   * @see `percentPos = (originalPos + 48) / 1280`
   */
  @:optional
  public var playfieldPosition:Null<Float> = null;

  /**
   * The length of this strumline.
   *
   * This will determine the width of the playing field.
   */
  @:default(4)
  public var strumlineLength:Int;

  public function new()
  {
    this.computerControlled = true;
    this.showPlayfield = true;
    this.strumlineLength = 4;
  }
}
