package funkin.objects.ui.freeplay;

import flixel.FlxCamera;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flxanimate.FlxAnimate;
import flxanimate.animate.FlxElement;
import funkin.util.visualizer.AnalyzerAnimationHelper;
import openfl.geom.ColorTransform;

class FreeplayDJAtlas extends FlxAnimate
{
	var analyzerHelper:AnalyzerAnimationHelper;

	public function new(?X:Null<Float>, ?Y:Null<Float>, ?Path:Null<String>, ?Settings:Null<Null<Null<flxanimate.FlxAnimate.Settings>>>)
	{
		super(X, Y, Path, Settings);
		analyzerHelper = new AnalyzerAnimationHelper(null, 3, 4);
	}

	/**
	 * Initializes the visualizer with `snd`.
	 * @param snd The sound to initialize with.
	 */
	public function initVisualizer(snd:FlxSound):Void
	{
		analyzerHelper.snd = snd;
		analyzerHelper.initAnalyzer(35);
	}

	override public function draw():Void
	{
		if (analyzerHelper.ready)
		{
			analyzerHelper.updateFFT();
		}

		super.draw();
	}

	override public function parseElement(instance:FlxElement, m:FlxMatrix, colorFilter:ColorTransform, ?filterInstance:
		{
			?instance:FlxElement
		} = null, ?cameras:Array<FlxCamera> = null, ?scrollFactor:FlxPoint = null):Void
	{
		if (instance?.symbol?.name?.startsWith('tt lights') && analyzerHelper.ready)
		{
			var nameSuffix:String = instance.symbol.name.substring('tt lights'.length);
			trace(nameSuffix);

			var index:Null<Int> = Std.parseInt(nameSuffix);
			if (index == null)
				return;

			instance.symbol.firstFrame = analyzerHelper.frameMap[index];
		}

		super.parseElement(instance, m, colorFilter, filterInstance, cameras, scrollFactor);
	}
}
