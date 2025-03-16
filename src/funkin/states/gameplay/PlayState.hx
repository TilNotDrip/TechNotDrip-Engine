package funkin.states.gameplay;

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
	 * The current difficulty used for `this`.
	 */
	public var difficulty:String;

	/**
	 * Strumlines.
	 */
	public var strumlines:FlxTypedGroup<Strumline>;

	/**
	 * The voices of this song.
	 */
	public var voices:FlxSound;

	public function new(params:PlayStateParams)
	{
		instance = this;

		this.params = params;

		// TODO: debate on whether these stay or not.
		song = params.song;
		difficulty = params.difficulty;
		chart = song?.getChart(params.variation, difficulty);

		if (chart == null)
			throw "Chart was not loaded.";

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

		// TODO: actual strumline searching
		var strumlinesToAdd:Array<String> = ['opponent', 'player'];

		var strumlineXPos:Float = FlxG.width / strumlinesToAdd.length;

		for (i => strumlineID in strumlinesToAdd)
		{
			var strumline:Strumline = new Strumline(strumlineID);
			strumline.conductorInUse = conductor;
			strumline.setupNotes(chart);
			strumline.y = Constants.STRUMLINE_Y_OFFSET;
			strumline.x = (strumlineXPos * i) + MathUtil.center(strumlineXPos, strumline.width);
			strumlines.add(strumline);
		}
	}

	public function generateSong():Void
	{
		FlxG.sound.playMusic(Paths.content.audio('gameplay/songs/${song.id}/Inst'), 1, false);
		FlxG.sound.music.stop();

		// TODO: multiple voices
		voices = FlxG.sound.load(Paths.content.audio('gameplay/songs/${song.id}/Voices'));
		voices.stop();

		FlxG.sound.music.play();
		voices.play();
	}

	override public function update(elapsed:Float):Void
	{
		conductor.update();
		super.update(elapsed);
	}
}

typedef PlayStateParams =
{
	var song:Song;
	var difficulty:String;
	var variation:String;
}
