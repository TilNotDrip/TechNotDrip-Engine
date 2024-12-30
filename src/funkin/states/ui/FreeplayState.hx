package funkin.states.ui;

import funkin.objects.ui.freeplay.backingcards.BackingCard;
import funkin.objects.ui.freeplay.backingcards.BoyfriendBackingCard;
import funkin.shaders.ui.AngleMask;

class FreeplayState extends FunkinState
{
	/**
	 * The thing behind the DJ
	 */
	public var backingCard:BackingCard;

	/**
	 * The Freeplay DJ.
	 */
	public var dj:FunkinSprite;

	/**
	 * The dad in the bg.
	 */
	public var bgDad:FunkinSprite;

	public var angleMaskShader:AngleMask = new AngleMask();

	override public function create():Void
	{
		#if FUNKIN_DISCORD_RPC
		DiscordRPC.details = 'Freeplay Menu';
		#end

		backingCard = new BoyfriendBackingCard(this);
		add(backingCard);

		bgDad = new FunkinSprite(backingCard.pinkBack.width * 0.74, 0).loadTexture('ui/freeplay/freeplayBGdad');
		bgDad.setGraphicSize(0, FlxG.height);
		bgDad.shader = angleMaskShader;
		add(bgDad);

		dj = new FunkinSprite().loadFrames('ui/freeplay/freeplay-boyfriend');
		dj.addAnimation('idle', 'Boyfriend DJ');
		dj.playAnimation('idle');
		add(dj);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		// FINE CRUSHER ARE YOU HAPPY
		// yes
		conductor.update();
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			backingCard.confirm();
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
			FlxG.switchState(MenuState.new);
		}
	}
}
