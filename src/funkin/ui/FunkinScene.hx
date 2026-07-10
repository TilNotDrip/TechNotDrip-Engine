package funkin.ui;

import funkin.events.ConductorEvent;
import funkin.events.FunkinEvent;
import funkin.events.IEventReceiver;
import h2d.Scene;

// TODO: Implement something like a `FlxSubState` from HaxeFlixel.
class FunkinScene extends Scene implements IEventDispatcher
{
  public function new()
  {
    super();
    defaultSmooth = true; // TODO: change this for a antialiasing option

    Conductor.instance.stepHit.add(stepHit);
    Conductor.instance.beatHit.add(beatHit);
    Conductor.instance.measureHit.add(measureHit);
  }

  public function dispatchFunkinEvent(event:FunkinEvent):Void
  {
    // make sure to add modules here
  }

  override function dispose():Void
  {
    Conductor.instance.stepHit.remove(stepHit);
    Conductor.instance.beatHit.remove(beatHit);
    Conductor.instance.measureHit.remove(measureHit);

    super.dispose();
  }

  function stepHit():Void
  {
    final event:ConductorEvent = new ConductorEvent(STEP, Conductor.instance);
    dispatchFunkinEvent(event);
  }

  function beatHit():Void
  {
    final event:ConductorEvent = new ConductorEvent(STEP, Conductor.instance);
    dispatchFunkinEvent(event);
  }

  function measureHit():Void
  {
    final event:ConductorEvent = new ConductorEvent(STEP, Conductor.instance);
    dispatchFunkinEvent(event);
  }
}
