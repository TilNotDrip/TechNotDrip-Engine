package funkin.events;

class FunkinEvent
{
  /**
   * If the behavior associated with this event can be prevented.
   */
  public var cancellable(default, null):Bool;

  /**
   * Whether the event has been canceled, meaning that behavior should be prevented.
   */
  public var cancelled(default, null):Bool;

  /**
   * Whether the event should continue to be triggered on additional targets.
   */
  public var propagate(default, null):Bool;

  public function new(cancellable:Bool = false):Void
  {
    this.cancellable = cancellable;
    this.cancelled = false;
    this.propagate = true;
  }

  /**
   * Cancel this event.
   */
  public function cancel():Void
  {
    if (!cancellable)
      return;

    cancelled = true;
  }

  /**
   * Call this function to stop any other receivers from receiving this event.
   */
  public function stopPropagation():Void
  {
    propagate = false;
  }
}
