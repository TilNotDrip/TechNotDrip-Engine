package funkin.states.ui;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.typeLimit.NextState;
import flixel.text.FlxText;

class MenuState extends FunkinState
{
	public static var curSelected:Int = 0;

	public static var menuItems:Array<MenuItem> = [
		{
			id: 'storymode',
			classToSwitch: null
		},
		{
			id: 'freeplay',
			classToSwitch: null
		},
		{
			id: 'credits',
			classToSwitch: null
		},
		{
			id: 'merch',
			website: 'https://needlejuicerecords.com/en-ca/collections/friday-night-funkin'
		},
		{
			id: 'options',
			classToSwitch: null
		}
	];

	var camFollow:FlxObject = null;

	var menuItemGroup:FlxTypedGroup<FlxSprite> = null;

	var selected:Bool = false;

	override public function create():Void
	{
		if (FlxG.sound.music != null)
		{
			conductor.bpm = 102;
			FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
		}

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		var bg:FlxSprite = new FlxSprite(Paths.content.imageGraphic('ui/menu/menuBGYellow'));
		bg.scrollFactor.set(0, 0.17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItemGroup = new FlxTypedGroup<FlxSprite>();
		add(menuItemGroup);
		
		var leftWatermarkText:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, '', 12);
        var rightWatermarkText:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, '', 12);

        leftWatermarkText.scrollFactor.set(0, 0);
        rightWatermarkText.scrollFactor.set(0, 0);
        leftWatermarkText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        rightWatermarkText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        // TODO: move the version numbers to a variable, im just too lazy rn
        leftWatermarkText.text = "Friday Night Funkin' v0.4";
        rightWatermarkText.text = "TechNotDrip Engine v0.1 [ALPHA]";

        add(leftWatermarkText);
        add(rightWatermarkText);
  }

		super.create();

		generateMenuItems();
		changeItem();

		FlxG.camera.follow(camFollow, null, 0.06);
		FlxG.camera.snapToTarget();
	}

	override public function update(elapsed:Float):Void
	{
		if (FlxG.keys.justPressed.UP && !selected)
			changeItem(-1);

		if (FlxG.keys.justPressed.DOWN && !selected)
			changeItem(1);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(TitleState.new);

		if (FlxG.keys.justPressed.ENTER && !selected)
		{
			selected = true;
			FlxG.sound.play(Paths.content.audio('ui/menu/confirmMenu'));

			menuItemGroup.forEach((item:FlxSprite) ->
			{
				if (curSelected == menuItemGroup.members.indexOf(item))
				{
					// TODO: CHANGE THIS TO FLASHING LIGHTS WHEN IT EXISTS!
					if (true)
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

			new FlxTimer().start(1, (_) ->
			{
				if (menuItems[curSelected].website != null)
					FlxG.openURL(menuItems[curSelected].website);

				if (menuItems[curSelected].classToSwitch != null)
					FlxG.switchState(menuItems[curSelected].classToSwitch);
				else
				{
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					FlxG.resetState();
				}
			});
		}

		super.update(elapsed);
	}

	public function generateMenuItems():Void
	{
		if (menuItemGroup != null)
		{
			menuItemGroup.forEach((spr:FlxSprite) ->
			{
				spr.destroy();
				menuItemGroup.remove(spr, true);
			});
		}

		var spacing:Float = 160;
		var top:Float = (FlxG.height - (spacing * (menuItems.length - 1))) / 2;
		for (i => item in menuItems)
		{
			var itemSpr:FlxSprite = new FlxSprite(0, top + (spacing * i));
			itemSpr.frames = Paths.content.sparrowAtlas('ui/menu/items/' + item.id);
			itemSpr.animation.addByPrefix('idle', item.id + ' idle');
			itemSpr.animation.addByPrefix('selected', item.id + ' selected');
			itemSpr.animation.play('idle');
			itemSpr.updateHitbox();
			itemSpr.x = FlxG.width / 2;
			menuItemGroup.add(itemSpr);
		}
	}

	public function changeItem(?indexHop:Int = 0):Void
	{
		curSelected += indexHop;

		if (curSelected > menuItems.length - 1)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = menuItems.length - 1;

		if (indexHop != 0)
			FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));

		menuItemGroup.forEach(function(item:FlxSprite)
		{
			if (curSelected == menuItemGroup.members.indexOf(item))
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
	}
}

typedef MenuItem =
{
	var id:String;
	@:optional var classToSwitch:NextState;
	@:optional var website:String;
}
