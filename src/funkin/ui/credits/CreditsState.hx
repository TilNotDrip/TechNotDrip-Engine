package funkin.ui.credits;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.util.FlxSpriteUtil;
import funkin.ui.Alphabet;
import funkin.ui.menu.MenuState;
import haxe.Http;
import haxe.Json;
import haxe.ds.StringMap;
import haxe.xml.Access;
#if FUNKIN_GIT_DETAILS
import funkin.util.macro.GitContributorMacro;
#end

class CreditsState extends FunkinState
{
  /**
   * The bubble X position.
   */
  public static final BUBBLE_X_POS:Float = 285;

  /**
   * The bubble Y position when selected.
   */
  public static final BUBBLE_Y_POS:Float = 40;

  /**
   * The bubble Y distance.
   */
  public static final BUBBLE_DISTANCE_Y:Float = 605;

  /**
   * The bubble width.
   */
  public static final BUBBLE_WIDTH:Int = 966;

  /**
   * The bubble height.
   */
  public static final BUBBLE_HEIGHT:Int = 588;

  /**
   * The arrow X position.
   */
  public static final ARROW_X:Float = 40;

  /**
   * The arrow Y position for top.
   */
  public static final ARROW_Y_TOP:Float = 8;

  /**
   * The arrow Y position for top.
   */
  public static final ARROW_Y_BOTTOM:Float = 620;

  /**
   * The icon Y.
   */
  public static final ICON_Y:Float = 100;

  /**
   * The icon distance.
   */
  public static final ICON_DISTANCE:Float = 15;

  #if FUNKIN_GIT_DETAILS
  /**
   * Percentage of commits done per contributor.
   */
  public static final CONTRIBUTOR_PERCENTAGES:Map<String, Float> = GitContributorMacro.percentages();
  #end

  /**
   * The current item selected.
   */
  public var curSelected:Int = 0;

  /**
   * The user data. Called bubble data cuz I said so.
   */
  public var bubbleData:Array<BubbleData>;

  /**
   * The group where all the bubbles are.
   */
  public var bubbleGroup:FlxTypedGroup<CreditsBubble>;

  /**
   * The camera where all the icons are.
   */
  public var iconCamera:FlxCamera;

  /**
   * The variable to tell `iconCamera` to lerp to.
   */
  public var iconCameraYLerp:Float = 0;

  /**
   * An array with all the icons.
   */
  public var icons:Array<FunkinSprite> = [];

  /**
   * The top arrow.
   */
  public var arrowUp:FunkinSprite;

  /**
   * The bottom arrow.
   */
  public var arrowDown:FunkinSprite;

  /**
   * The XML Data for the credits.
   */
  public var creditsXML:Access;

  override public function create():Void
  {
    var bg:FunkinSprite = new FunkinSprite().loadTexture('ui/menu/menuBG');
    bg.color = 0xFFAA008E;
    bg.screenCenter();
    bg.active = false;
    add(bg);

    var checkers:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 80 * 2, 80 * 2, true, 0x33FFFFFF, 0x0));
    checkers.velocity.set(40, 40);
    add(checkers);

    bubbleGroup = new FlxTypedGroup<CreditsBubble>();
    add(bubbleGroup);

    iconCamera = new FlxCamera(ARROW_X);
    iconCamera.bgColor = 0x0;
    FlxG.cameras.add(iconCamera, false);

    arrowUp = new FunkinSprite(0, ARROW_Y_TOP).loadTexture('ui/credits/arrow');
    arrowUp.alpha = 0.9;
    arrowUp.cameras = [iconCamera];
    arrowUp.scrollFactor.set();

    arrowDown = new FunkinSprite(0, ARROW_Y_BOTTOM).loadTexture('ui/credits/arrow');
    arrowDown.flipY = true;
    arrowDown.alpha = 0.9;
    arrowDown.cameras = [iconCamera];
    arrowDown.scrollFactor.set();

    iconCamera.width = Std.int(arrowUp.width);

    loadXML();

    add(arrowUp);
    add(arrowDown);

    super.create();

    #if FLX_MOUSE
    FlxG.mouse.visible = true;
    #end

    changeItem();
  }

  override public function update(elapsed:Float):Void
  {
    if (controls.justPressed.BACK)
    {
      #if FLX_MOUSE
      FlxG.mouse.visible = false;
      #end

      FlxG.switchState(MenuState.new);
    }

    if (controls.waitAndRepeat().UI_UP)
    {
      changeItem(-1);
      arrowUp.scale.set(1.2, 0.5);
    }

    if (controls.waitAndRepeat().UI_DOWN)
    {
      changeItem(1);
      arrowDown.scale.set(1.2, 0.5);
    }

    if (controls.justReleased.UI_UP)
    {
      arrowUp.scale.set(1, 1);
    }

    if (controls.justReleased.UI_DOWN)
    {
      arrowDown.scale.set(1, 1);
    }

    // MOUSE

    #if FLX_MOUSE
    if (FlxG.mouse.wheel != 0)
    {
      changeItem(-FlxG.mouse.wheel);
      // TODO: scale for wheel, it wouldnt work for me even with a good way to check so like idfk. - Crusher
      // we could always remove it, idk if i like it tbh - Til
    }

    if (FlxG.mouse.justPressed)
    {
      if (FlxG.mouse.overlaps(arrowUp, iconCamera))
      {
        changeItem(-1);
        arrowUp.scale.set(1.2, 0.5);
      }

      if (FlxG.mouse.overlaps(arrowDown, iconCamera))
      {
        changeItem(1);
        arrowDown.scale.set(1.2, 0.5);
      }

      for (i => item in bubbleGroup.members[curSelected].grpSocials.members)
      {
        if (FlxG.mouse.overlaps(item))
          SystemUtil.openURL(bubbleData[curSelected].socials[i].url);
      }
    }

    if (FlxG.mouse.justReleased)
    {
      arrowUp.scale.set(1, 1);
      arrowDown.scale.set(1, 1);
    }
    #end

    iconCamera.scroll.y = MathUtil.coolLerp(iconCamera.scroll.y, iconCameraYLerp, 0.23);

    super.update(elapsed);
  }

  public function loadXML():Void
  {
    try
    {
      creditsXML = new Access(Paths.content.xml('config/credits'));
      creditsXML = creditsXML.node.credits;
    }
    catch (e:Exception)
    {
      trace('[WARNING] Credits data is invalid! (${e.toString()})');
      FlxG.switchState(MenuState.new);
      return;
    }

    // TODO: when modding support is done, find a way to merge xmls together (make sure modded ones are first)

    bubbleData = [];

    var iconPosY:Float = ICON_Y;
    for (user in creditsXML.nodes.user)
    {
      var data:BubbleData = {
        name: 'Default User',
        icon: 'face',
        description: 'Make sure to add a description in your credits.xml!',
        socials: []
      };

      if (user.has.name)
        data.name = user.att.name;

      if (user.has.icon)
        data.icon = user.att.icon;

      if (user.hasNode.description)
        data.description = user.node.description.innerData;

      if (user.hasNode.socials)
      {
        var socials:Access = user.node.socials;

        for (social in socials.elements)
        {
          var toPush:SocialData = {name: social.name, url: social.innerData};

          if (toPush.name == 'github')
            toPush.url = 'https://github.com/' + toPush.url;

          data.socials.push(toPush);
        }

        #if FUNKIN_GIT_DETAILS
        if (socials.hasNode.github && socials.node.github.has.contributor && socials.node.github.att.contributor == 'true')
        {
          var percentage:Null<Float> = CONTRIBUTOR_PERCENTAGES.get(socials.node.github.innerData);
          data.githubContribPercent = percentage;
        }
        #end
      }

      // hahahahahaha bfdi reference
      var yoylecake:CreditsBubble = new CreditsBubble(data);
      bubbleGroup.add(yoylecake);

      var icon:FunkinSprite = new FunkinSprite(0, iconPosY);
      icon.loadTexture('ui/credits/icons/' + data.icon);
      icon.x = MathUtil.center(arrowUp.width, icon.width);
      iconPosY += icon.height + ICON_DISTANCE;
      icon.cameras = [iconCamera];
      icons.push(icon);
      add(icon);

      bubbleData.push(data);
    }
  }

  function changeItem(?indexHop:Int = 0):Void
  {
    curSelected = FlxMath.wrap(curSelected + indexHop, 0, bubbleData.length - 1);

    if (indexHop != 0)
      FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));

    for (i => item in bubbleGroup.members)
    {
      item.targetY = i - curSelected;
    }

    for (i => item in icons)
    {
      if (i == curSelected)
      {
        item.alpha = 1;
        iconCameraYLerp = item.y - ICON_Y;
      }
      else
      {
        item.alpha = 0.8;
      }
    }
  }
}

private class CreditsBubble extends FlxSpriteGroup
{
  /**
   * cant really explain it dude idk
   */
  public var targetY:Float = 0;

  /**
   * All the social icons for this bubble. Is used by `CreditsState` for mouse detection.
   */
  public var grpSocials:FlxTypedSpriteGroup<FunkinSprite>;

  public function new(data:BubbleData)
  {
    super(CreditsState.BUBBLE_X_POS);

    var bubble:FlxSprite = new FlxSprite(0, 0).makeGraphic(CreditsState.BUBBLE_WIDTH, CreditsState.BUBBLE_HEIGHT, 0x0);
    FlxSpriteUtil.drawRoundRect(bubble, 0, 0, CreditsState.BUBBLE_WIDTH, CreditsState.BUBBLE_HEIGHT, CreditsState.BUBBLE_WIDTH / 16,
      CreditsState.BUBBLE_WIDTH / 16);
    bubble.alpha = 0.6;
    add(bubble);

    var name:Alphabet = new Alphabet(51, 45, data.name, CreditsState.BUBBLE_WIDTH - 51, "bold");
    add(name);

    var description:Alphabet = new Alphabet(64, 176, data.description, CreditsState.BUBBLE_WIDTH - 64, "default");
    add(description);

    if (data.githubContribPercent != null)
    {
      var percent:FlxText = new FlxText(0, 425, CreditsState.BUBBLE_WIDTH - 7, '${Math.round(data.githubContribPercent * 100)}% of the commits', 40);
      percent.setFormat(Paths.location.get('ui/fonts/vcr.ttf'), 40, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      add(percent);
    }

    var line:FlxSprite = new FlxSprite(0, 474).makeGraphic(CreditsState.BUBBLE_WIDTH, 10, 0x0);
    FlxSpriteUtil.drawLine(line, 0, 0, CreditsState.BUBBLE_WIDTH, 0, {
      color: 0xFF000000,
      thickness: 10
    });
    add(line);

    grpSocials = new FlxTypedSpriteGroup<FunkinSprite>(50, 490);
    add(grpSocials);

    var xPos:Float = 0;
    for (social in data.socials)
    {
      var socialIcon:FunkinSprite = new FunkinSprite(xPos, 0).loadTexture('ui/credits/socials/' + social.name);
      socialIcon.setGraphicSize(0, 98);
      socialIcon.updateHitbox();
      xPos += socialIcon.width + 4;
      grpSocials.add(socialIcon);
    }
  }

  override public function update(elapsed:Float)
  {
    y = MathUtil.coolLerp(y, CreditsState.BUBBLE_Y_POS + (CreditsState.BUBBLE_DISTANCE_Y * targetY), 0.17);
    super.update(elapsed);
  }
}

private typedef BubbleData =
{
  var name:String;
  var description:String;
  var socials:Array<
    {
      name:String,
      url:String
    }>;

  var icon:String;

  @:optional
  var githubContribPercent:Null<Float>;
}

private typedef SocialData =
{
  name:String,
  url:String
}
