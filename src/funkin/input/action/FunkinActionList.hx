package funkin.input.action;

import funkin.input.FunkinInput.FunkinInputState;

@:build(funkin.input.action.FunkinActionMacro.build())
class FunkinActionList
{
  /**
   * Anything that is bound.
   */
  public var ANY(get, never):Bool;

  function get_ANY():Bool
  {
    for (input in parent.inputs)
    {
      if (input.check(state))
        return true;
    }

    return false;
  }

  var state:FunkinInputState;
  var parent:FunkinControls;

  public function new(parent:FunkinControls, state:FunkinInputState)
  {
    this.parent = parent;
    this.state = state;
  }

  function check(action:FunkinActionType):Bool
  {
    for (input in parent.inputs)
    {
      if (input.action != action)
        continue;

      return input.check(state);
    }

    return false;
  }
}
