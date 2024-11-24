package funkin.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class ControlsMacro
{
	public static final variablesToAdd:Array<String> = [
		'UI_UP',
		'UI_DOWN',
		'UI_LEFT',
		'UI_RIGHT',
		'NOTE_LEFT',
		'NOTE_DOWN',
		'NOTE_UP',
		'NOTE_RIGHT',
		'ACCEPT',
		'BACK',
		'PAUSE',
		'RESET'
	];

	public static final variablesWithRandP:Array<String> = [
		'UI_UP',
		'UI_DOWN',
		'UI_LEFT',
		'UI_RIGHT',
		'NOTE_LEFT',
		'NOTE_DOWN',
		'NOTE_UP',
		'NOTE_RIGHT'
	];

	public static function build():Array<Field>
	{
		#if macro
		var fields = Context.getBuildFields();
		var pos = Context.currentPos();

		for (variableName in variablesToAdd)
		{
			if (variablesWithRandP.contains(variableName))
			{
				fields.push({
					name: variableName + "_R",
					access: [Access.APublic],
					kind: FieldType.FVar(macro :Bool, macro $v{false}),
					pos: pos
				});

				fields.push({
					name: variableName + "_P",
					access: [Access.APublic],
					kind: FieldType.FVar(macro :Bool, macro $v{false}),
					pos: pos
				});
			}

			fields.push({
				name: variableName,
				access: [Access.APublic],
				kind: FieldType.FVar(macro :Bool, macro $v{false}),
				pos: pos
			});
		}

		return fields;
		#else
		return null;
		#end
	}
}
