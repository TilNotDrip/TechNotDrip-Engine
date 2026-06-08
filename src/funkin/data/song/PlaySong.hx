package funkin.data.song;

import funkin.data.song.SongFormat;
import funkin.data.sound.BPMChange;
import funkin.sound.VoicesGroup;

class PlaySong
{
  /**
   * The ID of this Song.
   */
  public final id:String;

  /**
   * The variation of this Song.
   */
  public final variation:String;

  /**
   * The internal Song Metadata,
   * wrapped in a `Song` instance.
   */
  public final song:Song;

  final chart:SongChart;
  final events:SongEvents;

  public function new(variation:String, song:Song, chart:SongChart, events:SongEvents)
  {
    this.id = song.id;
    this.variation = variation;

    this.song = song;
    this.chart = chart;
    this.events = events;
  }

  /**
   * Initializes a `VoicesGroup` instance.
   * @return The `VoicesGroup` instance.
   */
  public function createVoices():VoicesGroup
  {
    final voices:VoicesGroup = new VoicesGroup(getAudioPath());

    for (id in getStrumlineIds())
      voices.registerStrumline(id);

    return voices;
  }

  /**
   * Fetches the path to the instrumental.
   * @return The path.
   */
  public function getInstrumentalPath():String
  {
    return '${getAudioPath()}/instrumental';
  }

  /**
   * Fetches all the strumline ids available in this song.
   * @return The Strumline Ids.
   */
  public function getStrumlineIds():Array<String>
  {
    var playData:Null<SongPlayData> = getPlayData();
    if (playData == null)
      return [];

    return [for (i in playData.characters.keys()) i];
  }

  /**
   * Fetches all BPM Changes used in this song.
   * @return The BPM Changes.
   */
  public function getBPMChanges():Array<BPMChange>
  {
    return song.getBPMChanges(variation);
  }

  /**
   * Gets the difficulty data, which includes the chart and scroll speed.
   * @param difficultyId The difficulty ID to look for.
   * @return The chart and scroll speed, wrapped neatly in a `SongDifficulty` instance.
   */
  public function getDifficulty(difficultyId:String):Null<SongDifficulty>
  {
    final difficulty:Null<SongDifficulty> = chart.difficulties.get(difficultyId);
    return difficulty;
  }

  /**
   * Get the Display Name for this song.
   * @return The name.
   */
  public function getDisplayName():String
  {
    return song.getDisplayName(this.variation);
  }

  /**
   * Fetches the Play Data for this song.
   * @return The Play Data.
   */
  public function getPlayData():Null<SongPlayData>
  {
    return song.getPlayData(this.variation);
  }

  /**
   * Fetches all events.
   * @return The events.
   */
  public function getEvents():SongEvents
  {
    return events;
  }

  function getAudioPath():String
  {
    return '${Song.SONG_PATH}/$id/$variation/audio';
  }
}
