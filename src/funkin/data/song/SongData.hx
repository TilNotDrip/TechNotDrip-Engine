package funkin.data.song;

// TODO: We prolly gonna redo this whole thing lol

/**
 * Legacy Chart Structure, too lazy to add documentation to these, figure it out yourself lmao
 */
typedef LegacyChartStructure =
{
  /**
   * idk burppppppppppppppp
   */
  var song:String;

  /**
   * idk burppppppppppppppp
   */
  @:default([])
  var notes:Array<LegacySectionStructure>;

  /**
   * idk burppppppppppppppp
   */
  @:default(150)
  var bpm:Float;

  /**
   * idk burppppppppppppppp
   */
  @:default(true)
  var needsVoices:Bool;

  /**
   * idk burppppppppppppppp
   */
  @:default(1)
  var speed:Float;

  /**
   * idk burppppppppppppppp
   */
  @:default('bf')
  var player1:String;

  /**
   * idk burppppppppppppppp
   */
  @:default('dad')
  var player2:String;

  /**
   * idk burppppppppppppppp
   */
  @:default('gf')
  var player3:String;

  /**
   * idk burppppppppppppppp
   */
  @:default('stage') // accomodate older chart that had stages based on the song.
  var stage:String;

  // GOTTA MAKE SURE. (variables we have in other mods, or stuff people have in other engines)
  @:optional
  var credits:SongCredits; // credits
}

/**
 * Legacy Section Structure, too lazy to add documentation to these.
 */
typedef LegacySectionStructure =
{
  // TODO: make this FUCKING work
  // @:jcustomparse(funkin.data.json2object.DataParse.jsonArrayToLegacyNotes) // why cant this FUCKING work
  var sectionNotes:Array<Dynamic>;
  var lengthInSteps:Int;
  var typeOfSection:Int;
  var mustHitSection:Bool;
  var bpm:Float;
  var changeBPM:Bool;
  var altAnim:Bool;

  @:optional
  @:default(false)
  var gfSection:Bool;
}

// i am so sorry for the comments, it is 1:39 for Til and 3:39 for crusher.
typedef ChartStructure =
{
  var charts:Array<ChartArrayElement>;

  // @:default(funkin.util.Constants.VERSION_CHART)
  @:optional
  var version:String;
}

typedef EventsStructure =
{
  var events:Array<EventData>;

  // @:default(funkin.util.Constants.VERSION_SONG_EVENTS)
  @:optional
  var version:String;
}

/**
 * That FUCKING oughhhhh~~~~~~~ BIRD THAT I HATE
 */
typedef ChartArrayElement =
{
  /**
   * The Difficulty of the chart.
   */
  var difficulty:String;

  /**
   * The Scroll Speed of the song.
   */
  @:default(1)
  var speed:Float;

  /**
   * The Rating of the song, this shows up in freeplay.
   */
  @:default(0)
  var rating:Int;

  /**
   * The actual chart.
   */
  @:default([]) // fuck you smart guy
  var chart:Array<NoteData>;
}

typedef MetadataStructure =
{
  /**
   * The name of the song.
   */
  var name:String;

  /**
   * The Characters in this song.
   * This goes by Character Type to Character ID.
   */
  @:default(['player' => 'bf', 'opponent' => 'dad', 'spectator' => 'gf'])
  var characters:Map<String, String>;

  /**
   * The setting (stay in school kids) you are in. Are you in a street where two maniacs want to kill you? Sure bud, youre not pico fnf.
   */
  @:default('mainStage')
  var stage:String;

  /**
   * The audio preview. This plays if you hover over the song in freeplay.
   */
  @:default({start: 0, end: 150000})
  var preview:
    {
      var start:Float;
      var end:Float;
    };

  @:default([{bpm: 100, time: 0, timeSignature: {numerator: 4, denominator: 4}}])
  var bpmChanges:Array<BPMChangeData>;

  /**
   * The freeplay icon for the song.
   */
  var icon:String;

  var credits:SongCredits;
}

typedef EventData =
{
  /**
   * The time that this event gets played on.
   */
  var time:Float;

  /**
   * The name of the event to play.
   */
  var name:String;

  /**
   * The arguments for the event. (If it requires it)
   *
   * An example of a Hey! argument
   * ```json
   * "args": {"heyTimer": 1}
   * ```
   */
  @:default([])
  var args:Map<String, Dynamic>;
}

typedef BPMChangeData =
{
  /**
   * The new bpm when this change is hit.
   */
  var bpm:Float;

  /**
   * The time that this bpm change gets played on.
   */
  var time:Float;

  /**
   * The time signature to change to.
   * @param numerator How many beats are in a measure.
   * @param denominator How many steps are in a beat (i think)
   */
  @:default({numerator: 4, denominator: 4})
  var timeSignature:{numerator:Float, denominator:Float}; // making it float cuz some person is gonna complain. I WILL BLOW YOUR HOSUE UP BITHC FUCK YOU

  /**
   * The time in beats. This is used internally to calculate beats after the change.
   */
  @:optional
  @:default(0)
  var beatTime:Float;
}

typedef NoteData =
{
  /**
   * The time the note will be hit.
   */
  var time:Float;

  /**
   * The direction that the note is facing.
   */
  var direction:Int;

  /**
   * The Type of the Note.
   */
  @:default('')
  var type:String;

  /**
   * The strum that the note shows up on.
   */
  var strum:String;

  /**
   * The *sus*tain length of the note.
   * @see https://www.innersloth.com/games/among-us/
   */
  @:optional
  var length:Float;
}

typedef SongCredits =
{
  /**
   * The person that composed this song.
   */
  @:default('Unknown')
  var composer:String;

  /**
   * The person that charted this song.
   */
  @:default('Unknown')
  var charter:String;
}
