package funkin.ui.story;

import funkin.data.week.Week;
import funkin.play.PlayState;
import funkin.ui.menu.MenuState;

class StoryModeState extends FunkinState
{
  /**
   * The weeks that the game has successfully loaded.
   */
  public var loadedWeeks:Array<Week> = [];

  static var curSelected:Int = 0;
  static var curDifficulty:Int = 0;

  var selectedWeek:Bool = false;

  var colorBG:FunkinSprite;

  var txtTracklist:FlxText;
  var scoreText:FlxText = null;
  var weekMotto:FlxText = null;

  var grpWeekItems:FlxTypedGroup<WeekItem>;
  var grpOfWeekSprGrps:FlxTypedSpriteGroup<FunkinSpriteGroup>;

  var difficultyGrp:FlxSpriteGroup;
  var difficultySprs:FunkinSpriteGroup;
  var leftArrow:FunkinSprite;
  var rightArrow:FunkinSprite;

  var lerpScore:Float = 0;
  var intendedScore:Int = 0;

  override public function create():Void
  {
    loadedWeeks = Week.fetchAllWeeks();

    #if FUNKIN_DISCORD_RPC
    DiscordRPC.details = 'Story Mode Menu';
    #end

    PlayState.storyMode = null;

    grpWeekItems = new FlxTypedGroup<WeekItem>();
    add(grpWeekItems);

    txtTracklist = new FlxText(FlxG.width * 0.05, 500, 0, "", 32);
    txtTracklist.setFormat("VCR OSD Mono", 32, 0xFFE55777, CENTER);
    txtTracklist.antialiasing = false;
    add(txtTracklist);

    var topBlackBar:FunkinSprite = new FunkinSprite().loadTexture('#000000', FlxG.width, 56);
    add(topBlackBar);

    scoreText = new FlxText(10, 10, 0, "SCORE: 0", 36);
    scoreText.setFormat("VCR OSD Mono", 32);
    add(scoreText);

    weekMotto = new FlxText(FlxG.width, 10, 0, "", 32);
    weekMotto.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
    weekMotto.alpha = 0.7;
    add(weekMotto);

    colorBG = new FunkinSprite(0, 56).loadTexture('#FFFFFF', FlxG.width, 400);
    add(colorBG);

    grpOfWeekSprGrps = new FlxTypedSpriteGroup<FunkinSpriteGroup>(0, 56);
    add(grpOfWeekSprGrps);

    for (i => week in loadedWeeks)
    {
      var weekSpr:WeekItem = new WeekItem(0, colorBG.y + colorBG.height + 10, week.id);
      weekSpr.targetY = i;
      weekSpr.z = 10;
      grpWeekItems.add(weekSpr);

      weekSpr.screenCenter(X);

      var weekSprGrp:FunkinSpriteGroup = week.buildSprites();
      // weekSprGrp.group.rearrange();
      grpOfWeekSprGrps.add(weekSprGrp);

      // TODO: ADD LOCK SPRITE
    }

    difficultyGrp = new FlxSpriteGroup(870, 480);
    add(difficultyGrp);

    leftArrow = new FunkinSprite().loadFrames('ui/story/ui/arrows');
    leftArrow.addAnimation('idle', 'leftIdle');
    leftArrow.addAnimation('push', 'leftConfirm');
    leftArrow.playAnimation('idle');
    leftArrow.updateHitbox();
    difficultyGrp.add(leftArrow);

    rightArrow = new FunkinSprite(leftArrow.width + Constants.DIFFICULTY_SPACING).loadFrames('ui/story/ui/arrows');
    rightArrow.addAnimation('idle', 'rightIdle');
    rightArrow.addAnimation('push', 'rightConfirm');
    rightArrow.playAnimation('idle');
    rightArrow.updateHitbox();
    difficultyGrp.add(rightArrow);

    difficultySprs = new FunkinSpriteGroup();
    difficultyGrp.add(difficultySprs);

    generateDifficultySprites();

    super.create();

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

    if (controls.waitAndRepeat().UI_UP)
      changeItem(-1);

    if (controls.waitAndRepeat().UI_DOWN)
      changeItem(1);

    if (controls.justPressed.ACCEPT)
    {
      selectedWeek = true;

      FlxG.sound.play(Paths.content.audio('ui/menu/confirmMenu'));

      for (spr in grpOfWeekSprGrps.members[curSelected].members)
      {
        if (spr.animationExists('confirm'))
        {
          spr.playAnimation('confirm', true);
        }
      }

      grpWeekItems.members[curSelected].startFlashing();

      PlayState.storyMode = new StoryModeHandler(loadedWeeks[curSelected], _difficulties[curDifficulty]);

      new FlxTimer().start(1, (tmr:FlxTimer) ->
      {
        FlxG.switchState(PlayState.storyMode.nextState);
      });
    }

    if (controls.justPressed.BACK)
    {
      FlxG.switchState(MenuState.new);
    }

    if (controls.waitAndRepeat().UI_LEFT)
    {
      changeDifficulty(-1);
      leftArrow.playAnimation('push');
      leftArrow.updateHitbox();
    }

    if (controls.justReleased.UI_LEFT)
    {
      leftArrow.playAnimation('idle');
      leftArrow.updateHitbox();
    }

    if (controls.waitAndRepeat().UI_RIGHT)
    {
      changeDifficulty(1);
      rightArrow.playAnimation('push');
      rightArrow.updateHitbox();
    }

    if (controls.justReleased.UI_RIGHT)
    {
      rightArrow.playAnimation('idle');
      rightArrow.updateHitbox();
    }
  }

  override public function beatHit():Void
  {
    danced = !danced;

    for (grp in grpOfWeekSprGrps.members)
    {
      for (spr in grp.members)
      {
        if (spr.currentAnim != 'confirm')
          spr.animation.play(getIdleAnimationForSprite(spr), false);
      }
    }
  }

  var danced:Bool = false;

  /**
   * Auto determines the current idle animation that should be played.
   * @param spr The sprite to check the animations from.
   * @return idle or danceLeft/Right.
   */
  public function getIdleAnimationForSprite(spr:FlxSprite):String
  {
    if (spr.animation.exists('danceLeft') || spr.animation.exists('danceRight'))
    {
      return (danced) ? 'danceLeft' : 'danceRight';
    }

    return 'idle';
  }

  var difficultySpriteIds:Array<String> = [];
  var _difficulties:Array<String> = [];

  /**
   * (Re)generates the difficulty sprites.
   */
  public function generateDifficultySprites():Void
  {
    difficultySpriteIds = [];
    for (week in loadedWeeks)
    {
      for (difficulty in week.getDifficulties())
      {
        if (!difficultySpriteIds.contains(difficulty))
        {
          var difficultySprite:FunkinSprite = new FunkinSprite().loadTexture('ui/story/ui/difficulties/' + difficulty);
          difficultySprite.doInvisibleDraw = true;
          difficultySprs.add(difficultySprite);
          difficultySpriteIds.push(difficulty);
        }
      }
    }
  }

  function changeItem(change:Int = 0):Void
  {
    curSelected = FlxMath.wrap(curSelected + change, 0, loadedWeeks.length - 1);

    if (change != 0)
    {
      FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));
    }

    colorBG.color = loadedWeeks[curSelected].getBGColor();

    weekMotto.text = loadedWeeks[curSelected].getMotto();
    weekMotto.x = FlxG.width - (weekMotto.width + 10);

    txtTracklist.text = "TRACKS\n\n";
    txtTracklist.text += loadedWeeks[curSelected].getDisplaySongNames().join('\n');
    txtTracklist.updateHitbox();

    txtTracklist.screenCenter(X);
    txtTracklist.x -= FlxG.width * 0.35;

    _difficulties = loadedWeeks[curSelected].getDifficulties();
    changeDifficulty();

    #if FUNKIN_DISCORD_RPC
    DiscordRPC.state = 'Has ' + loadedWeeks[curSelected].name + ' selected';
    #end

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

  function changeDifficulty(change:Int = 0):Void
  {
    curDifficulty = FlxMath.wrap(curDifficulty + change, 0, _difficulties.length - 1);

    if (change != 0)
    {
      FlxG.sound.play(Paths.content.audio('ui/menu/scrollMenu'));
    }

    for (i => difficultySpr in difficultySprs.members)
    {
      difficultySpr.y = difficultySprs.y + MathUtil.center(Math.max(leftArrow.height, rightArrow.height), difficultySpr.height);
      difficultySpr.doInvisibleDraw = true;
      FlxTween.cancelTweensOf(difficultySpr);

      if (difficultySpriteIds[i] == _difficulties[curDifficulty])
      {
        difficultySpr.doInvisibleDraw = false;

        if (change != 0)
        {
          difficultySpr.y -= 15;
          FlxTween.tween(difficultySpr, {y: difficultySpr.y + 15, alpha: 1}, 0.07);
        }

        difficultySpr.x = difficultyGrp.x;
        difficultySpr.x += MathUtil.center(leftArrow.width + Constants.DIFFICULTY_SPACING + rightArrow.width, difficultySpr.width);
      }
    }
  }
}
