package funkin.ui.options;

import flixel.FlxCamera;
import funkin.ui.Alphabet;
import funkin.ui.menu.MenuState;
import funkin.ui.options.OptionMenuData;

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
          id: 'downScroll',
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

  static var curSelectedCategory:Int = 0;

  var curSelectedOption:Int = 0;

  /**
   * The current status for `OptionsState`.
   */
  public var currentStatus:OptionStatus = CATEGORY;

  var categoryCamera:FlxCamera;

  var categoryArrow:FlxSprite = null;
  var categoryGroup:FunkinSpriteGroup = null;

  var categoryName:Alphabet = null;
  var categoryDescription:Alphabet = null;

  var optionsCamera:FlxCamera;

  var checkboxGroup:FlxTypedGroup<OptionCheckbox>;

  override public function create():Void
  {
    #if FUNKIN_DISCORD_RPC
    DiscordRPC.details = 'Options Menu';
    #end

    #if FLX_MOUSE
    FlxG.mouse.visible = true;
    #end

    categoryCamera = new FlxCamera(0, 5);
    categoryCamera.bgColor = 0x0;
    FlxG.cameras.add(categoryCamera, false);

    optionsCamera = new FlxCamera();
    optionsCamera.bgColor = 0x0;
    FlxG.cameras.add(optionsCamera, false);

    var bg:FunkinSprite = new FunkinSprite().loadTexture('ui/menu/menuBGYellow');
    bg.screenCenter();
    bg.active = false;
    add(bg);

    categoryArrow = new FunkinSprite().loadTexture('ui/options/arrow');
    categoryArrow.cameras = [categoryCamera];
    add(categoryArrow);

    categoryGroup = new FunkinSpriteGroup();
    categoryGroup.cameras = [categoryCamera];
    add(categoryGroup);

    var fullWidth:Float = 0;
    for (i => category in categories)
    {
      var categoryObj:FunkinSprite = new FunkinSprite(fullWidth).loadFrames('ui/options/categories/' + category.id);
      categoryObj.addAnimation('idle', category.id + ' idle');
      categoryObj.addAnimation('hovered', category.id + ' hovered');
      categoryObj.playAnimation('idle');
      fullWidth += categoryObj.width;
      categoryGroup.add(categoryObj);
    }

    var nextXPos:Float = MathUtil.center(FlxG.width, fullWidth);
    for (i => spr in categoryGroup.members)
    {
      spr.x = nextXPos;
      nextXPos += spr.width;
    }

    categoryArrow.y = categoryGroup.members[0].y + categoryGroup.members[0].height;
    categoryCamera.height = Std.int(categoryArrow.y + categoryArrow.height);

    categoryName = new Alphabet(0, 269, '', FlxG.width, "bold");
    categoryName.alignment = CENTER;
    add(categoryName);

    categoryDescription = new Alphabet(0, 456, '', FlxG.width, "default");
    categoryDescription.scale.set(0.7, 0.7);
    categoryDescription.alignment = CENTER;
    add(categoryDescription);

    super.create();

    changeCategory();

    categoryArrow.x = lerpXPosArrow;
  }

  var lerpXPosArrow:Float = 0;

  override public function update(elapsed:Float):Void
  {
    switch (currentStatus)
    {
      case CATEGORY:
        if (controls.waitAndRepeat().UI_LEFT)
          changeCategory(-1);

        if (controls.waitAndRepeat().UI_RIGHT)
          changeCategory(1);

        if (controls.justPressed.ACCEPT)
          openCategory();

        #if FLX_MOUSE
        for (i => category in categoryGroup.members)
        {
          if (FlxG.mouse.overlaps(category, categoryCamera) && FlxG.mouse.justPressed)
          {
            if (curSelectedCategory != i)
            {
              curSelectedCategory = i;
              FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));
              changeCategory();
            }
            else
            {
              openCategory();
            }
          }
        }
        #end

        if (controls.justPressed.BACK)
        {
          #if FLX_MOUSE
          FlxG.mouse.visible = false;
          #end
          currentStatus = STUNNED;

          FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
          FlxG.switchState(MenuState.new);
        }

        categoryArrow.x = MathUtil.coolLerp(categoryArrow.x, lerpXPosArrow, 0.3);
      case OPTIONS:
        if (controls.waitAndRepeat().UI_UP)
          changeOption(-1);

        if (controls.waitAndRepeat().UI_DOWN)
          changeOption(1);

        if (controls.justPressed.BACK)
        {
          FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));

          playCategoryTweens(false);
          currentStatus = CATEGORY;
        }
      default:
    }

    super.update(elapsed);
  }

  function changeCategory(?indexHop:Int = 0):Void
  {
    curSelectedCategory = FlxMath.wrap(curSelectedCategory + indexHop, 0, categories.length - 1);

    if (indexHop != 0)
      FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));

    for (spr in categoryGroup.members)
      spr.alpha = 0.6;

    categoryName.text = categories[curSelectedCategory].name;
    categoryDescription.text = categories[curSelectedCategory].description;

    categoryGroup.members[curSelectedCategory].alpha = 1;
    lerpXPosArrow = categoryGroup.members[curSelectedCategory].getGraphicMidpoint().x - (categoryArrow.width / 2);
  }

  function openCategory():Void
  {
    currentStatus = OPTIONS;
    playCategoryTweens(true);
    generateCategoryOptions();
  }

  function playCategoryTweens(gone:Bool):Void
  {
    var alphaValue:Float = (gone) ? 0 : 1;

    var cameraY:Float = (gone) ? -90 : 5;
    var cameraZoom:Float = (gone) ? 0.2 : 1;

    FlxTween.cancelTweensOf(categoryName);
    FlxTween.tween(categoryName, {alpha: alphaValue}, 0.3);

    FlxTween.cancelTweensOf(categoryDescription);
    FlxTween.tween(categoryDescription, {alpha: alphaValue}, 0.3);

    FlxTween.cancelTweensOf(categoryCamera);
    FlxTween.tween(categoryCamera, {y: cameraY, zoom: cameraZoom}, 0.4, {ease: FlxEase.expoInOut});

    categoryArrow.x = lerpXPosArrow; // just in case
  }

  function generateCategoryOptions():Void
  {
    var curCategoryObj:OptionCategory = categories[curSelectedCategory];

    for (option in curCategoryObj.options)
    {
      trace(option);
    }
  }

  function changeOption(?indexHop:Int = 0):Void
  {
    curSelectedOption = FlxMath.wrap(curSelectedOption + indexHop, 0, categories[curSelectedCategory].options.length - 1);

    if (indexHop != 0)
      FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));
  }
}

enum OptionStatus
{
  /**
   * Selecting categories.
   */
  CATEGORY;

  /**
   * Editing options.
   */
  OPTIONS;

  /**
   * Currently stunned.
   * This will disable all input until status is changed.
   */
  STUNNED;
}
