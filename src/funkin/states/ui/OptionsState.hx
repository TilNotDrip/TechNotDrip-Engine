package funkin.states.ui;

import funkin.objects.ui.Alphabet;
import funkin.structures.OptionMenuStructure;

class OptionsState extends FunkinState
{
	static final categories:Array<OptionCategory> = [
		{
			id: 'graphics',
			name: 'Graphics',
			description: 'Adjusting your game graphics for either performance or quality.',
			options: [
				{
					id: 'fps',
					name: 'FPS Limit',
					description: "How much frames should the game run at?",
					type: SLIDER
				},
				{
					id: 'fullscreen',
					name: 'Fullscreen',
					description: "Whether the game should be displayed in fullscreen or not.",
					type: CHECKBOX
				},
				{
					id: 'antialiasing',
					name: 'Antialiasing',
					description: "Whether the edges of graphics should be smoothened out or not.\nCan have an impact on low-end devices.",
					type: CHECKBOX
				},
				{
					id: 'flashingLights',
					name: 'Flashing Lights',
					description: "Whether some sections of the game display flickering flashing lights or not.\nRecommened to leave off if you have ",
					type: CHECKBOX
				},
				{
					id: 'showFps',
					name: 'Show FPS',
					description: "Whether to show the FPS on the top left corner of your game or not.",
					type: CHECKBOX
				},
				{
					id: 'showRAM',
					name: 'Show RAM',
					description: "Whether to show the RAM on the top left corner of your game or not.",
					type: CHECKBOX
				},
				{
					id: 'ramLimit',
					name: 'RAM Limit',
					description: "How much RAM the game can go up to.",
					type: SLIDER
				},
				{ // TODO: read the description dumbass
					id: 'cachingOptions',
					name: 'Caching Options',
					description: "//TODO: Add a type that expands the options when interacted with.",
					type: SELECTION
				}
			]
		},
		{
			id: 'gameplay',
			name: 'Gameplay',
			description: 'Adjusting your in-game experience to your liking.',
			options: [
				{
					id: 'downscroll',
					name: 'Downscroll',
					description: "Whether notes should go up to down, or down to up.",
					type: CHECKBOX
				},
				{
					id: 'middlescroll',
					name: 'Middlescroll',
					description: "Whether the strumline should be centered or not.",
					type: CHECKBOX
				},
				{
					id: 'ghostTapping',
					name: 'Ghost Tapping',
					description: "Whether hitting a note keybind punishes you or not.",
					type: CHECKBOX
				},
				{
					id: 'cameraZoom',
					name: 'Camera Zoom',
					description: "Whether the camera bops or not.",
					type: CHECKBOX
				},
				{
					id: 'noteSplashes',
					name: 'Note Splashes',
					description: "Whether a splash plays on the strums on a good enough rating or not.",
					type: SELECTION
				}
			]
		},
		{
			id: 'audio',
			name: 'Audio',
			description: 'Adjusting the audio of your game so its not too loud but not too low either.',
			options: []
		},
		{
			id: 'controls',
			name: 'Controls',
			description: 'Customizing your controls for menu use or in-game.',
			options: [
				{ // TODO: read dumbass
					id: '',
					name: 'TODO',
					description: "Make a way to send you to a state. Also make control options. guys we should just be different and have control settings in here too like Disable Reset key in-game????? liek !!!!!!",
					type: SELECTION
				}
			]
		},
		{
			id: 'developer',
			name: 'Developer',
			description: 'Access to settings that would help you for developing a mod for this engine.',
			options: [
				{
					id: 'devMode',
					name: 'Developer Mode',
					description: "Whether the game should enable debug logs, key combos, etc.",
					type: CHECKBOX
				},
				{
					id: 'safeMode',
					name: 'Safe Mode',
					description: "Whether the game should block potentially malicious scripts or not.",
					type: CHECKBOX
				}
			]
		},
		{
			id: 'misc',
			name: 'Misc',
			description: 'Variety of options that wouldn\'t go in any other category.',
			options: [
				{
					id: 'systemCursor',
					name: 'System Cursor',
					description: "Whether the game should use the system cursor instead of using the default flixel one.",
					type: CHECKBOX
				},
				{
					id: 'autoPause',
					name: 'Auto Pause',
					description: "Whether the game should pause the game when you tab out or not.",
					type: CHECKBOX
				}
			]
		}
	];

	static var curSelected:Int = 0;

	var categoryArrow:FlxSprite = null;

	var categoryName:Alphabet = null;

	var categoryDescription:Alphabet = null;

	var categoryGroup:FunkinSpriteGroup = null;

	override public function create():Void
	{
		#if FUNKIN_DISCORD_RPC
		DiscordRPC.details = 'Options Menu';
		#end

		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end

		var bg:FunkinSprite = new FunkinSprite().loadTexture('ui/menu/menuBGYellow');
		bg.screenCenter();
		bg.active = false;
		add(bg);

		categoryArrow = new FunkinSprite().loadTexture('ui/options/arrow');
		add(categoryArrow);

		categoryName = new Alphabet(456, 269, '', BOLD);
		add(categoryName);

		categoryDescription = new Alphabet(0, 456, '', DEFAULT);
		categoryDescription.scale.set(0.7, 0.7);
		categoryDescription.updateHitbox();
		add(categoryDescription);

		categoryGroup = new FunkinSpriteGroup(0, 5);
		add(categoryGroup);

		var fullWidth:Float = 0;
		var centerXPos:Float = 0;
		for (i => category in categories)
		{
			var categoryObj:FunkinSprite = new FunkinSprite().loadFrames('ui/options/categories/' + category.id);
			categoryObj.addAnimation('idle', category.id + ' idle');
			categoryObj.addAnimation('hovered', category.id + ' hovered');
			categoryObj.playAnimation('idle');
			fullWidth += categoryObj.width;
			categoryGroup.add(categoryObj);
		}

		centerXPos = (FlxG.width - fullWidth) / 2;

		for (i => spr in categoryGroup.members)
			spr.x = centerXPos + ((categoryGroup.members[i - 1]?.x ?? 0) + (categoryGroup.members[i - 1]?.width ?? 0));

		categoryArrow.y = categoryGroup.members[0].y + categoryGroup.members[0].height;

		super.create();

		changeOptionCategory();

		categoryArrow.x = lerpXPosArrow;
	}

	var lerpXPosArrow:Float = 0;

	override public function update(elapsed:Float):Void
	{
		if (controls.UI_LEFT_P)
			changeOptionCategory(-1);

		if (controls.UI_RIGHT_P)
			changeOptionCategory(1);

		#if FLX_MOUSE
		for (i => category in categoryGroup.members)
		{
			if (FlxG.mouse.overlaps(category) && FlxG.mouse.justPressed)
			{
				curSelected = i;
				changeOptionCategory();
			}
		}
		#end

		if (controls.BACK)
		{
			#if FLX_MOUSE
			FlxG.mouse.visible = false;
			#end

			FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
			FlxG.switchState(MenuState.new);
		}

		super.update(elapsed);

		categoryArrow.x = MathUtil.coolLerp(categoryArrow.x, lerpXPosArrow, 0.3);
	}

	function changeOptionCategory(?indexHop:Int = 0):Void
	{
		curSelected += indexHop;

		if (curSelected > categories.length - 1)
			curSelected = 0;
		else if (curSelected < 0)
			curSelected = categories.length - 1;

		if (indexHop != 0)
			FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));

		for (spr in categoryGroup.members)
			spr.alpha = 0.6;

		categoryName.text = categories[curSelected].name;
		categoryDescription.text = categories[curSelected].description;

		categoryGroup.members[curSelected].alpha = 1;
		lerpXPosArrow = categoryGroup.members[curSelected].getGraphicMidpoint().x - (categoryArrow.width / 2);
	}
}
