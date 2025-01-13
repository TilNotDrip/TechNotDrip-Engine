package funkin.states.ui;

import funkin.objects.ui.Alphabet;
import funkin.substates.FunkinTransition;
import haxe.xml.Access;

/**
 * The Title Screen.
 *
 * This state shows some quick credits and a press enter to begin.
 *
 * This is also the first state that the player sees.
 */
class TitleState extends FunkinState
{
	/**
	 * Whether the player has already seen the intro.
	 *
	 * This affects whether or not to show the player the opening credits.
	 */
	public static var seenIntro:Bool = false;

	/**
	 * The text data for the intro.
	 */
	public var introText:Access = null;

	/**
	 * The newgrounds logo that shows up mid intro.
	 */
	public var ngSpr:FlxSprite = null;

	/**
	 * The logo that bumps on beat hit after the intro is done.
	 */
	public var logoBumpin:FlxSprite = null;

	/**
	 * The Girlfriend bopping on beat hit after the intro is done.
	 */
	public var gfDance:FlxSprite = null;

	/**
	 * The "Press Enter to Begin" object that shows up after the intro is done.
	 */
	public var enterSpr:FlxSprite = null;

	var textGroup:FlxTypedGroup<Alphabet> = null;

	var curRandomText:Array<String> = [];

	override public function create():Void
	{
		Paths.content.cache.clear();

		if (FlxG.sound.music == null)
		{
			conductor.bpm = 102;
			FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
		}

		FunkinTransition.skipNextTransitionOut = true;

		#if FUNKIN_DISCORD_RPC
		DiscordRPC.details = 'Title Screen';
		DiscordRPC.state = 'Watching Intro';
		#end

		initPostIntroObjects();

		if (!seenIntro)
			initIntroObjects();
		else
			skipIntro();

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		if (controls.BACK && !transitioning)
		{
			SystemUtil.close();
		}

		conductor.update();

		super.update(elapsed);

		if (!seenIntro)
		{
			handleIntroUpdate();
		}
		else
		{
			handlePostIntroUpdate();
		}
	}

	override public function destroy():Void
	{
		Paths.content.cache.removeImage(Paths.location.image('ui/title/logoBumpin'));
		Paths.content.cache.removeImage(Paths.location.image('ui/title/gfDanceTitle'));
		Paths.content.cache.removeImage(Paths.location.image('ui/title/titleEnter'));

		if (ngSpr != null)
			Paths.content.cache.removeImage(ngSpr.graphic.key);

		super.destroy();
	}

	function initIntroObjects():Void
	{
		try
		{
			introText = new Access(Paths.content.xml('ui/title/introText'));
			introText = introText.node.introText;
		}
		catch (e:Exception)
		{
			trace('[WARNING]: introText data is invalid! (${e.toString()})');
		}

		getRandomIntroText();

		textGroup = new FlxTypedGroup<Alphabet>();
		add(textGroup);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52);

		if (FlxG.random.bool(1))
		{
			ngSpr.loadGraphic(Paths.content.imageGraphic('ui/title/newgrounds_logo_classic'));
		}
		else if (FlxG.random.bool(30))
		{
			ngSpr.loadGraphic(Paths.content.imageGraphic('ui/title/newgrounds_logo_animated'), true, 600);
			ngSpr.animation.add('idle', [0, 1], 4);
			ngSpr.animation.play('idle');
			ngSpr.setGraphicSize(Math.floor(ngSpr.width * 0.55));
			ngSpr.y += 25;
		}
		else
		{
			ngSpr.loadGraphic(Paths.content.imageGraphic('ui/title/newgrounds_logo'));
			ngSpr.setGraphicSize(Math.floor(ngSpr.width * 0.8));
		}

		ngSpr.visible = false;
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		add(ngSpr);
	}

	function initPostIntroObjects():Void
	{
		logoBumpin = new FlxSprite(-150 + 116, -100 + 106);
		logoBumpin.frames = Paths.content.sparrowAtlas('ui/title/logoBumpin');
		logoBumpin.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBumpin.animation.play('bump');
		logoBumpin.updateHitbox();
		logoBumpin.visible = false;
		add(logoBumpin);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.content.sparrowAtlas('ui/title/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
		gfDance.updateHitbox();
		gfDance.visible = false;
		add(gfDance);

		enterSpr = new FlxSprite(0, FlxG.height * 0.8);
		enterSpr.frames = Paths.content.sparrowAtlas('ui/title/titleEnter');
		enterSpr.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		enterSpr.animation.addByPrefix('press', "ENTER PRESSED", 24);
		enterSpr.animation.play('idle');
		enterSpr.updateHitbox();
		enterSpr.screenCenter(X);
		enterSpr.visible = false;
		add(enterSpr);
	}

	function getRandomIntroText():Void
	{
		var randomArray:Array<Array<String>> = [];
		var randomTexts:Access = introText.node.randomTexts;

		for (text in randomTexts.nodes.text)
		{
			randomArray.push(parseXMLInnerDataArray(text.innerData));
		}

		curRandomText = FlxG.random.getObject(randomArray);
	}

	function handleIntroUpdate():Void
	{
		if (controls.ACCEPT)
		{
			skipIntro();
		}
	}

	var transitioning:Bool = false;
	var enterTimer:FlxTimer;

	function handlePostIntroUpdate():Void
	{
		// Maybe make a FlxSkipableTimer?
		// TODO: Make this work
		/*if (enterTimer != null && !enterTimer.finished && controls.ACCEPT)
			{
				enterTimer.cancel();
				enterTimer.onComplete(null);
		}*/

		if (controls.ACCEPT && !transitioning)
		{
			if (enterSpr != null && enterSpr.animation != null)
			{
				enterSpr.animation.play('press', true);
			}

			FlxG.sound.play(Paths.content.audio('ui/menu/confirmMenu'), 0.7);

			enterTimer = new FlxTimer().start(2, (tmr:FlxTimer) ->
			{
				FlxG.switchState(MenuState.new);
			});

			transitioning = true;
		}
	}

	function skipIntro():Void
	{
		#if FUNKIN_DISCORD_RPC
		DiscordRPC.state = null; // Maybe add something here?
		#end

		if (Save.instance.options.flashingLights)
		{
			FlxG.camera.flash(0xFFFFFFFF, seenIntro ? 1 : 4);
		}

		for (spr in [logoBumpin, gfDance, enterSpr])
		{
			if (spr != null)
			{
				spr.visible = true;
			}
		}

		if (textGroup != null)
		{
			textGroup.destroy();
		}

		if (ngSpr != null && ngSpr.visible)
		{
			ngSpr.visible = false;
		}

		seenIntro = true;
	}

	override public function beatHit():Void
	{
		if (!seenIntro)
		{
			handleIntroBeatHit();
		}
		else
		{
			handlePostIntroBeatHit();
		}

		super.beatHit();
	}

	function handleIntroBeatHit():Void
	{
		var displayText:Access = introText.node.displayText;

		for (access in displayText.nodes.text)
		{
			if (!access.has.beat || access.att.beat != Std.string(conductor.curBeat))
				continue;

			var textArray:Array<String> = parseXMLInnerDataArray(access.innerData);

			addTextToGroup(textArray);
		}

		for (access in displayText.nodes.deleteText)
		{
			if (!access.has.beat || access.att.beat != Std.string(conductor.curBeat))
				continue;

			deleteAllText();

			if (ngSpr.visible)
				ngSpr.visible = false;
		}

		for (access in displayText.nodes.showNgSpr)
		{
			if (!access.has.beat || access.att.beat != Std.string(conductor.curBeat))
				continue;

			if (!ngSpr.visible)
				ngSpr.visible = true;
		}

		for (access in displayText.nodes.hideNgSpr)
		{
			if (!access.has.beat || access.att.beat != Std.string(conductor.curBeat))
				continue;

			if (!ngSpr.visible)
				ngSpr.visible = false;
		}

		for (access in displayText.nodes.randomText)
		{
			if (!access.has.beat || access.att.beat != Std.string(conductor.curBeat) || !access.has.line)
				continue;

			var line:Int = Std.parseInt(access.att.line) - 1;

			addTextToGroup([curRandomText[line]]);
		}

		for (access in displayText.nodes.finishIntro)
		{
			if (!access.has.beat || access.att.beat != Std.string(conductor.curBeat))
				continue;

			skipIntro();
		}
	}

	function addTextToGroup(textArray:Array<String>):Void
	{
		if (textGroup == null)
			return;

		var curY:Float = 200 + (textGroup.length * 60);

		for (i in 0...textArray.length)
		{
			var text:Alphabet = new Alphabet(0, 0, textArray[i], BOLD);
			text.screenCenter(X);
			text.y = curY + (i * 60);
			textGroup.add(text);
		}
	}

	function deleteAllText():Void
	{
		if (textGroup == null)
			return;

		while (textGroup.members.length > 0)
		{
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var gfHasDancedLeft:Bool = false;

	function handlePostIntroBeatHit():Void
	{
		gfHasDancedLeft = !gfHasDancedLeft;

		if (logoBumpin != null && logoBumpin.animation != null)
		{
			logoBumpin.animation.play('bump', true);
		}

		if (gfDance != null && gfDance.animation != null)
		{
			gfDance.animation.play('${gfHasDancedLeft ? 'danceLeft' : 'danceRight'}', true);
		}
	}

	function parseXMLInnerDataArray(innerData:String):Array<String>
	{
		var theTexts:Array<String> = innerData.split('\n');

		for (i in 0...theTexts.length)
		{
			theTexts[i] = theTexts[i].trim();
		}

		theTexts = theTexts.filter((f:String) ->
		{
			return f != '';
		});

		return theTexts;
	}
}
