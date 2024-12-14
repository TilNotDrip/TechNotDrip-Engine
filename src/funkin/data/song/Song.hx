package funkin.data.song;

import flixel.sound.FlxSoundGroup;
import funkin.structures.SongStructure;

class Song
{
	static var cachedSongs:Map<String, Song>;

	/**
	 * Caches all songs to use later.
	 */
	public static function cacheSongs():Void
	{
		cachedSongs = new Map<String, Song>();

		for (file in Paths.location.scan('gameplay/songs', '.json', true, PATH_FILE, false))
		{
			if (!file.endsWith('metadata'))
				continue;

			var endLength:Int = file.length - 'metadata'.length - 1;
			var songName:String = file.substring('gameplay/songs/'.length, endLength);
			var song:Song = new Song(songName);
			cachedSongs.set(songName, song);
		}
	}

	/**
	 * Gets a song using it's ID.
	 * @param id The ID of the song to search for. 
	 * @return The Song Object.
	 */
	public static function getSongByID(id:String):Song
	{
		if (cachedSongs == null)
			cacheSongs();

		return cachedSongs.get(id);
	}

	/**
	 * The song ID.
	 */
	public final id:String;

	/**
	 * All the metadatas.
	 * id => structure
	 */
	public final metadatas:Map<String, SongMetadata>;

	public function new(id:String)
	{
		this.id = id;

		metadatas = new Map<String, SongMetadata>();

		for (variation in getVariations())
		{
			metadatas.set(variation, getSongMetadata(id, variation));
		}
	}

	/**
	 * Get the Display Name for this song.
	 * @param variation The variation to get the name from.
	 * @return The name.
	 */
	public function getDisplayName(variation:String = 'default'):String
	{
		var metadata:SongMetadata = metadatas.get(variation);
		return metadata.name;
	}

	static function getSongMetadata(id:String, variation:String):SongMetadata
	{
		var path:String = 'gameplay/songs/' + id + '/';

		if (variation != 'default')
			path += variation + '-';

		path += 'metadata';

		return cast haxe.Json.parse(Paths.content.json(path));
	}

	var _variations:Array<String>;

	/**
	 * Get all of the variations for this Song.
	 * @return The variations.
	 */
	public function getVariations():Array<String>
	{
		if (_variations != null)
			return _variations;

		_variations = ['default'];

		var queryPath:String = 'gameplay/songs/' + id;
		for (file in Paths.location.scan(queryPath, 'metadata.json', false, FILE, false))
		{
			if (file == '') // default
				continue;

			var variationWithoutDash:String = file.substring(0, file.length - 1);
			_variations.push(variationWithoutDash);
		}

		return _variations;
	}
}
