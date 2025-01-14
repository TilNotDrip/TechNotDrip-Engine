package funkin.structures;

/**
 * The base structure for an object for use with Flixel.
 *
 * An system for converting this to an object is implimented inside of funkin.objects.FunkinSprite
 */
typedef ObjectStructure =
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
	 * - URL (e.g "https://images.gamebanana.com/img/ss/mods/6341cc54e0b70.jpg") (Takes longer unless your loading the graphic on another thread)
	 */
	var path:String;

	/**
	 * The placement of where this object should be.
	 */
	@:optional
	var ?position:PositionStructure;

	@:optional
	var ?animation:AnimationStructure;

	@:optional
	var ?alpha:Float;

	@:optional
	var ?antialiasing:Bool;

	@:optional
	var ?flipX:Bool;

	@:optional
	var ?flipY:Bool;

	@:optional
	var ?scale:PointStructure;

	@:optional
	var ?scrollFactor:PointStructure;
}

typedef PointStructure =
{
	@:optional
	var ?x:Float;

	@:optional
	var ?y:Float;
}

typedef PositionStructure =
{
	> PointStructure,

	@:optional
	var ?z:Int;
}

typedef AnimationStructure =
{
	var type:String;
	var anims:Array<AnimationArrayStructure>;
}

typedef AnimationArrayStructure =
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
	var ?offsets:PointStructure;
}
