package funkin.states.test;

import funkin.objects.ui.Alphabet;
import funkin.states.ui.TitleState;

class AlphabetTestState extends FunkinState
{
	var text:Alphabet;

	override public function create():Void
	{
		var greyBG:FunkinSprite = new FunkinSprite();
		greyBG.loadTexture('#323232', Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5));
		greyBG.screenCenter();
		add(greyBG);

		text = new Alphabet(0, 0, "hi this is a test", 0, "bold");
		add(text);
	}

	override public function update(elapsed:Float):Void
	{
		var velo:Float = FlxG.keys.pressed.SHIFT ? 50 : 10;
		if (FlxG.keys.pressed.LEFT)
			text.x -= velo * elapsed;
		else if (FlxG.keys.pressed.RIGHT)
			text.x += velo * elapsed;

		if (FlxG.keys.pressed.UP)
			text.y -= velo * elapsed;
		else if (FlxG.keys.pressed.DOWN)
			text.y += velo * elapsed;

		if (FlxG.keys.pressed.Z)
			FlxG.camera.zoom += 0.2 * elapsed;
		else if (FlxG.keys.pressed.X)
			FlxG.camera.zoom -= 0.2 * elapsed;

		if (FlxG.keys.justPressed.C)
			text.atlasFontID = (text.atlasFontID == 'bold') ? 'normal' : 'bold';

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(TitleState.new);

		super.update(elapsed);
	}
}
