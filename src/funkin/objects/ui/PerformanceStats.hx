package funkin.objects.ui;

import flixel.util.FlxStringUtil;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * The performance stats TextField keeps track of FPS and Memory in-game.
 */
class PerformanceStats extends TextField
{
	/**
	 * How many frames have passed since the last second.
	 */
	public var framesPerSecond(default, null):Int;

	/**
	 * The amount of RAM the application is currently using.
	 */
	public var randomAccessMemory(get, null):Null<Float>;

	var cacheCount:Int;
	var currentTime:Float;
	var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		framesPerSecond = 0;

		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.location.get('ui/fonts/vcr.ttf'), 12, color);
		text = '';

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
		framesPerSecond = Math.round((currentCount + cacheCount) / 2);

		if (currentCount != cacheCount)
		{
			text = getFramesPerSecond() + getRandomAccessMemory();
		}

		cacheCount = currentCount;
	}

	function getFramesPerSecond():String
	{
		return 'FPS: ' + (framesPerSecond ?? 0) + '\n';
	}

	function getRandomAccessMemory():String
	{
		if (randomAccessMemory != null)
			return 'MEM: ' + FlxStringUtil.formatBytes(randomAccessMemory);

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
