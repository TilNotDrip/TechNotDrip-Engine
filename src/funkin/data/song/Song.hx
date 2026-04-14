package funkin.data.song;

import flixel.sound.FlxSoundGroup;
import flixel.util.FlxSort;
import funkin.data.song.SongData;

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

    #if FLX_DEBUG
    FlxG.console.registerFunction('cacheSongs', cacheSongs);
    #end
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
   * variation id => structure
   */
  public final metadatas:Map<String, MetadataStructure>;

  /**
   * All the charts.
   * variation id => charts
   */
  public final charts:Map<String, Array<ChartArrayElement>>;

  /**
   * All the events.
   * variation id => events
   */
  public final events:Map<String, Array<EventData>>;

  public function new(id:String)
  {
    this.id = id;

    metadatas = new Map<String, MetadataStructure>();
    charts = new Map<String, Array<ChartArrayElement>>();
    events = new Map<String, Array<EventData>>();

    for (variation in getVariations())
    {
      metadatas.set(variation, getSongMetadata(id, variation));

      var chartJson:ChartStructure = getSongChart(id, variation);
      charts.set(variation, chartJson.charts);

      var eventsJson:EventsStructure = getSongEvents(id, variation);
      events.set(variation, eventsJson.events);
    }
  }

  /**
   * Get the Display Name for this song.
   * @param variation The variation to get the name from.
   * @return The name.
   */
  public function getDisplayName(variation:String = 'default'):String
  {
    var metadata:MetadataStructure = metadatas.get(variation);
    return metadata.name;
  }

  /**
   * Gets all the difficulties supported by `variation`.
   * @param variation The variation you want to search difficulties from. `null` for all variations.
   * @return The difficulties.
   */
  public function getDifficulties(variation:Null<String> = 'default'):Array<String>
  {
    var difficulties:Array<String> = [];
    var variationsToSearch:Array<String> = [];

    if (variation == null)
      variationsToSearch = getVariations().copy();
    else
      variationsToSearch = [variation];

    for (variation in variationsToSearch)
    {
      for (chartData in charts.get(variation))
      {
        if (!difficulties.contains(chartData.difficulty))
          difficulties.push(chartData.difficulty);
      }
    }

    difficulties.sort(function(a:String, b:String)
    {
      var indexA:Int = Constants.DEFAULT_DIFFICULTIES.indexOf(a);
      var indexB:Int = Constants.DEFAULT_DIFFICULTIES.indexOf(b);

      if (indexA == -1)
        indexA = Constants.DEFAULT_DIFFICULTIES.length;

      if (indexB == -1)
        indexB = Constants.DEFAULT_DIFFICULTIES.length;

      return FlxSort.byValues(FlxSort.ASCENDING, indexA, indexB);
    });

    return difficulties;
  }

  /**
   * Gets the chart for `difficulty` in `variation`.
   * @param variation The variation to check for.
   * @param difficulty The difficulty to check for.
   * @return The chart.
   */
  public function getChart(?variation:String = 'default', difficulty:String):ChartArrayElement
  {
    for (chart in charts.get(variation) ?? [])
    {
      if (chart.difficulty == difficulty)
        return chart;
    }

    return null;
  }

  static function getSongMetadata(id:String, variation:String):MetadataStructure
  {
    var path:String = 'gameplay/songs/' + id + '/';

    if (variation != 'default')
      path += variation + '-';

    path += 'metadata';

    var json:MetadataStructure = cast haxe.Json.parse(Paths.content.json(path));
    // TODO: version checking
    return json;
  }

  static function getSongChart(id:String, variation:String):ChartStructure
  {
    var path:String = 'gameplay/songs/' + id + '/';

    if (variation != 'default')
      path += variation + '-';

    path += 'chart';

    var json:ChartStructure = cast haxe.Json.parse(Paths.content.json(path));
    // TODO: version checking
    return json;
  }

  static function getSongEvents(id:String, variation:String):EventsStructure
  {
    var path:String = 'gameplay/songs/' + id + '/';

    if (variation != 'default')
      path += variation + '-';

    path += 'events';

    var json:EventsStructure = cast haxe.Json.parse(Paths.content.json(path));
    // TODO: version checking
    return json;
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
