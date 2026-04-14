package funkin.play.hud.strumline;

class NoteSplash extends FunkinSprite
{
  public function new()
  {
    super();
    loadNoteSplashes();
  }

  public function setupNoteSplash(x:Float, y:Float, direction:NoteDirection):Void
  {
    setPosition(x, y);

    alpha = 0.6;

    playAnimation('${direction}-${FlxG.random.int(0, 1)}');
    updateHitbox();

    offset.set(width * 0.3, height * 0.3);
  }

  public function loadNoteSplashes():Void
  {
    // TODO: make this softcoded
    loadFrames('gameplay/hud/funkin/strumline/noteSplashes');

    for (direction in NoteDirection.allDirections)
    {
      for (i in 0...2)
      {
        addAnimation('${direction}-$i', 'note impact ${i + 1} ${direction.color}', null, 24, false);
      }
    }

    onAnimFinished.add(onAnimationFinished);
  }

  function onAnimationFinished(anim:String):Void
  {
    kill();
  }
}
