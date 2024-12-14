package funkin.util;

import funkin.data.song.Song;
import funkin.structures.WeekStructure;
import haxe.Json;

class Week
{
	/**
	 * The identifier name for this week.
	 */
	public final id:String = null;

	/**
	 * The data stored for this week.
	 */
	final data:WeekStructure = null;

	public function new(id:String)
	{
		this.id = id;
		data = buildData();
	}

	public function toString():String
	{
		return 'Week ($id)';
	}

	function buildData():WeekStructure
	{
		var weekData:WeekStructure = null;

		try
		{
			weekData = cast Json.parse(Paths.content.json('ui/story/weeks/' + id));
		}
		catch (e:Exception)
		{
			trace('[WARNING]: Week Data could not be loaded! ($id) More details: ${e.message}');
			return null;
		}

		return weekData;
	}

	public function getBGColor():FlxColor
	{
		return FlxColor.fromString(data?.background ?? '#F9CF51');
	}

	public function getMotto():String
	{
		return data?.motto ?? 'idfk it didnt load';
	}

	public function getDisplaySongNames():Array<String>
	{
		var songIds:Array<String> = data?.songs ?? [];
		var displayNames:Array<String> = [];

		for (id in songIds)
		{
			var songObject:Song = Song.getSongByID(id);
			var songName:String = songObject?.getDisplayName('default') ?? id;
			displayNames.push(songName);
		}

		return displayNames;
	}

	public function buildSprites(?sprGroup:FunkinSpriteGroup = null):FunkinSpriteGroup
	{
		var sprGrp:FunkinSpriteGroup = sprGroup ?? new FunkinSpriteGroup();

		for (spriteStructure in data?.sprites ?? [])
		{
			var spr:FunkinSprite = FunkinSpriteUtil.createFromStructure(spriteStructure);
			sprGrp.add(spr);
		}

		return sprGrp;
	}

	/**
	 * @return Returns all weeks that are found within the game.
	 */
	public static function fetchAllWeeks():Array<Week>
	{
		var weeksToReturn:Array<Week> = [];

		for (weekFile in Paths.location.scan('ui/story/weeks', '.json', false, FILE, false))
		{
			var week:Week = new Week(weekFile);
			weeksToReturn.push(week);
		}

		weeksToReturn.sort((a:Week, b:Week) ->
		{
			return (a.data?.storyPosition ?? 0) - (b.data?.storyPosition ?? 0);
		});

		return weeksToReturn;
	}
}
