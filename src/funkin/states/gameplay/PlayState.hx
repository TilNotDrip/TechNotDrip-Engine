package funkin.states.gameplay;

import flixel.util.FlxSort;
import funkin.data.StrumlineData;
import funkin.data.song.Song;
import funkin.objects.gameplay.strumline.Strumline;
import funkin.structures.SongStructure;
import funkin.util.StoryModeHandler;

class PlayState extends FunkinState
{
	/**
	 * The current instance of PlayState.
	 * This lets you access variables for the current session.
	 */
	public static var instance:PlayState;

	/**
	 * Story Mode Handler.
	 */
	public static var storyMode:StoryModeHandler;

	/**
	 * The parameters used when initializing this state.
	 */
	public var params:PlayStateParams;

	/**
	 * The current song used for `this`.
	 */
	public var song:Song;

	/**
	 * The current chart used for `this`.
	 */
	public var chart:ChartArrayElement;

	/**
	 * The current metadata used for `this`.
	 */
	public var metadata:MetadataStructure;

	/**
	 * The current difficulty used for `this`.
	 */
	public var difficulty:String;

	/**
	 * The strumline data.
	 */
	public var strumlineDatas:Array<StrumlineData> = [];

	/**
	 * Strumlines.
	 */
	public var strumlines:FlxTypedGroup<Strumline>;

	/**
	 * The voice the player is using for this song.
	 */
	public var voicesPlayer:FlxSound;

	/**
	 * The voice the player is using for this song.
	 */
	public var voicesOpponent:FlxSound;

	public function new(params:PlayStateParams)
	{
		instance = this;

		this.params = params;

		// TODO: debate on whether these stay or not.
		song = params.song;
		difficulty = params.difficulty;
		chart = song?.getChart(params.variation, difficulty);
		metadata = song?.metadatas.get(params.variation);

		if (chart == null)
			throw "Chart was not loaded.";

		if (metadata == null)
			throw "Metadata was not loaded.";

		super();
	}

	override public function create():Void
	{
		generateStrumlines();
		generateSong();

		super.create();
	}

	public function generateStrumlines():Void
	{
		strumlines = new FlxTypedGroup<Strumline>();
		add(strumlines);

		metadata = song?.metadatas.get('default');

		for (strumlineID in ['player', 'opponent', 'spectator'])
		{
			var strumlineData:StrumlineData = new StrumlineData(strumlineID);
			strumlineData.conductorInUse = conductor;
			strumlineDatas.push(strumlineData);

			if (strumlineData.data.renderStrumline)
			{
				var strumline:Strumline = new Strumline(strumlineData);

				strumline.y = Constants.STRUMLINE_Y_OFFSET;

				strumline.x = switch (strumlineData.data.strumlinePosition)
				{
					case 'left':
						MathUtil.center(FlxG.width / 2, strumline.width);
					case 'right':
						FlxG.width / 2 + MathUtil.center(FlxG.width / 2, strumline.width);
					default:
						0;
				}

				strumline.conductorInUse = conductor;
				strumline.setupNotes(chart);
				strumlineData.strumline = strumline;
				strumlines.add(strumline);
			}
		}
	}

	public function generateSong():Void
	{
		FlxG.sound.playMusic(Paths.content.audio('gameplay/songs/${song.id}/Inst'), 1, false);
		FlxG.sound.music.stop();

		if (Paths.location.exists('gameplay/songs/${song.id}/Voices-Opponent.ogg')
			&& Paths.location.exists('gameplay/songs/${song.id}/Voices-Player.ogg'))
		{
			voicesOpponent = FlxG.sound.load(Paths.content.audio('gameplay/songs/${song.id}/Voices-Opponent'));
			voicesOpponent.stop();

			voicesPlayer = FlxG.sound.load(Paths.content.audio('gameplay/songs/${song.id}/Voices-Player'));
			voicesPlayer.stop();
		}
		else if (Paths.location.exists('gameplay/songs/${song.id}/Voices.ogg'))
		{
			voicesPlayer = FlxG.sound.load(Paths.content.audio('gameplay/songs/${song.id}/Voices'));
			voicesPlayer.stop();
		}
		else
		{
			trace('[NOTICE] The current song does not have vocals.');
		}

		FlxG.sound.music.play();
		getPlayerSound()?.play();
		getOpponentSound()?.play();

		var soundsAvailable:Array<FlxSound> = [FlxG.sound.music, getPlayerSound(), getOpponentSound()];
		soundsAvailable.sort((a:FlxSound, b:FlxSound) ->
		{
			return FlxSort.byValues(FlxSort.DESCENDING, a?.length ?? 0, b?.length ?? 0);
		});
		soundsAvailable[0].onComplete = finishSong;

		conductor.setupBPMChanges(metadata.bpmChanges);
	}

	override public function update(elapsed:Float):Void
	{
		conductor.update();

		for (i in strumlineDatas)
			i.update();

		super.update(elapsed);

		if (controls.justPressed.BACK)
		{
			finishSong();
		}
	}

	/**
	 * Finish the song.
	 */
	public function finishSong():Void
	{
		if (storyMode != null)
		{
			FlxG.switchState(storyMode.nextState);
		}
		else
		{
			conductor.changeBPM(102);
			FlxG.sound.music.onComplete = null;
			FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));

			FlxG.switchState(funkin.states.ui.FreeplayState.new);
		}
	}

	public function getPlayerSound():FlxSound
	{
		return voicesPlayer;
	}

	public function getOpponentSound():FlxSound
	{
		return voicesOpponent ?? voicesPlayer;
	}
}

typedef PlayStateParams =
{
	var song:Song;
	var difficulty:String;
	var variation:String;
}
