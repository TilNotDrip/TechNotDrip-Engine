package funkin.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
#end

class SignalMacro
{
  #if macro
  public static function build():Null<ComplexType>
  {
    final position:Position = Context.currentPos();
    final localType:Null<Type> = Context.getLocalType();

    var typeArgs:Null<Array<{name:String, opt:Bool, t:Type}>> = null;
    var typeResult:Null<Type> = null;
    var typeName:String = '';

    switch (localType)
    {
      case TInst(_.get() => t, [paramType]):
        switch (paramType)
        {
          case TFun(args, ret):
            typeArgs = args;
            typeResult = ret;
            typeName = createName(t, typeArgs, typeResult);
          default:
        }
      default:
    }

    if (typeArgs == null || typeResult == null)
      return null;

    final classPackage:Array<String> = typeName.split('.');
    final className:String = classPackage.pop();

    try
    {
      Context.getType(typeName);
    }
    catch (e:Dynamic)
    {
      final funcArgs:Array<FunctionArg> = [
        for (i => typeArg in typeArgs)
          {
            name: 'arg$i',
            opt: typeArg.opt,
            type: typeArg.t.toComplexType()
          }
      ];

      final funcArgNames:Array<Expr> = funcArgs.map(i -> Context.parse(i.name, position));
      final fnType:ComplexType = TFun(typeArgs, typeResult).toComplexType();

      final dispatchExpr:Expr = macro
        {
          var toRemove:Array<funkin.util.Signal.Listener<T>> = [];

          for (listener in this.listeners)
          {
            (cast listener.callback : $fnType)($a{funcArgNames});

            if (listener.once)
              toRemove.push(listener);
          }

          for (listener in toRemove)
            this.listeners.remove(listener);
        };

      var fields:Array<Field> = Context.getBuildFields();
      fields.push({
        name: 'dispatch',
        access: [APublic],
        kind: FFun({
          args: funcArgs,
          ret: macro :Void,
          expr: dispatchExpr
        }),
        pos: position
      });

      Context.defineType({
        pos: position,
        pack: classPackage,
        name: className,
        kind: TDClass(),
        fields: fields,
        params: [{name: 'T'}]
      });
    }

    return TPath({pack: classPackage, name: className, params: [TPType(TFun(typeArgs, typeResult).toComplexType())]});
  }

  static function createName(classType:ClassType, args:Array<ParameterArgument>, ret:Type):String
  {
    var toReturn:String = '';

    toReturn += classType.pack.join('.');
    if (classType.pack.length > 0)
      toReturn += '.';
    toReturn += classType.name;

    toReturn += '__';

    var funcResult:String = '';
    for (arg in args)
      funcResult += '${arg.t.toString()}->';
    funcResult += ret.toString();
    funcResult = StringTools.replace(funcResult, '->', '_');
    funcResult = StringTools.replace(funcResult, '.', '_');
    funcResult = StringTools.replace(funcResult, '<', '_');
    funcResult = StringTools.replace(funcResult, '>', '_');

    toReturn += funcResult;
    return toReturn;
  }
  #end
}

#if macro
typedef ParameterArgument =
{
  name:String,
  opt:Bool,
  t:Type
};
#end
