package funkin.states.ui;

import funkin.data.song.Song;
import funkin.objects.ui.freeplay.FreeplayCapsule;
import funkin.objects.ui.freeplay.FreeplayDJ;
import funkin.objects.ui.freeplay.backingcards.BackingCard;
import funkin.objects.ui.freeplay.backingcards.BoyfriendBackingCard;
import funkin.shaders.ui.AngleMask;
import funkin.shaders.ui.StrokeShader;
import funkin.util.Week;

class FreeplayState extends FunkinState
{
	/**
	 * Current Selection.
	 */
	public var curSelected:Int = 0;

	/**
	 * The songs.
	 */
	public var songs:Array<Song>;

	/**
	 * The thing behind the DJ
	 */
	public var backingCard:BackingCard;

	/**
	 * The Freeplay DJ.
	 */
	public var dj:FreeplayDJ;

	/**
	 * The dad in the bg.
	 */
	public var bgDad:FunkinSprite;

	/**
	 * ze angle mask shader
	 */
	public var angleMaskShader:AngleMask;

	/**
	 * The thing that says Official OST.
	 */
	public var ostName:FlxText;

	/**
	 * The thing that says Official OST.
	 */
	public var grpCapsules:FlxTypedGroup<FreeplayCapsule>;

	/**
	 * Should there be an intro?
	 */
	public var skipIntro:Bool = false;

	/**
	 * Blocks the inputs, like selecting and moving.
	 */
	public var blockInputs:Bool = false;

	override public function create():Void
	{
		#if FUNKIN_DISCORD_RPC
		DiscordRPC.details = 'Freeplay Menu';
		#end

		songs = [];

		for (week in Week.fetchAllWeeks())
		{
			for (song in week.songs)
				songs.push(song);
		}

		angleMaskShader = new AngleMask();

		backingCard = new BoyfriendBackingCard(this);
		add(backingCard);

		bgDad = new FunkinSprite(backingCard.pinkBack.width * 0.74, 0).loadTexture('ui/freeplay/freeplayBGdad');
		bgDad.setGraphicSize(0, FlxG.height);
		bgDad.updateHitbox();
		bgDad.shader = angleMaskShader;

		var blackOverlay:FlxSprite = new FlxSprite(387.76).makeGraphic(Std.int(bgDad.width), Std.int(bgDad.height), FlxColor.BLACK);
		blackOverlay.setGraphicSize(0, FlxG.height);
		blackOverlay.updateHitbox();
		blackOverlay.shader = bgDad.shader;

		add(blackOverlay);
		add(bgDad);

		dj = new FreeplayDJ(640, 366, 'bf');
		add(dj);

		var overhangStuff:FlxSprite = new FlxSprite(0, -100).makeGraphic(FlxG.width, 164, FlxColor.BLACK);
		add(overhangStuff);

		var sillyStroke:StrokeShader = new StrokeShader(0xFFFFFFFF, 2, 2);

		var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
		fnfFreeplay.font = Paths.location.get('ui/fonts/vcr.ttf');
		fnfFreeplay.visible = false;
		fnfFreeplay.shader = sillyStroke;
		add(fnfFreeplay);

		ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48);
		ostName.font = Paths.location.get('ui/fonts/vcr.ttf');
		ostName.alignment = RIGHT;
		ostName.visible = false;
		ostName.shader = sillyStroke;
		add(ostName);

		grpCapsules = new FlxTypedGroup<FreeplayCapsule>();
		add(grpCapsules);

		var randomCapsule:FreeplayCapsule = new FreeplayCapsule();
		randomCapsule.init('Random');
		grpCapsules.add(randomCapsule);

		generateCapsules();

		super.create();

		if (!skipIntro)
		{
			blockInputs = true;

			backingCard.startIntroTween();

			bgDad.visible = false;

			for (i in grpCapsules.members)
				i.visible = false;

			blackOverlay.x = FlxG.width;
			FlxTween.tween(blackOverlay, {x: 387.76}, 0.7, {
				ease: FlxEase.quintOut,
				onUpdate: (_) ->
				{
					angleMaskShader.extraColor = bgDad.color;
				}
			});

			overhangStuff.y = -overhangStuff.height;
			FlxTween.tween(overhangStuff, {y: -100}, 0.3, {ease: FlxEase.quartOut});

			dj.introDone.add(() ->
			{
				blockInputs = false;

				FlxTween.color(bgDad, 0.6, 0xFF000000, 0xFFFFFFFF, {ease: FlxEase.expoOut});
				backingCard.introDone();

				bgDad.visible = true;

				for (i in grpCapsules.members)
					i.visible = true;

				new FlxTimer().start(1 / 24, (_) ->
				{
					fnfFreeplay.visible = true;
					ostName.visible = true;

					new FlxTimer().start(1.5 / 24, (_) ->
					{
						sillyStroke.width = 0;
						sillyStroke.height = 0;
					});
				});
			});
		}

		changeSelection();
	}

	override public function beatHit():Void
	{
		dj.beatHit();
	}

	override public function update(elapsed:Float):Void
	{
		// FINE CRUSHER ARE YOU HAPPY
		// yes
		conductor.update();
		super.update(elapsed);

		if (!blockInputs)
		{
			if (controls.ACCEPT #if debug && !FlxG.keys.justPressed.SPACE #end)
			{
				backingCard.confirm();
				dj.confirm();
			}

			if (controls.BACK)
			{
				FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
				FlxG.switchState(MenuState.new);
			}

			if (controls.UI_UP_P)
				changeSelection(-1);

			if (controls.UI_DOWN_P)
				changeSelection(1);
		}
	}

	/**
	 * Generates the capsules.
	 * @return Void
	 */
	public function generateCapsules():Void
	{
		// TODO: regeneration

		for (song in songs)
		{
			var capsule:FreeplayCapsule = new FreeplayCapsule();
			capsule.init(song.getDisplayName(), song.getFreeplayIcon());
			grpCapsules.add(capsule);
		}
	}

	public function changeSelection(?index:Int = 0):Void
	{
		curSelected += index;

		if (curSelected >= songs.length + 1) // random
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = songs.length;

		for (i => capsule in grpCapsules.members)
		{
			i += 1;

			capsule.selected = i == curSelected + 1;

			capsule.lerpPos.y = capsule.intendedY(i - curSelected);
			capsule.lerpPos.x = 270 + (60 * (Math.sin(i - curSelected)));

			if (i < curSelected)
				capsule.lerpPos.y -= 100; // another 100 for good measure
		}
	}
}
