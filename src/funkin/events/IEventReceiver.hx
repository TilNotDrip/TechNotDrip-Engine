package funkin.events;

/**
 * Defines an element which can receive script events.
 * For example, the PlayState dispatches the event to all its child elements.
 */
interface IEventDispatcher
{
  public function dispatchFunkinEvent(event:FunkinEvent):Void;
}
