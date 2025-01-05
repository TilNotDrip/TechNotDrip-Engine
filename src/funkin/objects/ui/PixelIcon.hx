package funkin.objects.ui;

class PixelIcon extends FunkinSprite
{
	/**
	 * If the icon is animated or not
	 */
	public var animated:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(32, 32, 0x00000000);
		antialiasing = false;
		active = false;
	}

	/**
	 * Changes the character.
	 * @param char The character
	 */
	public function setCharacter(char:String):Void
	{
		var iconPath:String = 'ui/freeplay/icons/' + char;

		if (!Paths.location.exists(iconPath + '.xml'))
		{
			trace('[WARN] $char has no freeplay icon.');
			return;
		}

		animated = Paths.location.exists(iconPath + '.xml');

		if (animated)
			loadFrames(iconPath);
		else
			loadTexture(iconPath);

		scale.set(2, 2);

		origin.x = switch (char)
		{
			case 'parents-christmas':
				140;
			default:
				100;
		}

		if (animated)
		{
			active = true;
			addAnimation('idle', 'idle', null, 10, true);
			addAnimation('confirm', 'confirm', null, 10, false);
			addAnimation('confirm', 'confirm', null, 10, true);

			onAnimFinished.add((name:String) ->
			{
				if (name == 'confirm')
					playAnimation('confirm-hold');
			});

			playAnimation('idle');
		}
	}
}
