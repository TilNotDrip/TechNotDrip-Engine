package funkin.objects;

import funkin.structures.ObjectStructure;

/**
 * This is a sprite class that adds on to the already existing FlxSprite.
 */
class FunkinSprite extends FlxSprite
{
	/**
	 * Draws this `FunkinSprite`, but invisible.
	 * This is basically visible/alpha, but it doesn't lag when you make it visible again.
	 */
	public var doInvisibleDraw:Bool = false;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
	}

	/**
	 * Loads or creates a texture and applies it to this sprite.
	 * @param path The asset path. (If `path` starts with a **#** then a color will be made instead and rectWidth + rectHeight will determine its size.)
	 * @param rectWidth If the path is a color then how big should it's width be?
	 * @param rectHeight If the path is a color then how big should it's height be?
	 * @return This `FunkinSprite` instance (nice for chaining stuff together, if you're into that).
	 */
	public function loadTexture(path:String = '#000000', rectWidth:Int = 1, rectHeight:Int = 1):FunkinSprite
	{
		if (path.startsWith('#'))
		{
			makeGraphic(rectWidth, rectHeight, FlxColor.fromString(path));
		}
		else
		{
			loadGraphic(Paths.content.imageGraphic(path));
		}

		return this;
	}

	override public function draw():Void
	{
		if (doInvisibleDraw)
		{
			// kinda how psych engine does it for cached characters.
			var oldAlpha:Float = alpha;
			alpha = 0.0001;
			super.draw();
			alpha = oldAlpha;
		}
		else
			super.draw();
	}
}

typedef FunkinSpriteGroup = FlxTypedSpriteGroup<FunkinSprite>
