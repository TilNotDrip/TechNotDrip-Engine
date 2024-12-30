package funkin.states.ui;

import funkin.objects.ui.WeekItem;
import funkin.util.Week;

class StoryState extends FunkinState
{
	/**
	 * The weeks that the game has successfully loaded.
	 */
	public var loadedWeeks:Array<Week> = [];

	static var curSelected:Int = 0;

	var selectedWeek:Bool = false;

	var colorBG:FunkinSprite;

	var txtTracklist:FlxText;
	var scoreText:FlxText = null;
	var weekMotto:FlxText = null;

	var grpWeekItems:FlxTypedGroup<WeekItem>;
	var grpOfWeekSprGrps:FlxTypedSpriteGroup<FunkinSpriteGroup>;

	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	override public function create():Void
	{
		loadedWeeks = Week.fetchAllWeeks();

		grpWeekItems = new FlxTypedGroup<WeekItem>();
		grpWeekItems.z = 10;
		add(grpWeekItems);

		txtTracklist = new FlxText(FlxG.width * 0.05, 500, 0, "", 32);
		txtTracklist.setFormat("VCR OSD Mono", 32, 0xFFE55777, CENTER);
		txtTracklist.antialiasing = false;
		add(txtTracklist);

		var topBlackBar:FunkinSprite = new FunkinSprite().loadTexture('#000000', FlxG.width, 56);
		topBlackBar.z = 20;
		add(topBlackBar);

		scoreText = new FlxText(10, 10, 0, "SCORE: 0", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.z = 30;
		add(scoreText);

		weekMotto = new FlxText(FlxG.width, 10, 0, "", 32);
		weekMotto.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		weekMotto.alpha = 0.7;
		weekMotto.z = 40;
		add(weekMotto);

		colorBG = new FunkinSprite(0, 56).loadTexture('#FFFFFF', FlxG.width, 400);
		colorBG.z = 50;
		add(colorBG);

		grpOfWeekSprGrps = new FlxTypedSpriteGroup<FunkinSpriteGroup>(0, 56);
		grpOfWeekSprGrps.z = 100;
		add(grpOfWeekSprGrps);

		for (i => week in loadedWeeks)
		{
			var weekSpr:WeekItem = new WeekItem(0, colorBG.y + colorBG.height + 10, week.id);
			weekSpr.targetY = i;
			weekSpr.z = 10;
			grpWeekItems.add(weekSpr);

			weekSpr.screenCenter(X);

			var weekSprGrp:FunkinSpriteGroup = week.buildSprites();
			grpOfWeekSprGrps.add(weekSprGrp);

			// TODO: ADD LOCK SPRITE
		}

		super.create();

		rearrange();
		changeItem();
	}

	override public function update(elapsed:Float):Void
	{
		lerpScore = MathUtil.coolLerp(lerpScore, intendedScore, 0.5);

		scoreText.text = "SCORE: " + Math.round(lerpScore);

		conductor.update();

		super.update(elapsed);

		if (selectedWeek)
			return;

		if (controls.UI_UP_P)
			changeItem(-1);

		if (controls.UI_DOWN_P)
			changeItem(1);

		if (controls.ACCEPT)
		{
			selectedWeek = true;

			FlxG.sound.play(Paths.content.audio('ui/menu/confirmMenu'));

			for (spr in grpOfWeekSprGrps.members[curSelected].members)
			{
				if (spr.animation.exists('confirm'))
					spr.animation.play('confirm', true);
			}

			grpWeekItems.members[curSelected].startFlashing();

			new FlxTimer().start(1, (_) ->
			{
				// TODO: Change this to PlayState
				FlxG.switchState(MenuState.new);
			});
		}

		if (controls.BACK)
		{
			FlxG.switchState(MenuState.new);
		}
	}

	override public function beatHit():Void
	{
		danced = !danced;

		for (grp in grpOfWeekSprGrps.members)
		{
			for (spr in grp.members)
			{
				if (spr.animation.curAnim?.name != 'confirm')
					spr.animation.play(getIdleAnimationForSprite(spr), false);
			}
		}
	}

	var danced:Bool = false;

	public function getIdleAnimationForSprite(spr:FlxSprite):String
	{
		if (spr.animation.exists('danceLeft') || spr.animation.exists('danceRight'))
		{
			return (danced) ? 'danceLeft' : 'danceRight';
		}

		return 'idle';
	}

	function changeItem(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected >= loadedWeeks.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = loadedWeeks.length - 1;

		if (change != 0)
			FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));

		colorBG.color = loadedWeeks[curSelected].getBGColor();

		weekMotto.text = loadedWeeks[curSelected].getMotto();
		weekMotto.x = FlxG.width - (weekMotto.width + 10);

		txtTracklist.text = "TRACKS\n\n";
		txtTracklist.text += loadedWeeks[curSelected].getDisplaySongNames().join('\n');

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		for (i => item in grpWeekItems.members)
		{
			item.targetY = i - curSelected;
			if (item.targetY == 0 /* && !loadedWeeks[curSelected].locked*/)
				item.alpha = 1;
			else
				item.alpha = 0.6;
		}

		for (i => sprGrps in grpOfWeekSprGrps.members)
		{
			sprGrps.forEach((spr:FunkinSprite) ->
			{
				spr.doInvisibleDraw = (curSelected != i);
			});
		}
	}
}
