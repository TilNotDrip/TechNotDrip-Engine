package funkin.macros;

#if !display
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

@:dox(hide)
class ZProperty
{
	/**
	 * Builds the field for the `z` property.
	 * @return New z field.
	 */
	public static macro function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();

		fields.push({
			name: 'z',
			doc: 'Z position of this object in world space.',
			access: [Access.APublic],
			kind: FieldType.FVar(macro :Int, macro $v{0}),
			pos: Context.currentPos(),
		});

		return fields;
	}
}
#end
#end
