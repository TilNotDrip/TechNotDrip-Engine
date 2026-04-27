package funkin.input;

import flixel.util.FlxSignal.FlxTypedSignal;
import haxe.Int64;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;

class FunkinGamepadListener
{
  /**
   * The main instance.
   */
  public static var instance(get, never):FunkinGamepadListener;

  static var _instance:Null<FunkinGamepadListener> = null;

  static function get_instance():FunkinGamepadListener
  {
    if (_instance == null)
      _instance = new FunkinGamepadListener();

    return _instance;
  }

  /**
   * Signal that gets dispatched when any gamepad button is pressed.
   */
  public var onButtonDown:FlxTypedSignal<(Gamepad, GamepadButton, Int64) -> Void>;

  /**
   * Signal that gets dispatched when any gamepad button is released.
   */
  public var onButtonUp:FlxTypedSignal<(Gamepad, GamepadButton, Int64) -> Void>;

  public function new()
  {
    onButtonDown = new FlxTypedSignal<(Gamepad, GamepadButton, Int64) -> Void>();
    onButtonUp = new FlxTypedSignal<(Gamepad, GamepadButton, Int64) -> Void>();

    for (gamepad in Gamepad.devices)
      onConnect(gamepad);

    Gamepad.onConnect.add(onConnect);
  }

  function onConnect(gamepad:Gamepad):Void
  {
    gamepad.onButtonDownPrecise.add(buttonDown.bind(gamepad, _, _));
    gamepad.onButtonUpPrecise.add(buttonUp.bind(gamepad, _, _));
    gamepad.onDisconnect.add(onDisconnect.bind(gamepad));
  }

  function onDisconnect(gamepad:Gamepad):Void
  {
    gamepad.onButtonDownPrecise.remove(buttonDown.bind(gamepad, _, _));
    gamepad.onButtonUpPrecise.remove(buttonUp.bind(gamepad, _, _));
  }

  function buttonDown(gamepad:Gamepad, button:GamepadButton, timestamp:Int64):Void
  {
    onButtonDown.dispatch(gamepad, button, timestamp);
  }

  function buttonUp(gamepad:Gamepad, button:GamepadButton, timestamp:Int64):Void
  {
    onButtonUp.dispatch(gamepad, button, timestamp);
  }
}
