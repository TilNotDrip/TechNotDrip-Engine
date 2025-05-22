package funkin.objects.ui;

import flixel.util.FlxStringUtil;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * The performance stats TextField keeps track of FPS and Memory in-game.
 */
class PerformanceStats extends Sprite
{
	/**
	 * How many frames have passed since the last second.
	 */
	public var framesPerSecond(default, null):Int;

	/**
	 * The amount of RAM the application is currently using.
	 */
	public var randomAccessMemory(get, null):Null<Float>;

	/**
	 * The main text that shows FPS and RAM Usage.
	 */
	public var mainText:TextField;

	/**
	 * The outline text group.
	 */
	public var outlineTextGrp:Sprite;

	var cacheCount:Int;
	var currentTime:Float;
	var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10)
	{
		super();
		visible = true;

		outlineTextGrp = new Sprite();
		addChild(outlineTextGrp);

		mainText = new TextField();
		mainText.x = x;
		mainText.y = y;
		addChild(mainText);

		var outlinePosArray:Array<Array<Int>> = [];

		// stolen from FlxText
		outlinePosArray.push([-1, -1]); // upper-left
		outlinePosArray.push([1, 0]); // upper-middle
		outlinePosArray.push([1, 0]); // upper-right
		outlinePosArray.push([0, 1]); // middle-right
		outlinePosArray.push([0, 1]); // lower-right
		outlinePosArray.push([-1, 0]); // lower-middle
		outlinePosArray.push([-1, 0]); // lower-left
		outlinePosArray.push([0, -1]); // lower-left

		for (pos in outlinePosArray)
		{
			var outlineText:TextField = new TextField();
			outlineText.x = x + pos[0];
			outlineText.y = y + pos[1];
			outlineTextGrp.addChild(outlineText);
		}

		framesPerSecond = 0;

		mainText.selectable = false;
		mouseEnabled = false;
		mainText.defaultTextFormat = new TextFormat(Paths.location.get('ui/fonts/vcr.ttf'), 12, 0xFFFFFF);
		mainText.text = '';

		for (i in 0...outlineTextGrp.numChildren)
		{
			var outlineText:TextField = cast outlineTextGrp.getChildAt(i);
			outlineText.selectable = false;
			outlineText.defaultTextFormat = new TextFormat(Paths.location.get('ui/fonts/vcr.ttf'), 12, 0x000000);
			outlineText.text = '';
		}

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	override function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount:Int = times.length;
		framesPerSecond = Math.round(((currentCount + cacheCount) / 2) * (60 / 64));

		if (currentCount != cacheCount)
		{
			mainText.text = getFramesPerSecond() + getRandomAccessMemory();

			for (i in 0...outlineTextGrp.numChildren)
			{
				var outlineText:TextField = cast outlineTextGrp.getChildAt(i);
				outlineText.text = getFramesPerSecond() + getRandomAccessMemory();
			}
		}

		cacheCount = currentCount;

		super.__enterFrame(cast deltaTime);
	}

	function getFramesPerSecond():String
	{
		return 'FPS: ' + (framesPerSecond ?? 0) + '\n';
	}

	function getRandomAccessMemory():String
	{
		if (randomAccessMemory != null)
		{
			var formattedBytes:String = FlxStringUtil.formatBytes(randomAccessMemory);

			if (formattedBytes == '0MB') // mustve broke on our end!
				return '';

			return 'MEM: ' + formattedBytes;
		}

		return '';
	}

	function get_randomAccessMemory():Null<Float>
	{
		#if cpp
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
		#elseif hl
		return hl.Gc.stats().currentMemory;
		#elseif (js && html5)
		if (untyped __js__("(window.performance && window.performance.memory)"))
			return untyped __js__("window.performance.memory.usedJSHeapSize");
		#end

		return null;
	}
}
