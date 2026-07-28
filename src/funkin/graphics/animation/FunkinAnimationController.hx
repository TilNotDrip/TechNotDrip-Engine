package funkin.graphics.animation;

class FunkinAnimationController
{
  /**
   * The current animation playing.
   */
  public var curAnim:Null<FunkinAnimation>;

  var animations:Map<String, FunkinAnimation>;
  var parent:FunkinSprite;

  @:allow(funkin.graphics.animation.FunkinAnimation)
  var frameIndex(get, set):Int;

  public function new(parent:FunkinSprite)
  {
    animations = new Map<String, FunkinAnimation>();
    this.parent = parent;
  }

  public function play(name:String, ?force:Bool):Void
  {
    final anim:Null<FunkinAnimation> = animations.get(name);
    if (anim == null)
      return;

    anim.play(force);
    curAnim = anim;
  }

  public function addByPrefix(name:String, prefix:String, ?frameRate:Float, ?looped:Bool, ?priority:Int):Void
  {
    var frames:Array<Int> = findFrames(prefix);

    var animation:FunkinAnimation = new FunkinAnimation(this, name, frames);
    animation.frameRate = frameRate ?? 24;
    animation.priority = priority ?? 1000;
    animation.looped = looped ?? false;
    animations.set(name, animation);
  }

  public function addByIndices(name:String, prefix:String, indices:Array<Int>, ?frameRate:Float, ?looped:Bool, ?priority:Int):Void
  {
    var allFrames:Array<Int> = findFrames(prefix);
    var frames:Array<Int> = indices.map(i -> allFrames[i]);

    var animation:FunkinAnimation = new FunkinAnimation(this, name, frames);
    animation.frameRate = frameRate ?? 24;
    animation.priority = priority ?? 1000;
    animation.looped = looped ?? false;
    animations.set(name, animation);
  }

  public function update(dt:Float):Void
  {
    curAnim?.update(dt);
  }

  function findFrames(prefix:String):Array<Int>
  {
    return [
      for (i => frame in parent.tiles)
      {
        if (frame.name.startsWith(prefix)) i;
      }
    ];
  }

  function set_frameIndex(value:Int):Int
  {
    parent.tileIndex = value;
    return value;
  }

  function get_frameIndex():Int
  {
    return parent.tileIndex;
  }
}
