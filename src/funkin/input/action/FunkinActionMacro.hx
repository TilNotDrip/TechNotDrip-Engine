package funkin.input.action;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class FunkinActionMacro
{
  /**
   * Enum to use for pulling actions.
   */
  public static final ACTION_ENUM:String = 'funkin.input.action.FunkinActionType';

  #if macro
  /**
   * Adds all actions to the action list.
   * @return Array<Field>
   */
  public static macro function build():Array<Field>
  {
    var fields:Array<Field> = Context.getBuildFields();
    var enumType:EnumType = getActionEnum();

    final pos:Position = Context.currentPos();
    final boolType:ComplexType = macro :Bool;

    for (enumName in enumType.names)
    {
      final enumField:Null<EnumField> = enumType.constructs.get(enumName);
      if (enumField == null)
        continue;

      var fullPath:Array<String> = enumType.pack.concat([enumType.name, enumName]);

      final getVarField:Field = {
        name: enumName,
        doc: enumField.doc,
        access: [APublic],
        kind: FProp('get', 'never', boolType),
        pos: pos
      };

      final getFuncField:Field = {
        name: 'get_${enumName}',
        access: [APrivate],
        pos: pos,
        kind: FFun({
          args: [],
          ret: boolType,
          expr: macro
          {
            return check($p{fullPath});
          }
        })
      };

      fields.push(getVarField);
      fields.push(getFuncField);
    }

    return fields;
  }

  static function getActionEnum():EnumType
  {
    return switch (Context.getType(ACTION_ENUM))
    {
      case TEnum(t, params):
        t.get();

      default:
        throw '"${ACTION_ENUM}" should be an enum.';
    }
  }
  #end
}
