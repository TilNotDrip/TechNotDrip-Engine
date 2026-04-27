package funkin.input;

import flixel.input.FlxInput;
import flixel.input.IFlxInputManager;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.input.action.FunkinActionList;
import funkin.input.action.FunkinActionType;
import haxe.Int64;
import haxe.ds.Either;
import lime.ui.Gamepad;
import lime.ui.GamepadButton;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import openfl.ui.Keyboard;

/**
 * The base controls input manager for TechNotDrip Engine.
 */
class FunkinControls implements IFlxInputManager
{
  /**
   * The current and main instance of this FunkinControls class.
   */
  public static var instance(get, never):FunkinControls;

  static var _instance:Null<FunkinControls> = null;

  static function get_instance():FunkinControls
  {
    if (_instance == null)
      _instance = new FunkinControls(Save.instance.getControls());

    return _instance;
  }

  /**
   * List for when an action is pressed.
   */
  public var pressed:FunkinActionList;

  /**
   * List for when an action is released.
   */
  public var released:FunkinActionList;

  /**
   * List for when an action was just pressed.
   */
  public var justPressed:FunkinActionList;

  /**
   * List for when an action was just released.
   */
  public var justReleased:FunkinActionList;

  /**
   * List for when an action was just pressed.
   *
   * If held down long enough, the action will start repeating rapidly until released.
   */
  public var repeat:FunkinActionList;

  /**
   * A signal that gets dispatched when an action gets pressed.
   */
  public var onKeyDown:FlxTypedSignal<(FunkinActionType, Int64) -> Void>;

  /**
   * A signal that gets dispatched when an action gets released.
   */
  public var onKeyUp:FlxTypedSignal<(FunkinActionType, Int64) -> Void>;

  /**
   * All input handlers.
   */
  public var inputs:Array<FunkinInput>;

  /**
   * The current mapping for the controls.
   */
  public var mappings:ControlMappings;

  var keyboardLookup:Map<KeyCode, Array<FunkinActionType>>;
  var gamepadLookup:Map<GamepadButton, Array<FunkinActionType>>;

  @:allow(funkin.input.FunkinInput)
  var turboActive:Bool = false;
  var turboTime:Float = 0;

  public function new(mappings:ControlMappings)
  {
    this.mappings = mappings;
    inputs = [];

    pressed = new FunkinActionList(this, Pressed);
    released = new FunkinActionList(this, Released);
    justPressed = new FunkinActionList(this, JustPressed);
    justReleased = new FunkinActionList(this, JustReleased);
    repeat = new FunkinActionList(this, Repeat);

    onKeyDown = new FlxTypedSignal<(FunkinActionType, Int64) -> Void>();
    onKeyUp = new FlxTypedSignal<(FunkinActionType, Int64) -> Void>();

    keyboardLookup = [];
    gamepadLookup = [];

    turboActive = false;
    turboTime = 0;

    for (actionString => mapping in mappings)
    {
      var actionEnum:FunkinActionType = Type.createEnum(FunkinActionType, actionString);
      inputs.push(new FunkinInput(actionEnum, this));

      for (key in mapping.keyboard)
      {
        var actionList:Array<FunkinActionType> = keyboardLookup.get(cast key) ?? [];
        if (!actionList.contains(actionEnum))
          actionList.push(actionEnum);

        keyboardLookup.set(cast key, actionList);
      }

      for (button in mapping.gamepad)
      {
        var actionList:Array<FunkinActionType> = gamepadLookup.get(cast button) ?? [];
        if (!actionList.contains(actionEnum))
          actionList.push(actionEnum);

        gamepadLookup.set(cast button, actionList);
      }
    }

    FlxG.stage.window.onKeyDownPrecise.add(keyDownHandle);
    FlxG.stage.window.onKeyUpPrecise.add(keyUpHandle);

    FunkinGamepadListener.instance.onButtonDown.add(buttonDownHandle);
    FunkinGamepadListener.instance.onButtonUp.add(buttonUpHandle);

    FlxG.inputs.addInput(this);
  }

  function keyDownHandle(keyCode:KeyCode, modifier:KeyModifier, timestamp:Int64):Void
  {
    final inputs:Array<FunkinInput> = getInputs(Left(keyCode));

    for (input in inputs)
    {
      var beforePressed:Bool = input.pressed;
      input.keyDown(cast keyCode);

      if (beforePressed != input.pressed)
        onKeyDown.dispatch(input.action, timestamp);
    }
  }

  function keyUpHandle(keyCode:KeyCode, modifier:KeyModifier, timestamp:Int64):Void
  {
    final inputs:Array<FunkinInput> = getInputs(Left(keyCode));

    for (input in inputs)
    {
      var beforePressed:Bool = input.pressed;
      input.keyUp(cast keyCode);

      if (beforePressed != input.pressed)
        onKeyUp.dispatch(input.action, timestamp);
    }
  }

  function buttonDownHandle(gamepad:Gamepad, button:GamepadButton, timestamp:Int64)
  {
    final inputs:Array<FunkinInput> = getInputs(Right(button));

    for (input in inputs)
    {
      var beforePressed:Bool = input.pressed;
      input.buttonDown(cast button);

      if (beforePressed != input.pressed)
        onKeyDown.dispatch(input.action, timestamp);
    }
  }

  function buttonUpHandle(gamepad:Gamepad, button:GamepadButton, timestamp:Int64)
  {
    final inputs:Array<FunkinInput> = getInputs(Right(button));

    for (input in inputs)
    {
      var beforePressed:Bool = input.pressed;
      input.buttonUp(cast button);

      if (beforePressed != input.pressed)
        onKeyUp.dispatch(input.action, timestamp);
    }
  }

  function getInputs(either:Either<KeyCode, GamepadButton>):Array<FunkinInput>
  {
    var actionList:Null<Array<FunkinActionType>> = switch (either)
    {
      case Left(v): keyboardLookup.get(v);
      case Right(v): gamepadLookup.get(v);
    };

    if (actionList == null)
      return [];

    return inputs.filter(input -> input != null && actionList.contains(input.action));
  }

  /**
   * Resets inputs.
   */
  public function reset():Void
  {
    for (input in inputs)
      input?.reset();
  }

  /**
   * Cleans up memory.
   */
  public function destroy():Void
  {
    FlxG.stage.window.onKeyDownPrecise.remove(keyDownHandle);
    FlxG.stage.window.onKeyUpPrecise.remove(keyUpHandle);

    FunkinGamepadListener.instance.onButtonDown.remove(buttonDownHandle);
    FunkinGamepadListener.instance.onButtonUp.remove(buttonUpHandle);

    inputs = [];
  }

  function update():Void
  {
    for (input in inputs)
      input?.update();

    updateTurbo(FlxG.elapsed);
  }

  function updateTurbo(elapsed:Float):Void
  {
    turboActive = false;

    if (pressed.ANY)
    {
      turboTime += FlxG.elapsed;

      turboActive = turboTime - Constants.TURBO_INITIAL_TIME >= Constants.TURBO_INTERVAL_TIME;
      if (turboActive)
        turboTime = Constants.TURBO_INITIAL_TIME;
    }
    else
    {
      turboTime = 0;
    }

    FlxG.watch.addQuick('turboActive', turboActive);
    FlxG.watch.addQuick('turboTime', turboTime);
  }

  function onFocus():Void {}

  function onFocusLost():Void
  {
    reset();
  }
}

typedef ControlMappings = Map<String, {keyboard:Array<KeyCode>, gamepad:Array<GamepadButton>}>;
