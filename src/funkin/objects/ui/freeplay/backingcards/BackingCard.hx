package funkin.objects.ui.freeplay.backingcards;

import funkin.states.ui.FreeplayState;

class BackingCard extends FlxSpriteGroup
{
	public var pinkBack:FunkinSprite;

	public var instance:FreeplayState;

	public function new(instance:FreeplayState)
	{
		this.instance = instance;

		super();

		pinkBack = new FunkinSprite().loadTexture('ui/freeplay/backingCard/pinkBack');
		pinkBack.color = 0xFFFFD863;
		add(pinkBack);

		instance.conductor.beatHit.add(beatHit);
	}

	override public function destroy():Void
	{
		instance.conductor.beatHit.remove(beatHit);
		super.destroy();
	}

	/**
	 * Called when entering from MenuState
	 */
	public function startIntroTween():Void
	{
		pinkBack.color = 0xFFFFD4E9; // sets it to pink!
		pinkBack.x -= pinkBack.width;

		FlxTween.tween(pinkBack, {x: 0}, 0.6, {ease: FlxEase.quartOut});
	}

	/**
	 * Called after DJ finishes their start animation.
	 */
	public function introDone():Void
	{
		pinkBack.color = 0xFFFFD863;
	}

	/**
	 * Called when selecting a song.
	 */
	public function confirm():Void
	{
		FlxTween.color(pinkBack, 0.33, 0xFFFFD0D5, 0xFF171831, {ease: FlxEase.quadOut});
	}

	/**
	 * Called when entering character select.
	 */
	public function enterCharSel():Void {}

	/**
	 * Called on each beat.
	 */
	public function beatHit():Void {}

	/**
	 * Called when exiting Freeplay.
	 */
	public function exit():Void {}
}
