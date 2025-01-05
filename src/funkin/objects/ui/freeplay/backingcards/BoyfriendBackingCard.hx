package funkin.objects.ui.freeplay.backingcards;

import flixel.util.FlxSpriteUtil;
import funkin.objects.ui.freeplay.BGScrollingText;
import funkin.states.ui.FreeplayState;

class BoyfriendBackingCard extends BackingCard
{
	var cardGlow:FunkinSprite;
	var confirmGlow:FunkinSprite;
	var confirmGlowTwo:FunkinSprite;
	var confirmTextGlow:FunkinSprite;
	var orangeBack:FunkinSprite;
	var orangeBackTwo:FunkinSprite;

	var glow:FunkinSprite;
	var glowDark:FunkinSprite;

	var moreWayss:Array<BGScrollingText> = [];
	var funnyScrolls:Array<BGScrollingText> = [];
	var watchNuts:BGScrollingText;

	public function new(instance:FreeplayState)
	{
		super(instance);

		orangeBack = new FunkinSprite(84, 440).loadTexture('#FEDA00', Std.int(pinkBack.width), 75);
		FlxSpriteUtil.alphaMaskFlxSprite(orangeBack, pinkBack, orangeBack);
		add(orangeBack);

		orangeBackTwo = new FunkinSprite(0, 440).loadTexture('#FFD400', 100, Std.int(orangeBack.height));
		add(orangeBackTwo);

		confirmGlowTwo = new FunkinSprite(-30, 240).loadTexture('ui/freeplay/backingCard/confirmGlow2');
		confirmGlowTwo.visible = false;
		add(confirmGlowTwo);

		confirmGlow = new FunkinSprite(-30, 240).loadTexture('ui/freeplay/backingCard/confirmGlow');
		confirmGlow.blend = ADD;
		confirmGlow.visible = false;
		add(confirmGlow);

		confirmTextGlow = new FunkinSprite(-8, 115).loadTexture('ui/freeplay/backingCard/glowingText');
		confirmTextGlow.blend = ADD;
		confirmTextGlow.visible = false;
		add(confirmTextGlow);

		cardGlow = new FunkinSprite(-30, -30).loadTexture('ui/freeplay/backingCard/cardGlow');
		cardGlow.visible = false;
		add(cardGlow);

		for (i in [[220, 0xFFFF9963], [335, 0xFFFF9963], [440, 0xFFFEA400]])
		{
			var funnyScroll:BGScrollingText = new BGScrollingText(0, i[0], 'BOYFRIEND', FlxG.width / 2, 60);
			funnyScroll.textColor = i[1];
			funnyScroll.speed = -3.8;
			funnyScrolls.push(funnyScroll);
			add(funnyScroll);
		}

		for (i in [160, 397])
		{
			var moreWays:BGScrollingText = new BGScrollingText(0, i, 'HOT BLOODED IN MORE WAYS THAN ONE', FlxG.width / 2, 43);
			moreWays.textColor = 0xFFFFF383;
			moreWays.speed = 6.8;
			moreWayss.push(moreWays);
			add(moreWays);
		}

		watchNuts = new BGScrollingText(0, 285, 'PROTECT YO NUTS', FlxG.width / 2, true, 43);
		watchNuts.speed = 3.5;
		add(watchNuts);

		glowDark = new FunkinSprite(-300, 330).loadTexture('ui/freeplay/backingCard/beatglow');
		glowDark.blend = MULTIPLY;
		add(glowDark);

		glow = new FunkinSprite(-300, 330).loadTexture('ui/freeplay/backingCard/beatglow');
		glow.blend = ADD;
		add(glow);
	}

	override public function startIntroTween():Void
	{
		super.startIntroTween();

		orangeBack.visible = false;
		orangeBackTwo.visible = false;

		for (grp in [moreWayss, funnyScrolls])
		{
			for (spr in grp)
			{
				spr.visible = false;
			}
		}
		watchNuts.visible = false;

		glow.visible = false;
		glowDark.visible = false;
	}

	override public function introDone():Void
	{
		super.introDone();

		orangeBack.visible = true;
		orangeBackTwo.visible = true;
		cardGlow.visible = true;

		for (grp in [moreWayss, funnyScrolls])
		{
			for (spr in grp)
			{
				spr.visible = true;
			}
		}
		watchNuts.visible = true;

		glow.visible = true;
		glowDark.visible = true;

		FlxTween.tween(cardGlow, {alpha: 0, "scale.x": 1.2, "scale.y": 1.2}, 0.45, {ease: FlxEase.sineOut});
	}

	override public function confirm():Void
	{
		super.confirm();

		for (grp in [moreWayss, funnyScrolls])
		{
			for (spr in grp)
			{
				spr.visible = false;
			}
		}
		watchNuts.visible = false;

		glow.visible = false;
		glowDark.visible = false;

		orangeBack.visible = false;
		orangeBackTwo.visible = false;

		confirmGlow.visible = true;
		confirmGlowTwo.visible = true;
		confirmGlow.alpha = 0;
		confirmGlowTwo.alpha = 0;

		FlxTween.color(instance.bgDad, 0.5, 0xFFA8A8A8, 0xFF646464, {
			onUpdate: function(_)
			{
				instance.angleMaskShader.extraColor = instance.bgDad.color;
			}
		});

		FlxTween.tween(confirmGlowTwo, {alpha: 0.5}, 0.33, {
			ease: FlxEase.quadOut,
			onComplete: (_) ->
			{
				confirmGlow.alpha = 1;
				confirmGlowTwo.alpha = 0.6;

				confirmTextGlow.visible = true;
				confirmTextGlow.alpha = 1;
				FlxTween.tween(confirmTextGlow, {alpha: 0.4}, 0.5);
				FlxTween.tween(confirmGlow, {alpha: 0}, 0.5);
				FlxTween.color(instance.bgDad, 2, 0xFFCDCDCD, 0xFF555555, {
					ease: FlxEase.expoOut,
					onUpdate: function(_)
					{
						instance.angleMaskShader.extraColor = instance.bgDad.color;
					}
				});
			}
		});
	}

	override public function exit():Void
	{
		for (grp in [moreWayss, funnyScrolls])
		{
			for (spr in grp)
			{
				spr.visible = true;
			}
		}
		watchNuts.visible = true;
	}

	var beatFreqList:Array<Int> = [1, 2, 4, 8];

	override public function beatHit():Void
	{
		var beatFreq:Int = beatFreqList[Math.floor(instance.conductor.bpm / 140)];

		if (instance.conductor.curBeat % beatFreq != 0)
			return;

		FlxTween.cancelTweensOf(glow);
		FlxTween.cancelTweensOf(glowDark);

		glow.alpha = 0.8;
		FlxTween.tween(glow, {alpha: 0}, 16 / 24, {ease: FlxEase.quartOut});
		glowDark.alpha = 0;
		FlxTween.tween(glowDark, {alpha: 0.6}, 18 / 24, {ease: FlxEase.quartOut});
	}
}
