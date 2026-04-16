package funkin.ui.freeplay;

import funkin.ui.shaders.PureColor;

class DifficultyGroup extends FunkinSpriteGroup
{
  var leftArrow:FunkinSprite;
  var rightArrow:FunkinSprite;

  var whiteShaderLeft:PureColor;
  var whiteShaderRight:PureColor;

  var difficultyMap:Map<String, FunkinSprite>;

  public function new(x:Float, y:Float, difficulties:Array<String>)
  {
    difficultyMap = new Map<String, FunkinSprite>();
    super(x, y);

    leftArrow = new FunkinSprite().loadFrames('ui/freeplay/freeplaySelector');
    leftArrow.addAnimation('idle', 'arrow pointer loop');
    leftArrow.playAnimation('idle');
    add(leftArrow);

    whiteShaderLeft = new PureColor(0xFFFFFFFF);
    leftArrow.shader = whiteShaderLeft;

    for (difficulty in difficulties)
    {
      var difficultySpr:FunkinSprite = new FunkinSprite(70, 10);

      if (Paths.location.isAnimated('ui/freeplay/difficulties/' + difficulty))
      {
        difficultySpr.loadFrames('ui/freeplay/difficulties/' + difficulty);
        difficultySpr.addAnimation('idle', '');
        difficultySpr.playAnimation('idle');
      }
      else
        difficultySpr.loadTexture('ui/freeplay/difficulties/' + difficulty);

      difficultySpr.doInvisibleDraw = true;
      difficultyMap.set(difficulty, difficultySpr);
      add(difficultySpr);
    }

    rightArrow = new FunkinSprite(305).loadFrames('ui/freeplay/freeplaySelector');
    rightArrow.addAnimation('idle', 'arrow pointer loop');
    rightArrow.playAnimation('idle');
    rightArrow.flipX = true;
    add(rightArrow);

    whiteShaderRight = new PureColor(0xFFFFFFFF);
    rightArrow.shader = whiteShaderRight;
  }

  /**
   * Changes the difficulty sprite and plays a little animation.
   * @param difficulty The difficulty to change to.
   * @param indexHop How much parent hopped to change to this difficulty.
   */
  public function changeDifficulty(difficulty:String, indexHop:Int):Void
  {
    for (name in difficultyMap.keys())
    {
      var spr:FunkinSprite = difficultyMap.get(name);
      spr.doInvisibleDraw = name != difficulty;
      spr.setPosition(x + 70, y + 10);

      if (name == difficulty && indexHop != 0)
      {
        spr.offset.y += 5;
        spr.alpha = 0.5;
        new FlxTimer().start(1 / 24, (_) ->
        {
          spr.alpha = 1;
          spr.updateHitbox();
        });
      }
    }

    var selector:FunkinSprite = null;
    var whiteShader:PureColor = null;

    if (indexHop == -1)
    {
      selector = leftArrow;
      whiteShader = whiteShaderLeft;
    }
    else if (indexHop == 1)
    {
      selector = rightArrow;
      whiteShader = whiteShaderRight;
    }
    else
      return;

    selector.offset.y -= 5;

    whiteShader.colorSet = true;

    selector.scale.set(0.5, 0.5);

    new FlxTimer().start(2 / 24, function(tmr)
    {
      selector.scale.set(1, 1);
      whiteShader.colorSet = false;
      selector.updateHitbox();
    });
  }
}
