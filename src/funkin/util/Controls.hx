package funkin.util;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxSignal;
import funkin.macros.ControlsMacro;
import haxe.ds.Either;

@:build(funkin.macros.ControlsMacro.build())
class Controls implements IFlxDestroyable
{
	public static var instance(get, never):Controls;
	static var _instance:Null<Controls> = null;

	static function get_instance():Controls
	{
		if (_instance == null)
			_instance = new Controls(getDefaultMappings(), FlxG.gamepads.getFirstActiveGamepad());
		return _instance;
	}

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

	public var mappings:ControlMappings;
	public var gamepad:FlxGamepad = null;

	public var pressed:FlxSignal;
	public var released:FlxSignal;

	public function new(mappings:ControlMappings, gamepad:FlxGamepad)
	{
		this.mappings = mappings;
		this.gamepad = gamepad;

		FlxG.debugger.addTrackerProfile(new TrackerProfile(Controls, Reflect.fields(this)));
		FlxG.debugger.track(this);

		pressed = new FlxSignal();
		released = new FlxSignal();

		FlxG.signals.preUpdate.add(update);
	}

	public function destroy():Void
	{
		FlxG.signals.preUpdate.remove(update);
	}

	function update()
	{
		for (variableName in ControlsMacro.variablesWithRandP)
		{
			if (Reflect.field(this, variableName + '_P'))
				Reflect.setField(this, variableName + '_P', false);

			if (Reflect.field(this, variableName + '_R'))
				Reflect.setField(this, variableName + '_R', false);
		}

		for (variableName in ControlsMacro.variablesToAdd)
		{
			if (ControlsMacro.variablesWithRandP.contains(variableName))
				continue;

			if (Reflect.field(this, variableName))
				Reflect.setField(this, variableName, false);
		}

		var keysDown:Array<Either<FlxKey, FlxGamepadInputID>> = [];
		var keysReleased:Array<Either<FlxKey, FlxGamepadInputID>> = [];

		@:privateAccess
		for (key in FlxG.keys._keyListArray)
		{
			if (key != null)
			{
				if (key.justPressed)
					keysDown.push(Either.Left(key.ID));
				else if (key.justReleased)
					keysReleased.push(Either.Left(key.ID));
			}
		}

		if (gamepad != null)
		{
			@:privateAccess
			for (key in gamepad.buttons)
			{
				if (key != null)
				{
					if (key.justPressed)
						keysDown.push(Either.Right(key.ID));
					else if (key.justReleased)
						keysReleased.push(Either.Right(key.ID));
				}
			}
		}

		for (eitherKey in keysDown)
		{
			var key:Int = -1;
			var variableNames:Array<String> = [];

			switch (eitherKey)
			{
				case Left(keyy):
					key = cast keyy;
					variableNames = getControlNamesFromKey(key, false);

				case Right(keyy):
					key = cast keyy;
					variableNames = getControlNamesFromKey(key, true);
			}

			for (variableName in variableNames)
			{
				if (!Reflect.field(this, variableName))
				{
					Reflect.setField(this, variableName, true);

					if (ControlsMacro.variablesWithRandP.contains(variableName))
						Reflect.setField(this, variableName + '_P', true);

					pressed.dispatch();
				}
			}
		}

		for (eitherKey in keysReleased)
		{
			var key:Int = -1;
			var variableNames:Array<String> = [];

			switch (eitherKey)
			{
				case Left(keyy):
					key = cast keyy;
					variableNames = getControlNamesFromKey(key, false);

				case Right(keyy):
					key = cast keyy;
					variableNames = getControlNamesFromKey(key, true);
			}

			for (variableName in variableNames)
			{
				if (Reflect.field(this, variableName))
				{
					Reflect.setField(this, variableName, false);

					if (ControlsMacro.variablesWithRandP.contains(variableName))
						Reflect.setField(this, variableName + '_R', true);

					released.dispatch();
				}
			}
		}
	}

	function getControlNamesFromKey(key:Int, isGamepad:Bool):Array<String>
	{
		var controlNames:Array<String> = [];
		for (variableName in mappings.keys())
		{
			var mapping = mappings.get(variableName);

			if ((isGamepad ? mapping.gamepad : mapping.keyboard).contains(key) && !controlNames.contains(variableName))
				controlNames.push(variableName);
		}

		return controlNames;
	}
}

enum PressType
{
	PRESSED;
	JUST_PRESSED;
	RELEASED;
}

typedef ControlMappings = Map<String, {keyboard:Array<Int>, gamepad:Array<Int>}>;
