package funkin.util;

import animate.FlxAnimate;
import animate.FlxAnimateJson;
import animate.internal.Frame;
import animate.internal.Timeline;

class FlxAnimateUtil
{
  /**
   * Gets every possible animation the texture atlas provides.
   * @param sprite The sprite to check for animations.
   * @return A list of all possible animations.
   */
  public static function getAnimateAnimations(sprite:FlxAnimate):Array<String>
  {
    var toReturn:Array<String> = [];

    var defaultTimeline:Null<Timeline> = sprite.anim.getDefaultTimeline();
    if (defaultTimeline == null)
      return toReturn;

    var timelines:Array<Timeline> = sprite.anim.getCollectionTimelines() ?? [];
    timelines.unshift(defaultTimeline);

    var timelineAnims:Array<String> = [];
    for (timeline in timelines)
    {
      timelineAnims.resize(0);

      var frames:Array<Frame> = [for (l in timeline.layers) for (i in l.frames) i];

      for (frame in frames)
      {
        if (frame.name.length < 1)
          continue;

        timelineAnims.push(frame.name.rtrim());
      }

      @:privateAccess
      {
        for (symbolItem in sprite.library.dictionary.iterator())
          timelineAnims.push(symbolItem.name);

        // Are the loops below needed??
        // I feel all symbols are already loaded in already due to the master symbol containing them.

        if (sprite.library._isInlined)
        {
          for (i in 0...sprite.library._symbolDictionary?.length ?? 0)
            timelineAnims.push(sprite.library._symbolDictionary[i].SN);
        }
        else
        {
          for (symbol in sprite.library._libraryList)
            timelineAnims.push(symbol);
        }
      }

      for (animName in timelineAnims)
      {
        var fullName:String = '${timeline.name}\\\\$animName';

        if (!toReturn.contains(animName))
          toReturn.push(animName);

        if (!toReturn.contains(fullName))
          toReturn.push(fullName);
      }
    }

    return toReturn;
  }

  /**
   * Adds a Texture Atlas Animation to a sprite.
   * Frame Labels and Symbols are supported.
   * @param sprite The sprite to apply this animation to.
   * @param name What this animation should be called (e.g. `"run"`).
   * @param prefix The name of the Texture Atlas animation internally.
   * @param indices An array of numbers indicating what frames to play in what order (e.g. `[0, 1, 2]`).
   * @param frameRate The speed in frames per second that the animation should play at (e.g. `40` fps), leave ``null`` to use the default framerate.
   * @param looped Whether or not the animation is looped or just plays once.
   * @param flipX Whether the frames should be flipped horizontally.
   * @param flipY Whether the frames should be flipped vertically.
   */
  public static function addAnimateAtlasAnimation(sprite:FlxAnimate, name:String, prefix:String, ?indices:Array<Int>, ?frameRate:Float, ?looped:Bool = true,
      ?flipX:Bool, ?flipY:Bool):Void
  {
    if (sprite.library == null)
      return;

    var slashIndex:Int = prefix.indexOf('\\\\');
    var timeline:Null<Timeline> = null;

    if (slashIndex >= 0)
    {
      var timelines:Array<Timeline> = sprite.anim.getCollectionTimelines() ?? [];
      timelines.unshift(sprite.anim.getDefaultTimeline());

      var timelineName:String = prefix.substring(0, slashIndex);
      timeline = timelines?.filter((timeline:Timeline) -> timeline.name == timelineName)[0];
    }

    var newPrefix:String = slashIndex != -1 ? prefix.substring(slashIndex + '\\\\'.length) : prefix;
    var foundLabelFrames:Array<Int> = sprite.anim.findFrameLabelIndices(newPrefix, timeline);

    if (foundLabelFrames.length > 0)
    {
      if (indices != null)
        sprite.anim.addByFrameLabelIndices(name, newPrefix, indices, frameRate, looped, flipX, flipY);
      else
        sprite.anim.addByFrameLabel(name, newPrefix, frameRate, looped, flipX, flipY);
    }
    else
    {
      if (indices != null)
        sprite.anim.addBySymbolIndices(name, newPrefix, indices, frameRate, looped, flipX, flipY);
      else
        sprite.anim.addBySymbol(name, newPrefix, frameRate, looped, flipX, flipY);
    }
  }
}
