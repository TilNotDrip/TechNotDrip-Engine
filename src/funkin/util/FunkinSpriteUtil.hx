package funkin.util;

import funkin.structures.ObjectStructure;

class FunkinSpriteUtil
{
	public static function createFromStructure(?spriteToUse:FunkinSprite = null, structure:ObjectStructure):FunkinSprite
	{
		if (structure == null)
			return spriteToUse;

		var sprite:FunkinSprite = spriteToUse ?? new FunkinSprite();

		var isAnimated:Bool = !structure.path.startsWith('#')
			&& (structure?.animation?.anims != null && structure?.animation?.anims?.length > 0);

		if (isAnimated)
		{
			sprite.loadFrames(structure.path);
		}
		else
		{
			sprite.loadTexture(structure.path, Math.floor(structure?.scale?.x ?? 1), Math.floor(structure?.scale?.y ?? 1));
		}

		sprite.active = isAnimated;

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

	public static function addAnimationsFromStructure(sprite:FunkinSprite, structure:Array<AnimationArrayStructure>):FunkinSprite
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
