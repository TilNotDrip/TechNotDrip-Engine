package funkin.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class MonitorMacro
{
	/**
	 * Builds this macro.
	 * @return Fields.
	 */
	public static macro function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();

		#if macro
		var pos:Position = Context.currentPos();

		switch (Context.getLocalType())
		{
			case TInst(t, params):
				if (t.get().isInterface || t.get().isExtern || t.get().meta.has(':generic'))
					return fields;
			default:
				return fields;
		}

		var newFields:Array<Field> = [];
		for (field in fields)
		{
			if (field.access.contains(AMacro) || field.access.contains(AExtern) || field.access.contains(AInline) || field.kind.getName() != "FFun")
				continue;

			var func:Function = field.kind.getParameters()[0];
			if (func.expr == null)
				continue;

			var hasInjectedToReturn:Bool = injectBefoReturn(func.expr,
				macro funkin.macros.MonitorMacro.setTime(___times, $v{Context.getLocalClass().get().name + "." + field.name},
					haxe.Timer.stamp() - ___callTime));
			if (hasInjectedToReturn)
			{
				func.expr = macro
					{
						var ___callTime:Float = haxe.Timer.stamp();
						${func.expr};
					};
			}
			else
			{
				func.expr = macro
					{
						var ___callTime:Float = haxe.Timer.stamp();
						${func.expr};
						funkin.macros.MonitorMacro.setTime(___times, $v{Context.getLocalClass().get().name + "." + field.name},
							haxe.Timer.stamp() - ___callTime);
					};
			}

			field.kind = FFun(func);
			fields.remove(field);
			newFields.push(field);
		}

		fields.push({
			name: "___times",
			access: [Access.AStatic],
			kind: FieldType.FVar(macro :Map<String, Float>, macro $v{new Map<String, Float>()}),
			pos: pos,
		});

		fields = fields.concat(newFields);
		#end

		return fields;
	}

	static function injectBefoReturn(expr:haxe.macro.Expr, inj:haxe.macro.Expr, ?injected:Bool = false)
	{
		switch (expr?.expr)
		{
			case EWhile(_, expr, _):
				injectBefoReturn(expr, inj, injected);
			case EIf(_, expr, eelse): // else will be ignored
				injectBefoReturn(expr, inj, injected);
				if (eelse != null)
					injectBefoReturn(eelse, inj, injected);
			case EFor(_, expr):
				injectBefoReturn(expr, inj, injected);
			case ETry(expr, catches):
				for (cat in catches)
				{
					injectBefoReturn(cat.expr, inj, injected);
				}
				injectBefoReturn(expr, inj, injected);
			case EUntyped(expr):
				injectBefoReturn(expr, inj, injected);
			case ETernary(_, expr, eelse):
				injectBefoReturn(expr, inj, injected);
				if (eelse != null)
					injectBefoReturn(eelse, inj, injected);
			case ESwitch(expr, cases, _):
				for (cas in cases)
				{
					if (cas.expr != null)
						injectBefoReturn(cas.expr, inj, injected);
				}
				injectBefoReturn(expr, inj, injected);
			case EParenthesis(expr):
				injectBefoReturn(expr, inj, injected);
			case EBlock(exprs):
				for (i => e in exprs.copy())
				{
					if (inj != e && isReturn(e))
					{
						exprs.insert(i, inj);
						injected = true;
					}
				}
			default:
		}
		return injected;
	}

	static function isReturn(expr:haxe.macro.Expr):Bool
	{
		switch (expr?.expr)
		{
			case EReturn(_):
				return true;
			default:
				return false;
		}
	}

	/**
	 * Sets completion time.
	 * @param map The time to set.
	 * @param k Class name.
	 * @param v Time to complete.
	 */
	public static function setTime(map:Map<String, Float>, k:String, v:Float)
	{
		if (v < 0.01 || map.get(k) > v)
			return;
		map.set(k, v);
		#if !macro
		FlxG.log.warn('Lag: $k -> ${v}s');
		#end
	}
}
