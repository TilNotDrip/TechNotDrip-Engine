package funkin.data.object;

/**
 * The base structure for an object for use with Flixel.
 *
 * An system for converting this to an object is implimented inside of funkin.objects.FunkinSprite
 */
typedef ObjectData =
{
  /**
   * The identifier for this object.
   *
   * Useful when trying to call this object via script.
   */
  @:optional
  var ?id:String;

  /**
   * The path used to display the object.
   *
   * Can either be
   *
   * - Asset Path (e.g "ui/mainmenu/menuBG")
   *
   * - Color (e.g "#00FF00") (Animations will not be used if this is used)
   *
   * - URL (e.g "https://images.gamebanana.com/img/ss/mods/6341cc54e0b70.jpg") (Takes longer unless you're loading the graphic on another thread)
   */
  var path:String;

  /**
   * The placement of where this object should be.
   */
  @:optional
  var ?position:PositionData;

  @:optional
  var ?animation:AnimationData;

  @:optional
  var ?alpha:Float;

  @:optional
  var ?antialiasing:Bool;

  @:optional
  var ?flipX:Bool;

  @:optional
  var ?flipY:Bool;

  @:optional
  var ?scale:PointData;

  @:optional
  var ?scrollFactor:PointData;
}

// TODO: when we make a custom json parser, make it so you can use an array or dis
typedef PointData =
{
  @:optional
  var ?x:Float;

  @:optional
  var ?y:Float;
}

typedef PositionData =
{
  > PointData,

  @:optional
  var ?z:Int;
}

typedef AnimationData =
{
  @:optional
  var ?type:String;

  var anims:Array<AnimationDataArray>;
}

typedef AnimationDataArray =
{
  var name:String;

  var prefix:String;

  @:optional
  var ?indices:Array<Int>;

  @:optional
  var ?framerate:Int;

  @:optional
  var ?looped:Bool;

  @:optional
  var ?flipX:Bool;

  @:optional
  var ?flipY:Bool;

  @:optional
  var ?offsets:PositionData;
}
