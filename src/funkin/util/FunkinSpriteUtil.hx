package funkin.util;

import funkin.data.object.ObjectData;

class FunkinSpriteUtil
{
  /**
   * Creates a new `FunkinSprite` from a `ObjectData`.
   * @param spriteToUse The `FunkinSprite` object to apply this to.
   * @param structure The structure data to use when applying it.
   * @return Freshly made `FunkinSprite`.
   */
  public static function createFromStructure(?spriteToUse:FunkinSprite = null, structure:ObjectData):FunkinSprite
  {
    if (structure == null)
      return spriteToUse;

    var sprite:FunkinSprite = spriteToUse ?? new FunkinSprite();

    var isAnimated:Bool = !structure.path.startsWith('#') && ((structure?.animation?.anims?.length ?? 0) > 0);

    if (isAnimated)
    {
      sprite.loadFrames(structure.path, structure.animation.type);
    }
    else
    {
      sprite.loadTexture(structure.path, Math.floor(structure?.scale?.x ?? 1), Math.floor(structure?.scale?.y ?? 1));
    }

    // i dont know if i like this...
    // sprite.active = isAnimated;

    sprite.x = structure?.position?.x ?? 0;
    sprite.y = structure?.position?.y ?? 0;
    sprite.z = structure?.position?.z ?? 0;
    sprite.alpha = structure?.alpha ?? 1;
    sprite.antialiasing = structure?.antialiasing ?? true;
    sprite.flipX = structure?.flipX ?? false;
    sprite.flipY = structure?.flipY ?? false;
    sprite.scale.x = structure?.scale?.x ?? 1;
    sprite.scale.y = structure?.scale?.y ?? 1;
    sprite.scrollFactor.x = structure?.scrollFactor?.x ?? 1;
    sprite.scrollFactor.y = structure?.scrollFactor?.y ?? 1;
    sprite.updateHitbox();

    if (isAnimated)
      addAnimationsFromStructure(sprite, structure?.animation?.anims ?? []);

    return sprite;
  }

  /**
   * Adds animations to a `FunkinSprite` from a array with `AnimationDataArray`'s.
   * @param sprite The `FunkinSprite` to apply this to.
   * @param structure The array filled with `AnimationDataArray`. to create animations from.
   * @return `FunkinSprite` with animations added.
   */
  public static function addAnimationsFromStructure(sprite:FunkinSprite, structure:Array<AnimationDataArray>):FunkinSprite
  {
    if (sprite == null || structure == null)
      return sprite;

    for (anim in structure)
    {
      // TODO: Work with flipX and flipY.
      sprite.addAnimation(anim.name, anim.prefix, anim?.indices ?? [], anim?.framerate ?? 24, anim?.looped ?? false);
    }

    return sprite;
  }
}
