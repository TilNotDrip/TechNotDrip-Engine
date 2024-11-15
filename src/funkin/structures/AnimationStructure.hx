package funkin.structures;

typedef AnimationStructure = {
    var name:String;

    var prefix:String;

    @:optional
    var indices:Array<Int>;

    @:optional
    var framerate:Int;

    @:optional
    var looped:Bool;

    @:optional
    var flipX:Bool;

    @:optional
    var flipY:Bool;

    @:optional
    var offsets:PositionStructure;
}