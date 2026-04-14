package funkin.data.week;

import funkin.data.object.ObjectData;

typedef WeekData =
{
  var name:String;

  var songs:Array<String>;

  @:optional
  var ?startLocked:Bool;

  @:optional
  var ?songToUnlock:String;

  @:optional
  var ?weekToUnlock:String;

  @:optional
  var ?visibleWhenLocked:Bool;

  @:optional
  var ?sprites:Array<ObjectData>;

  @:optional
  var ?motto:String;

  @:optional
  var ?storyPosition:Int;

  @:optional
  var ?background:String;
}
