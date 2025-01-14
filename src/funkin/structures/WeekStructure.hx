package funkin.structures;

typedef WeekStructure =
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
	var ?sprites:Array<ObjectStructure>;

	@:optional
	var ?motto:String;

	@:optional
	var ?storyPosition:Int;

	@:optional
	var ?background:String;
}
