package funkin.states.ui;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.util.typeLimit.NextState;
import funkin.macros.GitDefines;
import funkin.substates.FunkinTransition;

class MenuState extends FunkinState
{
	public static var curSelected:Int = 0;

	// Maybe move to config file?
	public static var menuItems:Array<MenuItem> = [
		{
			id: 'storymode',
			name: 'Story Mode',
			classToSwitch: StoryState.new
		},
		{
			id: 'freeplay',
			name: 'Freeplay',
			classToSwitch: FreeplayState.new
		},
		{
			id: 'credits',
			name: 'Credits',
			classToSwitch: null
		},
		{
			id: 'merch',
			name: 'Merch',
			website: 'https://needlejuicerecords.com/en-ca/collections/friday-night-funkin'
		},
		{
			id: 'options',
			name: 'Options',
			classToSwitch: null
		}
	];

	var camFollow:FlxObject = null;

	var menuItemGroup:FlxTypedGroup<FunkinSprite> = null;

	var selected:Bool = false;

	override public function create():Void
	{
		if (FlxG.sound.music == null)
		{
			conductor.bpm = 102;
			FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
		}

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		#if FUNKIN_DISCORD_RPC
		DiscordRPC.details = 'Main Menu';
		#end

		var bg:FunkinSprite = new FunkinSprite().loadTexture('ui/menu/menuBGYellow');
		bg.scrollFactor.set(0, 0.17);
		bg.setGraphicSize(Math.floor(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.active = false;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItemGroup = new FlxTypedGroup<FunkinSprite>();
		add(menuItemGroup);

		var fnfWatermark:FlxText = new FlxText(5, FlxG.height - 18, 0, 'Based on Friday Night Funkin\' v' + Constants.FNF_VERSION, 12);
		fnfWatermark.setFormat(Paths.location.get('ui/fonts/vcr.ttf'), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		fnfWatermark.scrollFactor.set();
		add(fnfWatermark);

		var tndWatermark:FlxText = new FlxText(-5, FlxG.height - 18, FlxG.width, 'TechNotDrip Engine v${Constants.TECHNOTDRIP_VERSION}', 12);
		tndWatermark.setFormat(Paths.location.get('ui/fonts/vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tndWatermark.scrollFactor.set();
		add(tndWatermark);

		#if FUNKIN_GIT_DETAILS
		tndWatermark.text += ((Constants.GIT_MODIFIED ? '*' : ''))
			+ ' ['
			+ Constants.GIT_BRANCH.toUpperCase()
			+ '] ['
			+ Constants.GIT_HASH_SPLICED
			+ ']';
		#end

		super.create();

		generateMenuItems();
		changeItem();

		FlxG.camera.follow(camFollow, null, 0.06);
		FlxG.camera.snapToTarget();
	}

	override public function update(elapsed:Float):Void
	{
		if (controls.UI_UP_P && !selected)
			changeItem(-1);

		if (controls.UI_DOWN_P && !selected)
			changeItem(1);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
			FlxG.switchState(TitleState.new);
		}

		if (controls.ACCEPT && !selected)
		{
			selected = true;
			FlxG.sound.play(Paths.content.audio('ui/menu/confirmMenu'));

			menuItemGroup.forEach((item:FunkinSprite) ->
			{
				if (curSelected == menuItemGroup.members.indexOf(item))
				{
					if (Save.instance.options.flashingLights)
					{
						FlxFlicker.flicker(item, 1, 0.06, false, false);
					}
				}
				else
				{
					FlxTween.tween(item, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut
					});
				}
			});

			new FlxTimer().start(1, (tmr:FlxTimer) ->
			{
				if (menuItems[curSelected].website != null)
					SystemUtil.openURL(menuItems[curSelected].website);

				if (menuItems[curSelected].classToSwitch != null)
					FlxG.switchState(menuItems[curSelected].classToSwitch);
				else
				{
					FunkinTransition.skipNextTransitionIn = true;
					FunkinTransition.skipNextTransitionOut = true;
					FlxG.resetState();
				}
			});
		}

		super.update(elapsed);
	}

	/**
	 * Generates the Menu Items.
	 */
	public function generateMenuItems():Void
	{
		if (menuItemGroup != null)
		{
			menuItemGroup.forEach((spr:FunkinSprite) ->
			{
				spr.destroy();
				menuItemGroup.remove(spr, true);
			});
		}

		var spacing:Float = 160;
		var top:Float = (FlxG.height - (spacing * (menuItems.length - 1))) / 2;

		for (i => item in menuItems)
		{
			var itemSpr:FunkinSprite = new FunkinSprite(0, top + (spacing * i));
			itemSpr.loadFrames('ui/menu/items/' + item.id);
			itemSpr.addAnimation('idle', item.id + ' idle', [], 30, true);
			itemSpr.addAnimation('selected', item.id + ' selected', [], 30, true);
			itemSpr.playAnimation('idle');
			itemSpr.updateHitbox();
			itemSpr.x = FlxG.width / 2;
			menuItemGroup.add(itemSpr);
		}
	}

	function changeItem(?indexHop:Int = 0):Void
	{
		curSelected += indexHop;

		if (curSelected > menuItems.length - 1)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if (indexHop != 0)
			FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));

		menuItemGroup.forEach((item:FunkinSprite) ->
		{
			if (menuItemGroup.members.indexOf(item) == curSelected)
			{
				camFollow.setPosition(FlxG.width / 2, item.getGraphicMidpoint().y);
				item.animation.play('selected', true);
			}
			else
				item.animation.play('idle', true);

			item.updateHitbox();
			item.centerOrigin();
			item.offset.copyFrom(item.origin);
		});

		#if FUNKIN_DISCORD_RPC
		DiscordRPC.state = 'Has ' + menuItems[curSelected].name + ' selected';
		#end
	}
}

typedef MenuItem =
{
	var id:String;
	var name:String;
	@:optional var classToSwitch:NextState;
	@:optional var website:String;
}
