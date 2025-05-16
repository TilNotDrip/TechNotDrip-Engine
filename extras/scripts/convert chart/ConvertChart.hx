package;

import haxe.Json;
import haxe.io.Path;
import json2object.JsonParser;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class ConvertChart
{
	public static function main():Void
	{
		if (Sys.args().length > 0)
		{
			var argsFiltered:Array<String> = Sys.args().join(' ').split('.\\');

			for (i in 0...argsFiltered.length)
				argsFiltered[i] = argsFiltered[i].trim();

			argsFiltered.shift();
			convertCharts(argsFiltered[0], argsFiltered[1]);
			return;
		}

		Sys.stdout().writeString('Welcome to TechNotDrip converter!\n');
		Sys.stdout().writeString('NOTE: If your song has a different variation (ex. erect), convert them seperately to avoid merging issues!\n');
		Sys.stdout().writeString('Please type directory you want to convert: ');
		Sys.stdout().flush();
		final path = Sys.stdin().readLine();

		if (FileSystem.isDirectory(path))
			convertCharts(path);
		else
			throw "Not supported!";
	}

	static function convertCharts(path:String, ?savePath:Null<String>):Void
	{
		var chartStructure:ChartStructure = {charts: []};
		var metadata:MetadataStructure = null;
		var events:EventsStructure = null;

		var songName:String = Path.withoutDirectory(path);
		for (file in FileSystem.readDirectory(path))
		{
			if (!file.endsWith('.json') || file == 'events.json')
				continue;

			var withoutExt:String = Path.withoutExtension(file);
			if (withoutExt == '$songName-metadata' || withoutExt == '$songName-chart')
			{
				var vsliceChartJson:JsonParser<VSliceChartStructure> = new JsonParser<VSliceChartStructure>();
				vsliceChartJson.fromJson(File.getContent(Path.join([path, '$songName-chart.json'])), '$songName-chart.json');
				var vsliceMetadataJson:JsonParser<VSliceMetadataStructure> = new JsonParser<VSliceMetadataStructure>();
				vsliceMetadataJson.fromJson(File.getContent(Path.join([path, '$songName-metadata.json'])), '$songName-metadata.json');
				var convertedThings:Array<Dynamic> = convertVSlice(vsliceChartJson.value, vsliceMetadataJson.value);
				chartStructure = convertedThings[0];
				metadata = convertedThings[1];
				events = convertedThings[2];
				break;
			}
			/*else
				{
					var legacyChart:LegacyChartStructure = cast Json.parse(File.getContent(Path.join([path, file]))).song;

					var difficulty:String = if (withoutExt != songName) withoutExt.substring(withoutExt.lastIndexOf('-') + 1); else 'normal';
					var convertedThings:Array<Dynamic> = convertLegacyChart(legacyChart, difficulty);

					chartStructure.charts.push(convertedThings[0]);

					if (metadata == null)
						metadata = convertedThings[1];

					if (events == null)
					{
						events = {
							events: convertedThings[2]
						};
					}
			}*/
			/*{
				Sys.stdout().writeString('\nPlease enter difficulty ID for $file (Leave enter to skip): ');
				Sys.stdout().flush();
				difficulty = Sys.stdin().readLine();
			}*/
		}

		var chartPath:String = '';
		if (savePath != null)
			chartPath = savePath;
		else
		{
			Sys.stdout().writeString('\nWhere should the converted chart be saved? (this should be a path): ');
			Sys.stdout().flush();
			chartPath = Sys.stdin().readLine();
		}

		if (!FileSystem.exists(chartPath))
			FileSystem.createDirectory(chartPath);

		File.saveContent(Path.join([chartPath, 'chart.json']), Json.stringify(chartStructure, '\t'));
		File.saveContent(Path.join([chartPath, 'metadata.json']), Json.stringify(metadata, '\t'));
		File.saveContent(Path.join([chartPath, 'events.json']), Json.stringify(events, '\t'));

		Sys.stdout().writeString('\nDONE!!');
		Sys.stdout().flush();
	}

	static function convertLegacyChart(legacyChart:LegacyChartStructure, difficulty:String):Array<Dynamic>
	{
		var chartConverted:ChartArrayElement = {
			difficulty: '',
			speed: 1,
			rating: 0,
			chart: []
		};
		var events:Array<EventData> = [];

		var bpmChanges:Array<BPMChangeData> = [];

		bpmChanges.insert(0, {bpm: legacyChart.bpm, time: 0, timeSignature: {numerator: 4, denominator: 4}});

		chartConverted.difficulty = difficulty;
		chartConverted.speed = legacyChart.speed;

		var sectionTime:Float = 0;
		var lastLengthInSteps:Float = 0;

		function getLastBPMChange():BPMChangeData
			return bpmChanges[bpmChanges.length - 1];

		var lastCamera:String = '';
		for (section in legacyChart.notes)
		{
			if (section.changeBPM)
			{
				bpmChanges.push({
					bpm: section.bpm,
					time: sectionTime,
					timeSignature: {numerator: 4, denominator: 4}
				});
			}

			if (section.lengthInSteps != lastLengthInSteps)
			{
				if (getLastBPMChange().time == sectionTime)
				{
					getLastBPMChange().timeSignature = {numerator: section.lengthInSteps / 4, denominator: 4};
				}
				else
				{
					bpmChanges.push({
						bpm: getLastBPMChange().bpm,
						time: sectionTime,
						timeSignature: {numerator: section.lengthInSteps / 4, denominator: 4}
					});
				}

				lastLengthInSteps = section.lengthInSteps;
			}

			var sectionCamera:String = section.mustHitSection ? 'player' : 'opponent';

			if (section.gfSection)
				sectionCamera = 'spectator';

			if (sectionCamera != lastCamera)
			{
				events.push({
					time: sectionTime,
					name: 'camera',
					args: ['strum' => sectionCamera]
				});

				sectionCamera = lastCamera;
			}

			// LEGACY NOTE PROPERTIES: time, direction, length, alt note/note type
			for (note in section.sectionNotes)
			{
				if (note[0] < 0)
					continue;

				var notePush:NoteData = {
					time: 0,
					direction: 0,
					type: '',
					strum: ''
				};

				notePush.time = note[0];
				notePush.direction = Std.int(note[1] % 4);

				if (Std.isOfType(note[3], Bool))
					notePush.type = note[3] ? 'alt' : '';
				else if (Std.isOfType(note[3], String))
				{
					if (Std.parseInt(note[3]) != null)
					{
						var noteInt:Int = Std.parseInt(note[3]);
						var psychNoteTypes:Array<String> = ['', 'alt'];

						if (psychNoteTypes.length <= noteInt)
							continue;

						notePush.type = psychNoteTypes[noteInt];
						continue;
					}

					switch (note[3])
					{
						case 'Alt Animation':
							notePush.type = 'alt';
						case 'No Animation':
							notePush.type = 'noanim';
						case 'GF Sing':
							notePush.strum = 'spectator';
						case '':
						default:
							Sys.stdout().writeString('\nWhat is the notetype ID for ${note[3]}? (type null to ignore note): ');
							Sys.stdout().flush();
							final noteType:String = Sys.stdin().readLine();

							if (noteType == 'null')
								continue;
							else
								notePush.type = noteType;
					}
				}

				// GF Note :trollface:
				if (notePush.strum == '')
				{
					var isOpponent:Bool = false;

					if (section.mustHitSection)
						isOpponent = note[1] > 3;
					else
						isOpponent = note[1] < 4;

					notePush.strum = isOpponent ? 'opponent' : 'player';
				}

				if (note[2] > 0)
					notePush.length = note[2];

				chartConverted.chart.push(notePush);
			}

			sectionTime += calculateCrochet(getLastBPMChange().bpm) * getLastBPMChange().timeSignature.numerator;
		}

		var metadata:MetadataStructure = {
			name: legacyChart.song,
			icon: legacyChart.player2, // its an attempt...
			characters: [
				'player' => legacyChart.player1 ?? 'bf',
				'opponent' => legacyChart.player2 ?? 'dad',
				'spectator' => legacyChart.player3 ?? 'gf'
			],
			stage: legacyChart.stage,
			preview: {
				start: 0,
				end: 150000
			},
			bpmChanges: bpmChanges,
			credits: {composer: 'Unknown', charter: 'Unknown'}
		};

		return [chartConverted, metadata, events];
	}

	static function convertVSlice(chartStructure:VSliceChartStructure, metadataStructure:VSliceMetadataStructure):Array<Dynamic>
	{
		var chartConverted:ChartStructure = {
			charts: []
		};
		for (difficulty in chartStructure.notes.keys())
		{
			var chartDifficultyConverted:ChartArrayElement = {
				difficulty: difficulty,
				speed: chartStructure.scrollSpeed.get(difficulty) ?? chartStructure.scrollSpeed.get('default') ?? 1,
				rating: metadataStructure.playData.ratings.get(difficulty) ?? 0,
				chart: []
			};

			for (note in chartStructure.notes.get(difficulty))
			{
				var notePush:NoteData = {
					time: 0,
					direction: 0,
					type: '',
					strum: ''
				};

				notePush.type = switch (note.kind)
				{
					case '', null:
						'';
					case 'mom', 'ugh', 'hehPrettyGood':
						'alt';
					// TODO: blazin' stuff
					default:
						continue;
				}

				notePush.time = note.time;
				notePush.direction = Std.int(note.data % 4);

				notePush.strum = switch (Math.floor(note.data / 4))
				{
					case 0:
						'player';
					default:
						// we dont want random notes on the players side, do we?
						'opponent';
				}

				if (note.length != null && note.length > 0)
					notePush.length = note.length;

				chartDifficultyConverted.chart.push(notePush);
			}

			chartConverted.charts.push(chartDifficultyConverted);
		}

		var eventsConverted:EventsStructure = {
			events: []
		};

		for (event in chartStructure.events)
		{
			var eventPush:EventData = {
				time: event.time,
				name: '',
				args: new Map<String, Dynamic>()
			};

			switch (event.eventKind)
			{
				case 'FocusCamera':
					eventPush.name = 'camera';

					var char:Int = (event.value?.char ?? event.value);
					var posX:Float = event.value?.x ?? 0;
					var posY:Float = event.value?.y ?? 0;

					var duration:Float = event.value?.duration ?? 4;
					var ease:Null<String> = event.value?.ease;

					var strum:Null<String> = switch (Std.int(char))
					{
						case 0:
							'player';
						case 1:
							'opponent';
						case 2:
							'spectator';
						default:
							null;
					}

					if (strum != null)
						eventPush.args.set('strum', strum);

					eventPush.args.set('pos', {
						x: posX,
						y: posY
					});

					if (ease != null)
						eventPush.args.set('tweenInfo', {duration: duration, ease: ease});

				case 'ZoomCamera':
					eventPush.name = 'zoom';

					var zoom:Float = (event.value?.zoom ?? event.value) ?? 1;
					var mode:String = event.value?.mode ?? 'direct';

					var duration:Float = event.value?.duration ?? 4;
					var ease:Null<String> = event.value?.ease;

					eventPush.args.set('zoom', zoom);
					eventPush.args.set('direct', mode == 'direct');

					if (ease != null)
						eventPush.args.set('tweenInfo', {duration: duration, ease: ease});

				case 'PlayAnimation':
					eventPush.name = 'anim';

					var target:String = event.value?.target ?? 'player';
					var anim:String = event.value?.anim ?? 'idle';
					var force:Bool = event.value?.anim ?? false;

					target = switch (target)
					{
						case 'boyfriend', 'bf', 'player':
							'player';
						case 'dad', 'opponent':
							'opponent';
						case 'girlfriend', 'gf':
							'spectator';
						default:
							target;
					}

					eventPush.args = ['spr' => target, 'anim' => anim, 'force' => force];
				default:
					continue;
			}

			eventsConverted.events.push(eventPush);
		}

		var bpmChanges:Array<BPMChangeData> = [];
		for (timeChange in metadataStructure.timeChanges)
		{
			bpmChanges.push({
				time: timeChange.timeStamp,
				bpm: timeChange.bpm,
				timeSignature: {
					numerator: timeChange.timeSignatureNum,
					denominator: timeChange.timeSignatureNum
				}
			});
		}

		var metadataConverted:MetadataStructure = {
			characters: [
				'player' => metadataStructure.playData.characters.player,
				'opponent' => metadataStructure.playData.characters.opponent,
				'spectator' => metadataStructure.playData.characters.girlfriend
			],
			bpmChanges: bpmChanges,
			credits: {
				composer: metadataStructure.artist,
				charter: metadataStructure.charter
			},
			icon: metadataStructure.playData.characters.opponent,
			name: metadataStructure.songName,
			preview: {
				start: metadataStructure.playData.previewStart,
				end: metadataStructure.playData.previewEnd
			},
			stage: metadataStructure.playData.stage
		};

		return [chartConverted, metadataConverted, eventsConverted];
	}

	/**
	 * Calculate the crochet, which is the length between a beat.
	 * @param bpm The bpm to use for calculating.
	 * @return The crochet, in miliseconds.
	 */
	static inline function calculateCrochet(bpm:Float):Float
	{
		return ((60 / bpm) * 1000);
	}

	public static function dynamicValueParse(json:hxjsonast.Json, name:String):Dynamic
	{
		return hxjsonast.Tools.getValue(json);
	}

	public static function dynamicValueWrite(value:Dynamic):String
	{
		return Json.parse(value);
	}
}

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
	var credits:SongCredits; // snc credits
}

/**
 * Legacy Section Structure, too lazy to add documentation to these.
 */
typedef LegacySectionStructure =
{
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
	 * The icon that shows up in freeplay.
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

typedef VSliceChartStructure =
{
	public var scrollSpeed:Map<String, Float>;
	public var events:Array<VSliceEventStructure>;
	public var notes:Map<String, Array<VSliceNoteStructure>>;

	public var version:String;
	public var generatedBy:String;
}

typedef VSliceNoteStructure =
{
	/**
	 * The timestamp of the note. The timestamp is in the format of the song's time format.
	 */
	@:alias("t")
	public var time:Float;

	/**
	 * Data for the note. Represents the index on the strumline.
	 * 0 = left, 1 = down, 2 = up, 3 = right
	 * `floor(direction / strumlineSize)` specifies which strumline the note is on.
	 * 0 = player, 1 = opponent, etc.
	 */
	@:alias("d")
	public var data:Int;

	/**
	 * Length of the note, if applicable.
	 * Defaults to 0 for single notes.
	 */
	@:alias("l")
	@:default(0)
	@:optional
	public var length:Float;

	/**
	 * The kind of the note.
	 * This can allow the note to include information used for custom behavior.
	 * Defaults to `null` for no kind.
	 */
	@:alias("k")
	@:optional
	@:isVar
	public var kind:Null<String>;
}

class VSliceEventStructure
{
	/**
	 * The timestamp of the event. The timestamp is in the format of the song's time format.
	 */
	@:alias("t")
	public var time:Float;

	/**
	 * The kind of the event.
	 * Examples include "FocusCamera" and "PlayAnimation"
	 * Custom events can be added by scripts with the `ScriptedSongEvent` class.
	 */
	@:alias("e")
	public var eventKind:String;

	/**
	 * The data for the event.
	 * This can allow the event to include information used for custom behavior.
	 * Data type depends on the event kind. It can be anything that's JSON serializable.
	 */
	@:alias("v")
	@:optional
	@:jcustomparse(ConvertChart.dynamicValueParse)
	@:jcustomwrite(ConvertChart.dynamicValueWrite)
	public var value:Dynamic;
}

typedef VSliceMetadataStructure =
{
	@:default("Unknown")
	var songName:String;
	@:default("Unknown")
	var artist:String;
	@:optional
	var charter:Null<String>;
	@:optional
	@:default(96)
	var divisions:Null<Int>; // Optional field
	@:optional
	@:default(false)
	var looped:Bool;

	/**
	 * Data relating to the song's gameplay.
	 */
	var playData:
		{
			/**
			 * The variations this song has. The associated metadata files should exist.
			 */
			@:default([])
			@:optional
			public var songVariations:Array<String>;
			/**
			 * The difficulties contained in this song's chart file.
			 */
			public var difficulties:Array<String>;
			/**
			 * The characters used by this song.
			 */
			public var characters:
				{
					@:optional
					@:default('')
					public var player:String;
					@:optional
					@:default('')
					public var girlfriend:String;
					@:optional
					@:default('')
					public var opponent:String;
					@:optional
					@:default('')
					public var instrumental:String;
					@:optional
					@:default([])
					public var altInstrumentals:Array<String>;
				};
			/**
			 * The stage used by this song.
			 */
			public var stage:String;
			/**
			 * The note style used by this song.
			 */
			public var noteStyle:String;
			/**
			 * The difficulty ratings for this song as displayed in Freeplay.
			 * Key is a difficulty ID.
			 */
			@:optional
			@:default(['normal' => 0])
			public var ratings:Map<String, Int>;
			/**
			 * The album ID for the album to display in Freeplay.
			 * If `null`, display no album.
			 */
			@:optional
			public var album:Null<String>;
			/**
			 * The start time for the audio preview in Freeplay.
			 * Defaults to 0 seconds in.
			 * @since `2.2.2`
			 */
			@:optional
			@:default(0)
			public var previewStart:Int;
			/**
			 * The end time for the audio preview in Freeplay.
			 * Defaults to 15 seconds in.
			 * @since `2.2.2`
			 */
			@:optional
			@:default(15000)
			public var previewEnd:Int;
		};

	/**
	 * Data relating to the song's gameplay.
	 */
	var timeChanges:Array<
		{
			/**
			 * Timestamp in specified `timeFormat`.
			 */
			@:alias("t")
			public var timeStamp:Float;
			/**
			 * Time in beats (int). The game will calculate further beat values based on this one,
			 * so it can do it in a simple linear fashion.
			 */
			@:optional
			@:alias("b")
			public var beatTime:Float;
			/**
			 * Quarter notes per minute (float). Cannot be empty in the first element of the list,
			 * but otherwise it's optional, and defaults to the value of the previous element.
			 */
			@:alias("bpm")
			public var bpm:Float;
			/**
			 * Time signature numerator (int). Optional, defaults to 4.
			 */
			@:default(4)
			@:optional
			@:alias("n")
			public var timeSignatureNum:Int;
			/**
			 * Time signature denominator (int). Optional, defaults to 4. Should only ever be a power of two.
			 */
			@:default(4)
			@:optional
			@:alias("d")
			public var timeSignatureDen:Int;
			/**
			 * Beat tuplets (Array<int> or int). This defines how many steps each beat is divided into.
			 * It can either be an array of length `n` (see above) or a single integer number.
			 * Optional, defaults to `[4]`.
			 */
			@:optional
			@:alias("bt")
			public var beatTuplets:Array<Int>;
		}>;
}
