package funkin.states.gameplay;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import funkin.data.StrumlineData;
import funkin.data.song.Song;
import funkin.objects.gameplay.strumline.Strumline;
import funkin.structures.SongStructure;
import funkin.util.InputUtil;
import funkin.util.StoryModeHandler;

class PlayState extends FunkinState
{
	/**
	 * Story Mode Handler
	 */
	public static var storyMode:StoryModeHandler;

	/**
	 * The scorebar at the bottom of the screen whilst playing a song
	 */
	public static var scoreTxt:FlxText;

	/**
	 * The total score of the player; Used for `scoreTxt`
	 */
	public static var totalScore:Int;

	/**
	 * The total note misses made by the player; Used for `scoreTxt`
	 */
	public static var totalMisses:Int;

	/**
	 * The total hittable notes; Used for the calculation of average accuracy
	 */
	public static var totalHittableNotes:Int;

	var song:Song;
	var chart:ChartArrayElement;
	var metadata:MetadataStructure;
	var difficulty:String;
	var strumlineDatas:Array<StrumlineData> = [];
	var strumlines:FlxTypedGroup<Strumline>;
	var voicesPlayer:FlxSound;
	var voicesOpponent:FlxSound;
	var avgAcc:Float;

	public function new(stateArgs:StateArgs)
	{
		song = stateArgs.song;
		difficulty = stateArgs.difficulty;
		chart = song?.getChart(stateArgs.variation, difficulty);
		metadata = song?.metadatas.get(stateArgs.variation);

		totalScore = 0;
		totalMisses = 0;
		totalHittableNotes = 0;
		avgAcc = 0;

		if (chart == null)
			throw "Chart was not loaded.";

		if (metadata == null)
			throw "Metadata was not loaded.";

		super();
	}

	override public function create():Void
	{
		bgColor = FlxColor.fromRGB(50, 50, 50); // use gray background

		generateStrumlines();
		generateSong();

		var font:String = Paths.location.get("ui/fonts/vcr.ttf");

		scoreTxt = new FlxText();
		scoreTxt.setFormat(font, 20, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.y = FlxG.height - (scoreTxt.size * 2);
		scoreTxt.borderSize = 2;
		scoreTxt.text = "";

		add(scoreTxt);

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

		var newVocalsExists:Bool = Paths.location.exists('gameplay/songs/${song.id}/Voices-Opponent.ogg')
			&& Paths.location.exists('gameplay/songs/${song.id}/Voices-Player.ogg');

		var oldVocalsExists:Bool = Paths.location.exists('gameplay/songs/${song.id}/Voices.ogg');

		if (newVocalsExists)
		{
			var opponentAudio:String = 'gameplay/songs/${song.id}/Voices-Opponent';
			var playerAudio:String = 'gameplay/songs/${song.id}/Voices-Player';

			voicesOpponent = FlxG.sound.load(Paths.content.audio(opponentAudio));
			voicesOpponent.stop();

			voicesPlayer = FlxG.sound.load(Paths.content.audio(playerAudio));
			voicesPlayer.stop();
		}
		else if (oldVocalsExists)
		{
			var voicesAudio:String = 'gameplay/songs/${song.id}/Voices';
			voicesPlayer = FlxG.sound.load(Paths.content.audio(voicesAudio));
			voicesPlayer.stop();
		}
		else
			trace('[NOTICE] The current song does not have vocals.');

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
			finishSong();

		// sync vocals to the instrumental
		var targetTime = FlxG.sound.music.time;

		var isPlayerDelayed:Bool = getPlayerSound() != null && Math.abs(getPlayerSound().time - targetTime) > 10;

		var isOpponentDelayed:Bool = getOpponentSound() != null && Math.abs(getOpponentSound().time - targetTime) > 10;

		if (isPlayerDelayed)
			getPlayerSound().time = targetTime;

		if (isOpponentDelayed)
			getOpponentSound().time = targetTime;

		if (totalHittableNotes > 0 && InputUtil.MAX_SCORE > 0)
			avgAcc = (totalScore / (totalHittableNotes * InputUtil.MAX_SCORE)) * 100;

		scoreTxt.text = 'Score: ${totalScore} | avg. Acc: ${truncateFloat(avgAcc, 2)}% | Misses: ${totalMisses}';

		scoreTxt.x = (FlxG.width / 2) - (scoreTxt.width / 2);

		var ratio:Float = 5 * FlxG.elapsed;
		scoreTxt.scale.y = FlxMath.lerp(scoreTxt.scale.y, 1, ratio);
		scoreTxt.scale.x = FlxMath.lerp(scoreTxt.scale.x, 1, ratio);
	}

	function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision); // shift decimal
		num = Math.round(num); // round to nearest integer
		num = num / Math.pow(10, precision); // shift back
		return num;
	}

	function finishSong():Void
	{
		if (storyMode != null)
			FlxG.switchState(storyMode.nextState);
		else
		{
			conductor.changeBPM(102);
			FlxG.sound.music.onComplete = null;
			FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
			getPlayerSound()?.stop();
			getOpponentSound()?.stop();
			bgColor = FlxColor.BLACK; // return to old background color
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

typedef StateArgs =
{
	var song:Song;
	var difficulty:String;
	var variation:String;
}
