package funkin.graphics.animation;

class FunkinAnimation
{
  /**
   * The name of the animation.
   */
  public var name:String;

  /**
   * A list of frames stored as indexes to the tile.
   */
  public var frames:Array<Int>;

  /**
   * Animation frameRate - the speed in frames per second that the animation should play at.
   */
  public var frameRate(default, set):Float;

  /**
   * Keeps track of the current frame of animation.
   * This is NOT an index into the tile sheet, but the frame number in the animation object.
   */
  public var curFrame(default, set):Int;

  /**
   * The priority of this animation.
   */
  public var priority:Int;

  /**
   * Whether or not the animation is looped.
   */
  public var looped:Bool;

  /**
   * Whether or not the animation is finished.
   */
  public var finished:Bool;

  /**
   * Whether or not the animation is paused.
   */
  public var paused:Bool;

  var parent:FunkinAnimationController;
  var frameDuration:Float;
  var frameTimer:Float;

  public function new(parent:FunkinAnimationController, name:String, frames:Array<Int>)
  {
    this.parent = parent;
    this.name = name;
    this.frames = frames;

    looped = false;
    finished = false;
    paused = false;
    priority = 1000;
    frameDuration = 0;
    frameTimer = 0;
    curFrame = 0;
  }

  public function play(?force:Bool):Void
  {
    if (!force && !finished)
    {
      paused = false;
      return;
    }

    paused = false;
    frameTimer = 0;
    finished = false;
    curFrame = 0;
  }

  public function stop():Void
  {
    curFrame = frames.length - 1;
    paused = true;
  }

  public function update(dt:Float):Void
  {
    if (paused || finished)
      return;

    frameTimer += dt;
    while (!finished && frameTimer > frameDuration)
    {
      frameTimer -= frameDuration;

      if (looped && curFrame == frames.length - 1)
      {
        // Loop Callback?
        curFrame = 0;
        continue;
      }

      curFrame++;
    }
  }

  function set_curFrame(frame:Int):Int
  {
    if (frame > frames.length - 1)
    {
      curFrame = frames.length - 1;
      finished = true;
    }
    else if (frame < 0)
      curFrame = 0;
    else
      curFrame = frame;

    parent.frameIndex = frames[curFrame];

    return curFrame;
  }

  function set_frameRate(value:Float):Float
  {
    frameDuration = value > 0 ? 1.0 / value : 0;
    frameRate = value;
    return value;
  }
}
