package funkin.util.macro;

#if !display
#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

@:dox(hide)
class AnimPriority
{
  /**
   * Builds the field for the `priority` property.
   * @return New `priority` field.
   */
  public static macro function build():Array<Field>
  {
    var fields:Array<Field> = Context.getBuildFields();

    fields.push({
      name: 'priority',
      doc: 'The current priority that this animation has over upcoming animations.',
      access: [Access.APublic],
      kind: FieldType.FVar(macro :Int, macro $v{0}),
      pos: Context.currentPos(),
    });

    return fields;
  }
}
#end
#end
