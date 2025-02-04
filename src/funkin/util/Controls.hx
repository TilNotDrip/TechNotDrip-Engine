package funkin.util;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxSignal;
import funkin.macros.ControlsMacro;
import haxe.ds.Either;

/**
 * The base controls input manager for TechNotDrip Engine.
 */
@:build(funkin.macros.ControlsMacro.build())
class Controls implements IFlxDestroyable
{
	/**
	 * The current and main instance of this Controls class.
	 */
	public static var instance(get, never):Controls;

	static var _instance:Null<Controls> = null;

	static function get_instance():Controls
	{
		if (_instance == null)
			_instance = new Controls(Save.instance.getControls(), FlxG.gamepads.getFirstActiveGamepad());

		return _instance;
	}

	/**
	 * @return Returns the default binds for controls.
	 */
	public static function getDefaultMappings():ControlMappings
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

	/**
	 * A signal that gets sent once a bind gets pressed.
	 */
	public var pressed:FlxSignal;

	/**
	 * A signal that gets sent once a bind gets released.
	 */
	public var released:FlxSignal;

	var pressJustDispatched:Bool = false;
	var releaseJustDispatched:Bool = false;

	public function new(mappings:ControlMappings, gamepad:FlxGamepad)
	{
		this.mappings = mappings;
		this.gamepad = gamepad;

		pressed = new FlxSignal();
		released = new FlxSignal();

		FlxG.signals.preUpdate.add(update);
	}

	public function destroy():Void
	{
		FlxG.signals.preUpdate.remove(update);
	}

	function update():Void
	{
		for (variableName in ControlsMacro.variablesToAdd)
		{
			if (ControlsMacro.variablesWithRandP.contains(variableName))
			{
				if (Reflect.field(this, variableName + '_P'))
					Reflect.setField(this, variableName + '_P', false);

				if (Reflect.field(this, variableName + '_R'))
					Reflect.setField(this, variableName + '_R', false);
			}
			else
			{
				if (Reflect.field(this, variableName))
					Reflect.setField(this, variableName, false);
			}
		}

		for (variableName in mappings.keys())
		{
			var mapping = mappings.get(variableName);

			var isPressed:Bool = false;

			#if FLX_KEYBOARD
			isPressed = FlxG.keys.anyJustPressed(mapping.keyboard);
			#end

			if (gamepad != null && gamepad.anyJustPressed(mapping.gamepad))
				isPressed = true;

			if (isPressed)
			{
				if (!Reflect.field(this, variableName))
				{
					Reflect.setField(this, variableName, true);

					if (ControlsMacro.variablesWithRandP.contains(variableName))
						Reflect.setField(this, variableName + '_P', true);

					if (!pressJustDispatched)
					{
						pressed.dispatch();
						pressJustDispatched = true;
					}
					else
					{
						pressJustDispatched = false;
					}
				}
			}

			var isReleased:Bool = false;

			#if FLX_KEYBOARD
			isReleased = FlxG.keys.anyJustReleased(mapping.keyboard);
			#end

			if (gamepad != null && gamepad.anyJustReleased(mapping.gamepad))
				isReleased = true;

			if (isReleased)
			{
				if (Reflect.field(this, variableName))
				{
					Reflect.setField(this, variableName, false);

					if (ControlsMacro.variablesWithRandP.contains(variableName))
						Reflect.setField(this, variableName + '_R', true);

					if (!releaseJustDispatched)
					{
						released.dispatch();
						releaseJustDispatched = true;
					}
					else
					{
						releaseJustDispatched = false;
					}
				}
			}
		}
	}
}

typedef ControlMappings = Map<String, {keyboard:Array<Int>, gamepad:Array<Int>}>;
