package funkin.ui;

import flixel.FlxBasic;
import flixel.FlxSubState;
import flixel.util.FlxSort;
import funkin.input.FunkinControls;
import funkin.sound.Conductor;
import funkin.ui.FunkinState;
import haxe.Timer;

/**
 * A FunkinSubState is a regular FlxSubState which adds more music functionality for it (etc. making objects play an animation on a beat hit).
 */
class FunkinSubState extends FlxSubState
{
  var controls(get, never):FunkinControls;

  inline function get_controls():FunkinControls
    return FunkinControls.instance;

  /**
   * The conductor that controls everything music-wise inside this substate.
   */
  public var conductor:Conductor = null;

  /**
   * The parent FunkinState.
   */
  var parentState(get, never):FunkinState;

  function get_parentState():FunkinState
  {
    return cast(_parentState, FunkinState);
  }

  public function new()
  {
    conductor = new Conductor();
    conductor.stepHit.add(stepHit);
    conductor.beatHit.add(beatHit);
    conductor.sectionHit.add(sectionHit);

    super();
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
}
