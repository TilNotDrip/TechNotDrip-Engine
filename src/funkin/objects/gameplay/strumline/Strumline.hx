package funkin.objects.gameplay.strumline;

import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSort;
import funkin.structures.SongStructure;

class Strumline extends FlxSpriteGroup
{
	/**
	 * The "size" of a strumline note.
	 */
	public static final STRUMLINE_SIZE:Int = 104;

	/**
	 * The spacing between strumline notes.
	 */
	public static final NOTE_SPACING:Int = STRUMLINE_SIZE + 8;

	static var RENDER_DISTANCE_MS(get, never):Float;

	static function get_RENDER_DISTANCE_MS():Float
	{
		return FlxG.height / Constants.PIXELS_PER_MS;
	}

	/**
	 * Very important, as this will impact which notes can be shown in the strumline.
	 */
	public var strumlineID:String;

	/**
	 * Is this strumline controlled by a player or not?
	 */
	public var isPlayer:Bool;

	/**
	 * The conductor to use.
	 */
	public var conductorInUse:Conductor;

	/**
	 * The notes shown for input.
	 */
	public var strumlineNotes:FlxTypedSpriteGroup<StrumlineNote>;

	/**
	 * The notes that are supposed to be hit.
	 */
	public var notes:FlxTypedSpriteGroup<NoteSprite>;

	/**
	 * The sustain notes that are supposed to be hit.
	 */
	public var sustainNotes:FlxTypedSpriteGroup<SustainNoteSprite>;

	/**
	 * The splashes that appear when you get the rating "Sick!" or higher.
	 */
	public var noteSplashes:FlxTypedSpriteGroup<NoteSplash>;

	/**
	 * The splashes that appear when you hold a note.
	 */
	// public var holdCovers:FlxTypedSpriteGroup<NoteHoldCover>;

	/**
	 * The Note Data to use for spawning.
	 */
	public var noteData:Array<NoteData> = [];

	/**
	 * The Note Data left for spawning.
	 */
	public var noteDataLeft:Array<NoteData> = [];

	/**
	 * The scroll speed.
	 */
	public var scrollSpeed:Float = 1;

	public function new(strumlineID:String, ?isPlayer:Bool = false)
	{
		this.strumlineID = strumlineID;
		this.isPlayer = isPlayer;

		super();

		strumlineNotes = new FlxTypedSpriteGroup<StrumlineNote>();
		add(strumlineNotes);

		for (i => direction in NoteDirection.allDirections)
		{
			var strumNote:StrumlineNote = new StrumlineNote(NOTE_SPACING * i, 0, direction);
			strumNote.head = this;
			strumlineNotes.add(strumNote);
		}

		sustainNotes = new FlxTypedSpriteGroup<SustainNoteSprite>();
		add(sustainNotes);

		var sustainNote:SustainNoteSprite = new SustainNoteSprite();
		sustainNote.kill();
		sustainNotes.add(sustainNote);

		notes = new FlxTypedSpriteGroup<NoteSprite>();
		add(notes);

		var note:NoteSprite = new NoteSprite();
		note.kill();
		notes.add(note);

		noteSplashes = new FlxTypedSpriteGroup<NoteSplash>();
		add(noteSplashes);

		var noteSplash:NoteSplash = new NoteSplash();
		noteSplash.kill();
		noteSplashes.add(noteSplash);

		/*holdCovers = new FlxTypedSpriteGroup<NoteHoldCover>();
			add(holdCovers);

			var holdCover:NoteHoldCover = new NoteHoldCover();
			holdCover.kill();
			holdCovers.add(holdCover); */
	}

	/**
	 * Sets up notes for spawning.
	 * @param chart The chart for this song.
	 */
	public function setupNotes(chart:ChartArrayElement):Void
	{
		var filteredNotes:Array<NoteData> = chart.chart.filter((note:NoteData) ->
		{
			return note.strum == strumlineID;
		});

		noteData = filteredNotes;
		noteData.sort((a:NoteData, b:NoteData) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		});

		scrollSpeed = chart.speed;

		noteDataLeft = noteData.copy();
	}

	// TODO: do note judging and stuff here
	public function noteHit(note:NoteSprite):Void
	{
		var strumlineNote:StrumlineNote = getStrumNoteForDirection(note.data.direction);

		if ((note.data?.length ?? 0) > 0)
			strumlineNote.playAnimation('confirm-hold', true);
		else
			strumlineNote.playAnimation('confirm', true);

		var noteSplash:NoteSplash = noteSplashes.recycle(NoteSplash);
		noteSplash.setupNoteSplash(strumlineNote.x, strumlineNote.y, note.data.direction);

		/*if ((note.data.length ?? 0) > 0)
			{
				var holdCover:NoteHoldCover = holdCovers.recycle(NoteHoldCover);
				holdCover.setupHoldCover(strumlineNote, note.data.direction);
		}*/

		note.kill();
	}

	override public function update(elapsed:Float):Void
	{
		while (true)
		{
			if (noteDataLeft.length > 0 && noteDataLeft[0].time - conductorInUse.time <= RENDER_DISTANCE_MS)
			{
				var noteSprite:NoteSprite = notes.recycle(NoteSprite);
				noteSprite.setupNoteSprite(noteDataLeft[0]);

				if ((noteDataLeft[0].length ?? 0) > 0)
				{
					var sustainNoteSprite:SustainNoteSprite = sustainNotes.recycle(SustainNoteSprite);
					sustainNoteSprite.setupSustainSprite(noteDataLeft[0], scrollSpeed);
				}

				// FlxG.log.add('Rendered note at ${noteDataLeft[0].time}');
				noteDataLeft.shift();
			}
			else
				break;
		}

		for (note in notes.members)
		{
			if (!note.alive)
				continue;

			if (!isPlayer)
			{
				if (note.data.time <= conductorInUse.time)
				{
					noteHit(note);
				}
			}
		}

		for (sustainNote in sustainNotes.members)
		{
			if (!sustainNote.alive)
				continue;

			var strumlineNote:StrumlineNote = getStrumNoteForDirection(sustainNote.data.direction);

			if (sustainNote.data.time + sustainNote.data.length <= conductorInUse.time)
			{
				strumlineNote.playAnimation('press', true);
				// strumlineNote.holdCover.playAnimation('end', true);
			}
		}
		super.update(elapsed);
	}

	override public function draw():Void
	{
		for (note in notes.members)
		{
			if (!note.alive)
				continue;

			var strumlineNote:StrumlineNote = getStrumNoteForDirection(note.data.direction);
			note.x = strumlineNote.x;
			note.y = strumlineNote.y + calculateNoteYPos(note.data.time);
		}

		for (sustainNote in sustainNotes.members)
		{
			if (!sustainNote.alive)
				continue;

			var strumlineNote:StrumlineNote = getStrumNoteForDirection(sustainNote.data.direction);
			var strumlineMid:Float = strumlineNote.y + (STRUMLINE_SIZE / 2);

			if (sustainNote.data.time + sustainNote.data.length <= conductorInUse.time)
			{
				sustainNote.clipRect = null;
				sustainNote.kill();
				continue;
			}

			sustainNote.x = strumlineNote.x + MathUtil.center(STRUMLINE_SIZE, sustainNote.width) + 5;
			sustainNote.y = strumlineMid + calculateNoteYPos(sustainNote.data.time);

			if (sustainNote.data.time <= conductorInUse.time)
			{
				var swagRect:FlxRect = new FlxRect(0, 0, sustainNote.width / sustainNote.scale.x, sustainNote.height / sustainNote.scale.y);

				swagRect.y = (strumlineMid - sustainNote.y) / sustainNote.scale.y;
				// swagRect.height -= swagRect.y;

				FlxG.watch.addQuick('swagRect', swagRect);

				sustainNote.clipRect = swagRect;
			}
		}

		super.draw();
	}

	override function get_width():Float
	{
		return NoteDirection.allDirections.length * NOTE_SPACING;
	}

	/**
	 * Gets the strumline note for direction.
	 * @param direction The direction.
	 * @return The strumline note.
	 */
	public function getStrumNoteForDirection(direction:NoteDirection):StrumlineNote
	{
		for (strumlineNote in strumlineNotes)
		{
			if (strumlineNote.direction == direction)
			{
				return strumlineNote;
			}
		}

		return null;
	}

	/**
	 * For a note's strumTime, calculate its Y position relative to the strumline.
	 * @param strumTime The time to calculate for.
	 * @param vwoosh If the notes should go offscreen.
	 * @return Float
	 */
	public function calculateNoteYPos(strumTime:Float):Float
	{
		// TODO: change false to downScroll
		return Constants.PIXELS_PER_MS * (conductorInUse.time - strumTime) * scrollSpeed * (false ? 1 : -1);
	}
}
