package funkin.data;

import flixel.util.FlxSort;
import funkin.objects.gameplay.strumline.NoteSprite;
import funkin.objects.gameplay.strumline.Strumline;
import funkin.util.FunkinControls;
import funkin.util.InputUtil;
import haxe.Json;

class StrumlineData
{
	/**
	 * The strumline ID.
	 */
	public final id:String;

	/**
	 * The strumline data structure.
	 * Scripts can overwrite this.
	 */
	public var data:StrumlineDataStructure;

	/**
	 * The character corresponding to the strumline.
	 * It is currently a string, as character rendering is not implemented.
	 */
	public var character:String;

	/**
	 * The strumline sprite.
	 */
	public var strumline:Strumline;

	/**
	 * The conductor to use.
	 */
	public var conductorInUse:Conductor;

	public function new(id:String)
	{
		this.id = id;

		var dataContent:String = Paths.content.json('gameplay/strumlineData/$id');
		data = cast Json.parse(dataContent);
	}

	public function update():Void
	{
		if (data.computerControlled)
			return;

		controlPressed();
		controlReleased();
		handleNoteInput();
	}

	private function controlPressed():Void
	{
		var controlArray:Array<Bool> = [
			FunkinControls.instance.justPressed.NOTE_LEFT,
			FunkinControls.instance.justPressed.NOTE_DOWN,
			FunkinControls.instance.justPressed.NOTE_UP,
			FunkinControls.instance.justPressed.NOTE_RIGHT
		];

		for (i in 0...controlArray.length)
		{
			if (controlArray[i])
			{
				var direction:NoteDirection = cast(i, NoteDirection);
				@:privateAccess
				if (strumline != null)
				{
					strumline.currentlyPressed[direction] = true;
					notesPressed.push({direction: direction, time: conductorInUse.time});
				}
			}
		}
	}

	private function controlReleased():Void
	{
		var controlArray:Array<Bool> = [
			FunkinControls.instance.justReleased.NOTE_LEFT,
			FunkinControls.instance.justReleased.NOTE_DOWN,
			FunkinControls.instance.justReleased.NOTE_UP,
			FunkinControls.instance.justReleased.NOTE_RIGHT
		];

		for (i in 0...controlArray.length)
		{
			// trace(controlArray[i]);
			if (controlArray[i])
			{
				var direction:NoteDirection = cast(i, NoteDirection);
				@:privateAccess
				if (strumline != null)
				{
					strumline.currentlyPressed[direction] = false;
					notesReleased.push({direction: direction, time: conductorInUse.time});
				}
			}
		}
	}

	var notesPressed:Array<InputHit> = [];
	var notesReleased:Array<InputHit> = [];

	public function handleNoteInput():Void
	{
		notesPressed.sort(function(a:InputHit, b:InputHit)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		});

		notesReleased.sort(function(a:InputHit, b:InputHit)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time);
		});

		while (notesPressed.length > 0)
		{
			var input:InputHit = notesPressed.shift();

			/*if (strumline.isCurrentSustain(input.direction))
				{
					strumline.getStrumNoteForDirection(input.direction).playAnimation('confirm-hold');
					continue;
			}*/

			var possibleNotes:Array<NoteSprite> = strumline.notes.members.filter(function(note:NoteSprite)
			{
				return note.alive
					&& input.direction == note.data.direction
					&& Math.abs(note.data.time - input.time) < InputUtil.MISS_THRESHOLD;
			});

			possibleNotes.sort(function(a:NoteSprite, b:NoteSprite)
			{
				return FlxSort.byValues(FlxSort.ASCENDING, a.data.time /* - input.time*/, b.data.time /* - input.time*/);
			});

			if (possibleNotes.length > 0)
			{
				// TODO: do more input checking
				var noteHit:NoteSprite = possibleNotes[0];

				var noteDiff:Float = input.time - noteHit.data.time;
				var rating:String = InputUtil.judgeNote(noteDiff);
				var score:Int = InputUtil.scoreNote(noteDiff);

				strumline.noteHit(noteHit, rating == 'sick');
				trace(rating);
				trace(score);
			}
			else
				strumline.getStrumNoteForDirection(input.direction).playAnimation('press', true);
		}

		while (notesReleased.length > 0)
		{
			var input:InputHit = notesReleased.shift();

			strumline.getStrumNoteForDirection(input.direction).playAnimation('static', true);
		}
	}
}

typedef StrumlineDataStructure =
{
	/**
	 * If the strumline is controlled by a computer.
	 * Otherwise `controls` will be used for input.
	 */
	var computerControlled:Bool;

	/**
	 * If the strumline is rendered or not.
	 * This is usually disabled by a Spectator. (Girlfriend, Nene, etc)
	 */
	var renderStrumline:Bool;

	/**
	 * The position of the strumline.
	 * `left`, `right`, and `custom` are the only values allowed.
	 * `custom` will require you to use scripts.
	 */
	var strumlinePosition:String; // TODO: add custom functionality.

	/**
	 * Whether ratings (Sick, Good, etc.) are rendered or not.
	 * This is usually enabled by a Player. (Boyfriend, Pico, etc.)
	 */
	var renderRatings:Bool;

	/**
	 * The RGB data to use.
	 * `player`, `character`, and `custom` are the only values allowed.
	 * `custom` will require you to use scripts.
	 */
	var rgbToUse:String; // TODO: add custom functionality.

}

typedef InputHit =
{
	time:Float,
	direction:NoteDirection
};
