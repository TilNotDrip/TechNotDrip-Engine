package funkin.states;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.util.FlxSort;
import funkin.util.Controls;

/**
 * A FunkinState is a regular FlxState which adds more music functionality for it (etc. making objects play an animation on a beat hit).
 */
class FunkinState extends FlxState
{
	private var controls(get, never):Controls;

	inline private function get_controls():Controls
		return Controls.instance;

	/**
	 * The conductor that controls everything music-wise inside this state.
	 */
	public var conductor:Conductor = null;

	public function new()
	{
		conductor = new Conductor();
		conductor.stepHit.add(stepHit);
		conductor.beatHit.add(beatHit);
		conductor.sectionHit.add(sectionHit);

		super();
	}

	override public function update(elasped:Float):Void
	{
		conductor.update();
		super.update(elapsed);
	}

	override public function destroy():Void
	{
		conductor.destroy();
		conductor = null;

		super.destroy();
	}

	/**
	 * This function is called after the conductor step changes.
	 */
	public function stepHit():Void {}

	/**
	 * This function is called after the conductor beat changes.
	 */
	public function beatHit():Void {}

	/**
	 * This function is called after the conductor section changes.
	 */
	public function sectionHit():Void {}

	/**
	 * Rearranges all FlxBasic objects by their Z value.
	 */
	public function rearrange():Void
	{
		sort((i:Int, basic1:FlxBasic, basic2:FlxBasic) ->
		{
			return FlxSort.byValues(i, basic1.z, basic2.z);
		}, FlxSort.ASCENDING);
	}
}
