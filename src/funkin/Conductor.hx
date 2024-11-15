package funkin;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxSignal;

/*
	CONDUCTOR TODO:
	* Add time changes, so most things arent hardcoded
 */
//

/**
 * The conductor is an class that handles most of the music timing.
 */
class Conductor implements IFlxDestroyable
{
	/**
	 * Signal fired when this instance advances to a new step.
	 */
	public var stepHit:FlxSignal;

	/**
	 * Signal fired when this instance advances to a new beat.
	 */
	public var beatHit:FlxSignal;

	/**
	 * Signal fired when this instance advances to a new section.
	 */
	public var sectionHit:FlxSignal;

	/**
	 * The current step.
	 */
	public var curStep:Int;

	/**
	 * The current beat.
	 */
	public var curBeat:Int;

	/**
	 * The current section.
	 */
	public var curSection:Int;

	/**
	 * Timestamp of the music that the conductor will follow.
	 * Should be in miliseconds.
	 */
	public var time(default, set):Float;

	/**
	 * The bpm of the music that the conductor will follow.
	 * TODO: tie this to a time change instead.
	 */
	public var bpm:Float;

	/**
	 * How many steps in a beat there are.
	 * TODO: tie this to a time change.
	 */
	public var beatSteps:Int = 4;

	/**
	 * How many beats in a section there are.
	 * TODO: tie this to a time change.
	 */
	public var sectionBeats:Int = 4;

	/**
	 * The length between a beat, in miliseconds.
	 */
	public var crochet(get, null):Float;

	/**
	 * The length between a step, in miliseconds.
	 */
	public var stepCrochet(get, null):Float;

	/**
	 * The length between a section, in miliseconds.
	 */
	public var sectionCrochet(get, null):Float;

	public function new()
	{
		stepHit = new FlxSignal();
		beatHit = new FlxSignal();
		sectionHit = new FlxSignal();

		bpm = 100;
		time = 0;
	}

	/**
	 * Updates the current conductor time.
	 * @param songTime The time to set it to. If not specified the FlxG.sound.music time will be used instead.
	 */
	public function update(?songTime:Float):Void
	{
		if (songTime != null)
		{
			time = songTime;
		}
		else
		{
			time = FlxG.sound.music.time ?? 0.0;
		}
	}

	/**
	 * Cleans up this Conductor to the best of our abilities.
	 */
	public function destroy():Void
	{
		stepHit.destroy();
		beatHit.destroy();
		sectionHit.destroy();
	}

	function set_time(value:Float):Float
	{
		time = value;

		var oldStep:Int = curStep;
		var oldBeat:Int = curBeat;
		var oldSection:Int = curSection;

		curStep = Math.floor(time / stepCrochet);
		curBeat = Math.floor(time / crochet);
		curSection = Math.floor(time / sectionCrochet);

		if (oldStep != curStep)
			stepHit.dispatch();

		if (oldBeat != curBeat)
			beatHit.dispatch();

		if (oldSection != curSection)
			sectionHit.dispatch();

		return value;
	}

	function get_crochet():Float
	{
		return calculateCrochet(bpm);
	}

	function get_stepCrochet():Float
	{
		return crochet / beatSteps;
	}

	function get_sectionCrochet():Float
	{
		return crochet * sectionBeats;
	}

	/**
	 * Calculate the crochet, which is the length between a beat.
	 * @param bpm The bpm to use for calculating.
	 * @return The crochet, in miliseconds.
	 */
	inline static function calculateCrochet(bpm:Float):Float
	{
		return ((60 / bpm) * 1000);
	}
}
