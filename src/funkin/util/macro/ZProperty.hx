package funkin.util.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

@:dox(hide)
class ZProperty
{
  /**
   * Builds the field for the `z` property.
   * @return New `z` field.
   */
  public static macro function buildZProperty():Array<Field>
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

  /**
   * Builds the field for the `rearrange` function.
   * @return New `rearrange` field.
   */
  public static macro function buildRearrangeFunction():Array<Field>
  {
    var fields:Array<Field> = Context.getBuildFields();

    fields.push({
      name: 'rearrange',
      doc: 'Rearranges all FlxBasic objects by their Z value.',
      access: [APublic],
      meta: null,
      pos: Context.currentPos(),
      kind: FFun({
        args: [],
        params: null,
        ret: macro :Void,
        expr: macro
        {
          this.sort((i:Int, basic1:flixel.FlxBasic, basic2:flixel.FlxBasic) ->
          {
            return flixel.util.FlxSort.byValues(i, basic1.z, basic2.z);
          }, flixel.util.FlxSort.ASCENDING);
        },
      })
    });

    return fields;
  }
}
#end
