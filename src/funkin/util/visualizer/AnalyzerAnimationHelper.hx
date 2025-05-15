package funkin.util.visualizer;

import funkin.vis.dsp.SpectralAnalyzer;

class AnalyzerAnimationHelper
{
	var analyzer:SpectralAnalyzer;

	var barCount:Int;
	var barHeight:Int;

	/**
	 * The sound to use for this analyzer.
	 */
	public var snd:FlxSound;

	/**
	 * Whether this analyzer is ready or not.
	 */
	public var ready(get, null):Bool;

	function get_ready():Bool
	{
		return snd != null && analyzer != null;
	}

	public function new(snd:FlxSound, barCount:Int, barHeight:Int)
	{
		this.snd = snd;
		this.barCount = barCount;
		this.barHeight = barHeight;
	}

	public function initAnalyzer(?peakHold:Int = 30):Void
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, barCount, 0.1, peakHold);

		#if desktop
		// On desktop it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
	}

	public var frameMap:Array<Int> = [];

	public function updateFFT():Void
	{
		var levels;
		try
		{
			levels = analyzer.getLevels();
		}
		catch (e)
		{
			trace('Couldn\'t load levels! $e');
			return;
		}

		frameMap = [];

		var len:Int = cast Math.min(barCount, levels.length);

		for (i in 0...len)
		{
			var animFrame:Int = Math.round(levels[i].value * barHeight);

			#if desktop
			// Web version scales with the Flixel volume level.
			// This line brings platform parity but looks worse.
			// animFrame = Math.round(animFrame * FlxG.sound.volume);
			#end

			animFrame = Math.floor(Math.min(barHeight, animFrame));
			animFrame = Math.floor(Math.max(0, animFrame));

			animFrame = Std.int(Math.abs(animFrame - barHeight)); // shitty dumbass flip, cuz dave got da shit backwards lol!

			frameMap[i] = animFrame;
		}
	}
}
