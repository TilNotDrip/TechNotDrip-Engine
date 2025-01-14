package funkin.states;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.util.FlxSort;
import funkin.substates.FunkinTransition;
import funkin.util.Controls;
import haxe.Timer;

/**
 * A FunkinState is a regular FlxState which adds more music functionality for it (etc. making objects play an animation on a beat hit).
 */
class FunkinState extends FlxState
{
	var controls(get, never):Controls;

	inline function get_controls():Controls
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

		#if FUNKIN_DISCORD_RPC
		DiscordRPC.clearValues();
		#end

		super();
	}

	override public function create():Void
	{
		super.create();
		openSubState(new FunkinTransition(true));
	}

	override public function destroy():Void
	{
		conductor.destroy();
		conductor = null;

		super.destroy();
	}

	override public function startOutro(onOutroComplete:() -> Void):Void
	{
		if (subState == null || !Std.isOfType(subState, FunkinTransition))
			openSubState(new FunkinTransition(false, onOutroComplete));
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
