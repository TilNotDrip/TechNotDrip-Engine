package funkin.data.song;

import funkin.data.song.SongFormat;
import funkin.data.sound.BPMChange;
import json2object.JsonParser;

class Song
{
  /**
   * The path to all songs.
   */
  public static final SONG_PATH:String = 'gameplay/songs';

  /**
   * The ID of this song.
   */
  public final id:String;

  /**
   * A list of all variations available.
   */
  public final variations:Array<String>;

  final _data:Map<String, SongMetadata>;

  public function new(id:String)
  {
    this.id = id;
    this.variations = getVariations(id);

    _data = [];
    for (variation in this.variations)
    {
      var metadata:SongMetadata = getMetadata(this.id, variation);
      _data.set(variation, metadata);
    }
  }

  /**
   * Get the Display Name for this song.
   * @param variation The variation to get the name from.
   * @return The name.
   */
  public function getDisplayName(?variation:String):String
  {
    var metadata:Null<SongMetadata> = _data.get(variation ?? Constants.DEFAULT_VARIATION);
    return metadata?.name ?? 'Unknown';
  }

  /**
   * Gets all the difficulties supported by `variation`.
   * @param variation The variation you want to search difficulties from. `null` for all variations.
   * @return The difficulties.
   */
  public function getDifficulties(variation:Null<String>):Array<String>
  {
    final variations:Array<String> = variation == null ? this.variations : [variation];
    var difficulties:Array<String> = [];

    for (variation in variations)
    {
      final metadata:Null<SongMetadata> = _data.get(variation);
      if (metadata == null)
        continue;

      for (difficulty in metadata.difficulties)
      {
        if (!difficulties.contains(difficulty))
          difficulties.push(difficulty);
      }
    }

    return difficulties;
  }

  /**
   * Get the Freeplay Data for a song.
   * @param variation The optional song variation to grab the freeplay data from.
   * @return The freeplay data. Will be `null` if variation doesn't exist.
   */
  public function getFreeplayData(?variation:String):Null<SongFreeplayData>
  {
    var metadata:Null<SongMetadata> = _data.get(variation ?? Constants.DEFAULT_VARIATION);
    return metadata?.freeplayData;
  }

  /**
   * Get the BPM Change Data for a song.
   * @param variation The optional song variation to grab the BPm Changes from.
   * @return The BPM Changes. Will be `null` if variation doesn't exist.
   */
  public function getBPMChanges(?variation:String):Array<BPMChange>
  {
    var metadata:Null<SongMetadata> = _data.get(variation ?? Constants.DEFAULT_VARIATION);
    return metadata?.bpmChanges ?? [BPMChange.DEFAULT_BPM_CHANGE];
  }

  @:allow(funkin.data.song.PlaySong)
  function getPlayData(variation:String):Null<SongPlayData>
  {
    var metadata:Null<SongMetadata> = _data.get(variation);
    return metadata?.playData;
  }

  /**
   * Loads a variation's chart and events.
   * @param variation The variation to use.
   * @return The chart and events, wrapped neatly in a nice `PlaySong` instance.
   */
  public function loadForPlay(variation:String):Null<PlaySong>
  {
    final chart:Null<SongChart> = getChart(this.id, variation);
    final events:Null<SongEvents> = getEvents(this.id, variation);
    if (chart == null || events == null)
      return null;

    return new PlaySong(variation, this, chart, events);
  }

  static function getVariations(id:String):Array<String>
  {
    var songIdPath:String = '$SONG_PATH/$id/';
    var variations:Array<String> = [];

    for (file in Paths.location.scan(songIdPath, '', true, PATH_FILE, false))
    {
      final slashIndex:Int = file.indexOf('/', songIdPath.length);
      final variationId:String = file.substring(songIdPath.length, slashIndex);
      if (slashIndex == -1)
        continue;

      if (!variations.contains(variationId))
        variations.push(variationId);
    }

    return variations;
  }

  static function getMetadata(id:String, variation:String):Null<SongMetadata>
  {
    final path:String = '$SONG_PATH/$id/$variation/metadata';
    final content:String = Paths.content.json(path);

    final parser:JsonParser<SongMetadata> = new JsonParser<SongMetadata>();
    parser.fromJson(content, path);
    return parser.value;
  }

  static function getChart(id:String, variation:String):Null<SongChart>
  {
    final path:String = '$SONG_PATH/$id/$variation/chart';
    final content:String = Paths.content.json(path);

    final parser:JsonParser<SongChart> = new JsonParser<SongChart>();
    parser.fromJson(content, path);
    return parser.value;
  }

  static function getEvents(id:String, variation:String):Null<SongEvents>
  {
    final path:String = '$SONG_PATH/$id/$variation/events';
    final content:String = Paths.content.json(path);

    final parser:JsonParser<SongEvents> = new JsonParser<SongEvents>();
    parser.fromJson(content, path);
    return parser.value;
  }
}
