package funkin.objects.ui;

class WeekItem extends FunkinSprite
{
	public var targetY:Float = 0;

	private var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekName:String)
	{
		super(x, y);
		loadGraphic(Paths.content.imageGraphic('ui/story/titles/' + weekName));
	}

	var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		y = MathUtil.coolLerp(y, (targetY * 120) + 480, 0.17);

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			color = 0xFF33FFFF;
		else
			color = FlxColor.WHITE;
	}
}
