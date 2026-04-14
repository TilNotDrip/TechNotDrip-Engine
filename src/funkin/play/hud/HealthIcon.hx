package funkin.play.hud;

import flixel.math.FlxPoint;
import funkin.data.icon.IconData;
import haxe.Json;

class HealthIcon extends FunkinSprite
{
  /**
   * The ID of the Health Icon.
   * This is used to determine what icon to load.
   */
  public var id:String = '';

  /**
   * Which direction the Health Icon is facing to.
   * @see `IconDirection`
   */
  public var direction(default, set):IconDirection = LEFT;

  /**
   * The color that the health bar should be in connection with this icon.
   */
  public var healthBarColor:FlxColor;

  /**
   * The metadata of this health icon.
   */
  public var metadata:IconData;

  /**
   * If this icon can play the bop animation.
   */
  public var canBop:Bool = true;

  /**
   * How much the icon should be scaled.
   * This will be calculated with `metadata.scale` in mind.
   */
  public var iconScale:FlxPoint = null;

  public function new(id:String, direction:IconDirection)
  {
    super();

    iconScale = new FlxCallbackPoint(iconScaleCallback);

    this.direction = direction;

    changeIcon(id);
  }

  var isOldIcon:Bool = false;
  var iconBeforeOldChange:String;

  /**
   * Swap the current icon with the bf-old icon.
   * Used for the "9 easter egg".
   */
  public function swapOldIcon():Void
  {
    isOldIcon = !isOldIcon;

    var iconChange:String;
    if (isOldIcon)
    {
      iconBeforeOldChange = id;
      iconChange = 'bf-old';
    }
    else
      iconChange = iconBeforeOldChange;

    changeIcon(iconChange);
  }

  /**
   * Change the icon, based off of ID.
   * @param newID The new Icon ID.
   */
  public function changeIcon(newID:String):Void
  {
    id = newID;
    var metadataText:String = Paths.content.json('gameplay/icons/' + id + '/data');

    if (metadataText == null)
    {
      trace('[ERROR] Unable to load the Icon Metadata of $id! Maybe it doesnt exist? Falling Back to Default...');

      id = 'face';
      metadataText = Paths.content.json('gameplay/icons/' + id + '/data');

      if (metadataText == null)
      {
        trace('[FATAL ERROR] Tried loading metadata for default icon, but it failed! [$id] Loading HaxeFlixel image...');
        loadGraphic("flixel/images/logo/default.png");
        setGraphicSize(150, 150);
        antialiasing = false;
        canBop = false;
        id = '';
        return;
      }
    }

    metadata = cast Json.parse(metadataText);

    if (metadata.resolution != null)
      loadGraphic(Paths.content.imageGraphic('gameplay/icons/' + newID + '/texture'), true, metadata.resolution[0], metadata.resolution[1]);
    else
      frames = Paths.content.sparrowAtlas('gameplay/icons/' + newID + '/texture');

    healthBarColor = FlxColor.fromString(metadata.color);

    if (true) // antialiasing
      antialiasing = metadata.antialiasing;
    else
      antialiasing = false;

    for (anim in metadata.animations)
    {
      if (metadata.resolution != null)
        animation.add(anim.name, anim.indices, anim.framerate, anim.looped, anim.flipX, anim.flipY);
      else
      {
        if (anim.indices.length != 0)
          animation.addByIndices(anim.name, anim.prefix, anim.indices, '', anim.framerate, anim.looped, anim.flipX, anim.flipY);
        else
          animation.addByPrefix(anim.name, anim.prefix, anim.framerate, anim.looped, anim.flipX, anim.flipY);
      }
    }

    updateIconAnimation(50);
  }

  /**
   * Update the Health Icon Animation based off of the health.
   * @param health The health, in percent.
   */
  public function updateIconAnimation(health:Float):Void
  {
    if (metadata == null)
      return;

    var curHealth:Float = health;

    if (direction == RIGHT)
      curHealth = 100 - health;

    for (check in metadata.healthAnimations)
    {
      if (animation.curAnim != null && animation.curAnim.name == check.anim)
        continue;

      if (curHealth >= check.minimumHealth && curHealth <= check.maximumHealth)
        animation.play(check.anim, true);
    }
  }

  private function iconScaleCallback(iconScale:FlxPoint):Void
  {
    scale.set(iconScale.x, iconScale.y);
    scale.scale(metadata?.scale?.x ?? 1, metadata?.scale?.y ?? 1);
  }

  private function set_direction(direction:IconDirection):IconDirection
  {
    this.direction = direction;

    // this works for now, but maybe this will need to be changed in the long run
    flipX = switch (direction)
    {
      case LEFT:
        false;
      case RIGHT:
        true;
    }

    return direction;
  }

  override public function destroy():Void
  {
    iconScale.destroy();
    super.destroy();
  }
}

enum IconDirection
{
  LEFT;
  RIGHT;
}
