package funkin.ui.title;

class TitleScene extends FunkinScene
{
  /**
   * The sprite containing GF bopping to the beat.
   */
  public var gfDance:FunkinSprite;

  /**
   * The Friday Night Funkin' Logo.
   */
  public var logo:FunkinSprite;

  /**
   * The "Press Enter to Begin" Text.
   */
  public var titleText:FunkinSprite;

  var danceLeft:Bool = true;

  public function new()
  {
    super();
    name = 'title';

    FunkinSound.playMusic('ui/main-menu/freaky-menu/audio', true);
    Conductor.instance.changeBPM(102);

    logo = new FunkinSprite(-34, 6);
    logo.loadSparrow('ui/title/logo');
    logo.animation.addByPrefix('idle', 'logo bumpin', 24, true);
    logo.animation.play('idle');
    addChild(logo);

    gfDance = new FunkinSprite(width * 0.4, height * 0.07);
    gfDance.loadSparrow('ui/title/gf-dance');
    gfDance.animation.addByIndices('danceLeft', 'gfDance', [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, false);
    gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], 24, false);
    gfDance.animation.play('danceLeft');
    addChild(gfDance);

    // move this to a texture atlas eventually
    titleText = new FunkinSprite(100, height * 0.8);
    titleText.loadSparrow('ui/title/begin-text');
    titleText.animation.addByPrefix('idle', 'Press Enter to Begin', 24, true);
    titleText.animation.play('idle');
    addChild(titleText);
  }

  override function beatHit():Void
  {
    logo.animation.play('idle', true);

    gfDance.animation.play('dance${danceLeft ? 'Left' : 'Right'}', true);
    danceLeft = !danceLeft;

    super.beatHit();
  }

  override function sync(ctx:RenderContext)
  {
    Conductor.instance.update();
    super.sync(ctx);
  }
}

enum TitleState
{
  Intro;
  Idle;
  Begin;
}
