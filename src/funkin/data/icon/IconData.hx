package funkin.data.icon;

import funkin.data.object.ObjectData;

typedef IconData =
{
  /**
   * Used for split animations, basically icons normally.
   */
  var resolution:Array<Int>;

  /**
   * Color of the icon.
   */
  var color:String;

  /**
   * If the icon should have antialiasing enabled.
   */
  var antialiasing:Bool;

  /**
   * If the icon should play a bop on beat.
   */
  var shouldBop:Bool;

  /**
   * The scale to use for this icon.
   */
  var scale:PointData;

  var animations:Array<AnimationDataArray>;
  var healthAnimations:Array<HealthAnimation>;
}

typedef HealthAnimation =
{
  var minimumHealth:Float;
  var maximumHealth:Float;
  var anim:String;
}
