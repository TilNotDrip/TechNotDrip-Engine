package funkin.states.gameplay;

import funkin.data.StrumlineData;
import funkin.data.song.Song;
import funkin.objects.gameplay.strumline.Strumline;
import funkin.structures.SongStructure;

class PlayState extends FunkinState
{
	/**
	 * The current instance of PlayState.
	 * This lets you access variables for the current session.
	 */
	public static var instance:PlayState;

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

		conductor.setupBPMChanges(metadata.bpmChanges);
	}

	override public function update(elapsed:Float):Void
	{
		conductor.update();

		for (i in strumlineDatas)
			i.update();

		super.update(elapsed);

		if (controls.justPressed.BACK)
			FlxG.switchState(funkin.states.ui.MenuState.new);
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
