package funkin.input;

import funkin.input.action.FunkinActionType;

class FunkinInput
{
  /**
   * The action this input belongs to.
   */
  public var action:FunkinActionType;

  var parent:FunkinControls;

  var keysDown:Array<Int>;
  var buttonsDown:Array<Int>;
  var justDidTimer:Int;

  public function new(action:FunkinActionType, parent:FunkinControls)
  {
    this.action = action;
    this.parent = parent;

    keysDown = [];
    buttonsDown = [];
    justDidTimer = 0;
  }

  /**
   * Checks if `this` input satisfies an input state.
   * @param state The input state to check for.
   * @return If the input state has satisfied results.
   */
  public function check(state:FunkinInputState):Bool
  {
    return switch (state)
    {
      case JustPressed: pressed && justDidTimer > 0;
      case Pressed: pressed;
      case JustReleased: !pressed && justDidTimer > 0;
      case Released: !pressed;
      case Repeat: pressed && (justDidTimer > 0 || parent.turboActive);
    }
  }

  /**
   * Resets the input.
   */
  public function reset():Void
  {
    keysDown = [];
    buttonsDown = [];
    justDidTimer = 0;
  }

  /**
   * If the input is currently pressed down.
   */
  public var pressed(get, never):Bool;

  inline function get_pressed():Bool
  {
    return keysDown.length > 0;
  }

  @:allow(funkin.input.FunkinControls)
  function keyDown(id:Int):Void
  {
    if (keysDown.contains(id))
      return;

    keysDown.push(id);
    justDidTimer = 2;
  }

  @:allow(funkin.input.FunkinControls)
  function keyUp(id:Int):Void
  {
    if (!keysDown.contains(id))
      return;

    keysDown.remove(id);
    justDidTimer = 2;
  }

  @:allow(funkin.input.FunkinControls)
  function buttonDown(id:Int):Void
  {
    if (buttonsDown.contains(id))
      return;

    buttonsDown.push(id);
    justDidTimer = 2;
  }

  @:allow(funkin.input.FunkinControls)
  function buttonUp(id:Int):Void
  {
    if (!buttonsDown.contains(id))
      return;

    buttonsDown.remove(id);
    justDidTimer = 2;
  }

  @:allow(funkin.input.FunkinControls)
  function update():Void
  {
    if (justDidTimer > 0)
      justDidTimer--;
  }
}

enum FunkinInputState
{
  JustPressed;
  Pressed;
  JustReleased;
  Released;
  Repeat;
}
