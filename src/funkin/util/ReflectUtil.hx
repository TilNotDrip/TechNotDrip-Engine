package funkin.util;

class ReflectUtil
{
	/**
	 * Deep merges `thing1` into `thing2`.
	 * @param thing1 The thing you want to merge in
	 * @param thing2 The thing that is getting merged into
	 * @param overwrite If you want to just overwrite everything.
	 * @return `thing2`
	 */
	public static function deepMerge(thing1:Dynamic, thing2:Dynamic, ?overwrite:Bool = false):Dynamic
	{
		var toMerge:Array<Array<Dynamic>> = [[thing1, thing2]];
		while (toMerge.length > 0)
		{
			var data:Array<Dynamic> = toMerge.shift();
			for (field in Reflect.fields(data[0]))
			{
				if (overwrite || !Reflect.hasField(data[1], field))
				{
					Reflect.setField(data[1], field, Reflect.field(data[0], field));
				}
				else if (Reflect.isObject(Reflect.field(data[0], field)))
				{
					toMerge.push([Reflect.field(data[0], field), Reflect.field(data[1], field)]);
				}
			}
		}

		return thing2;
	}
}
