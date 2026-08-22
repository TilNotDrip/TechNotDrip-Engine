package funkin.util;

import haxe.Constraints.Function;

@:genericBuild(funkin.macro.SignalMacro.build())
class Signal<T:Function>
{
  var listeners:Array<funkin.util.Signal.Listener<T>>;

  public function new()
  {
    listeners = [];
  }

  public function add(callback:T, ?priority:Int = 1000, ?once:Bool = false):Void
  {
    listeners.push({
      callback: callback,
      priority: priority,
      once: once
    });

    listeners.sort((a, b) -> b.priority - a.priority);
  }

  public function addOnce(callback:T, ?priority:Int = 1000):Void
  {
    add(callback, priority, true);
  }

  public function has(listener:T):Bool
  {
    var matchedListeners:Array<funkin.util.Signal.Listener<T>> = listeners.filter(l -> Reflect.compareMethods(l.callback, listener));
    return matchedListeners.length > 0;
  }

  public function remove(listener:T):Void
  {
    var matchedListeners:Array<funkin.util.Signal.Listener<T>> = listeners.filter(l -> Reflect.compareMethods(l.callback, listener));
    while (matchedListeners.length > 0)
    {
      final toRemove:Null<funkin.util.Signal.Listener<T>> = matchedListeners.shift();

      if (toRemove != null)
        listeners.remove(toRemove);
    }
  }

  public function removeAll():Void
  {
    listeners.resize(0);
  }

  public function dispose():Void
  {
    listeners = null;
  }
}

typedef Listener<T> =
{
  callback:T,
  priority:Int,
  once:Bool
};
