package funkin.input;

import flixel.addons.input.FlxControlInputType;
import flixel.addons.input.FlxControls;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

/**
 * The base controls input manager for TechNotDrip Engine.
 *
 * TODO: Til wants to skin flixel-controls... fine...
 */
class FunkinControls extends FlxControls<ControlAction>
{
  /**
   * The current and main instance of this FunkinControls class.
   */
  public static var instance(get, never):FunkinControls;

  static var _instance:Null<FunkinControls> = null;

  static function get_instance():FunkinControls
  {
    if (_instance == null)
      _instance = new FunkinControls(Save.instance.getControls(), FlxG.gamepads.getFirstActiveGamepad());

    return _instance;
  }

  /**
   * Internal, used for naming FlxControls.
   */
  private static var CONTROL_ID:Int = -1;

  /**
   * @return Returns the default binds for controls.
   */
  public static function getDefaultControlMappings():ControlMappings
  {
    return [
      'UI_UP' => {keyboard: [87, 38], gamepad: [11, 34]},
      'UI_DOWN' => {keyboard: [83, 40], gamepad: [12, 36]},
      'UI_LEFT' => {keyboard: [65, 37], gamepad: [13, 37]},
      'UI_RIGHT' => {keyboard: [68, 39], gamepad: [14, 35]},
      'NOTE_UP' => {keyboard: [87, 38], gamepad: [11, 3]},
      'NOTE_DOWN' => {keyboard: [83, 40], gamepad: [12, 0]},
      'NOTE_LEFT' => {keyboard: [65, 37], gamepad: [13, 2]},
      'NOTE_RIGHT' => {keyboard: [68, 39], gamepad: [14, 1]},
      'ACCEPT' => {keyboard: [32, 13], gamepad: [0, 7]},
      'BACK' => {keyboard: [8, 27], gamepad: [1]},
      'PAUSE' => {keyboard: [13, 27], gamepad: [7]},
      'RESET' => {keyboard: [82], gamepad: []}
    ];
  }

  /**
   * The current mapping for the controls.
   */
  public var mappings:ControlMappings;

  /**
   * The gamepad thats connected to the users system.
   */
  public var gamepad:FlxGamepad = null;

  public function new(mappings:ControlMappings, gamepad:FlxGamepad)
  {
    this.mappings = mappings;
    this.gamepad = gamepad;
    super('FUNKIN_CONTROLS' + CONTROL_ID++);

    if (gamepad != null)
      setGamepadID(gamepad.id);

    FlxG.inputs.addInput(this);
  }

  function getDefaultMappings():ActionMap<ControlAction>
  {
    var toReturn:ActionMap<ControlAction> = new ActionMap<ControlAction>();

    for (key => mapping in mappings)
    {
      var enumKey:ControlAction = Type.createEnum(ControlAction, key);
      var value:Array<FlxControlInputType> = [];

      for (keyboardKey in mapping.keyboard)
        value.push(FlxControlInputType.fromKey(keyboardKey));

      for (gamepadKey in mapping.gamepad)
        value.push(FlxControlInputType.fromGamepad(gamepadKey));

      toReturn.set(enumKey, value);
    }

    return toReturn;
  }
}

enum ControlAction
{
  /**
   * Up Key for UI States.
   */
  UI_UP;

  /**
   * Down Key for UI States.
   */
  UI_DOWN;

  /**
   * Left Key for UI States.
   */
  UI_LEFT;

  /**
   * Right Key for UI States.
   */
  UI_RIGHT;

  /**
   * Up Key for PlayState.
   */
  NOTE_UP;

  /**
   * Down Key for PlayState.
   */
  NOTE_DOWN;

  /**
   * Left Key for PlayState.
   */
  NOTE_LEFT;

  /**
   * Right Key for PlayState.
   */
  NOTE_RIGHT;

  /**
   * The accept key. Used for selecting an item.
   */
  ACCEPT;

  /**
   * The back key. Used for going back a state.
   */
  BACK;

  /**
   * The pause key. Used for pausing the game.
   */
  PAUSE;

  /**
   * The reset key. Used for utterly annihilating Boyfriend's Testicles.
   */
  RESET;
}

typedef ControlMappings = Map<String, {keyboard:Array<Int>, gamepad:Array<Int>}>;
