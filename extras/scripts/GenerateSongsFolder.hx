package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class GenerateSongsFolder
{
	public static function main()
	{
		var songsToGenerate:Array<Array<String>> = [];
		var generateText:Array<String> = File.getContent('./songsToGenerate.txt').split('\n');

		for (i in generateText)
		{
			songsToGenerate.push(i.split(' - '));
		}

		for (song in songsToGenerate)
		{
			var yeah = {
				"name": song[1]
			};
			var yeahAsString:String = Json.stringify(yeah, null, '\t').replace('\\r', '');

			FileSystem.createDirectory('./' + song[0]);
			File.saveContent('./' + song[0] + '/metadata.json', yeahAsString);
		}
	}

	static function print(string:String)
	{
		Sys.stdout().writeString(string + '\n');
	}
}
