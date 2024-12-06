package funkin.objects.ui;

import flixel.graphics.frames.FlxFramesCollection;

class Alphabet extends FlxTypedSpriteGroup<AlphabetLetter>
{
	/**
	 * The text that this group displays.
	 */
	public var text(default, set):String;

	/**
	 * The type of letters you want to have displayed!
	 */
	public var letterType(default, set):LetterType;

	@:allow(funkin.objects.ui.AlphabetLetter)
	var textFrames:FlxFramesCollection;

	var maxHeight:Float = 0.0;

	public function new(x:Float, y:Float, text:String = '', letterType:LetterType = DEFAULT)
	{
		super(x, y);

		this.letterType = letterType;
		this.text = text;
	}

	function set_text(value:String):String
	{
		text = value;

		killTextObjects();

		if (text.length > 1)
			generateText(text);

		return text;
	}

	function set_letterType(value:LetterType):LetterType
	{
		letterType = value;

		textFrames = Paths.content.sparrowAtlas(letterType.getPath());

		for (i in 0...members.length)
		{
			members[i].letter = members[i].letter; // reinit texture
		}

		if (textFrames?.frames != null)
		{
			for (frame in textFrames.frames)
			{
				maxHeight = Math.max(maxHeight, frame.frame.height);
			}
		}

		return letterType;
	}

	function generateText(text:String):Void
	{
		var aliveLetters:Int = countLiving();

		var letterX:Float = 0;
		var letterY:Float = 0;

		var splitText:Array<String> = text.split('');

		for (i in 0...text.length)
		{
			var letter:String = splitText[i];
			switch (letter)
			{
				case ' ':
					letterX += 40;

				case '\n':
					letterX = 0;
					letterY += maxHeight;

				default:
					var letterSpr:AlphabetLetter = null;

					if (i >= aliveLetters)
					{
						letterSpr = makeLetterSpr(letter);
					}
					else
					{
						letterSpr = members[i];
						letterSpr.revive();
					}

					letterSpr.letter = letter;
					letterSpr.setPosition(letterX, letterY + maxHeight - letterSpr.height);
					add(letterSpr);

					letterX += Math.floor(letterSpr.width);
			}
		}
	}

	function makeLetterSpr(letter:String, x:Float = 0, y:Float = 0):AlphabetLetter
	{
		var letterSpr:AlphabetLetter = new AlphabetLetter(this);
		return letterSpr;
	}

	function killTextObjects():Void
	{
		forEachAlive((letter:AlphabetLetter) ->
		{
			letter.kill();
		});
	}
}

class AlphabetLetter extends FunkinSprite
{
	/**
	 * The letter that this object displays.
	 */
	public var letter(default, set):String = '';

	var head:Alphabet;

	public function new(head:Alphabet)
	{
		this.head = head;

		super();
	}

	function set_letter(value:String):String
	{
		letter = value;

		var animName:String = getLetterPrefix(letter);

		frames = head.textFrames;
		animation.addByPrefix('letter', animName, 24);

		if (animation.exists('letter'))
			animation.play('letter');
		else
			trace("[WARNING]: " + (cast(head.letterType, String)) + " doesn't have " + letter + '!');

		updateHitbox();

		return value;
	}

	function getLetterPrefix(letter:String):String
	{
		return switch (letter)
		{
			case '&':
				'-andpersand-';
			case "😠":
				'-angry faic-';
			case "'":
				'-apostraphie-';
			case "\\":
				'-back slash-';
			case ",":
				'-comma-';
			case '-':
				'-dash-';
			case '↓':
				'-down arrow-'; // U+2193
			case "”":
				'-end quote-'; // U+0022
			case "!":
				'-exclamation point-'; // U+0021
			case "/":
				'-forward slash-'; // U+002F
			case '>':
				'-greater than-'; // U+003E
			case '♥':
				'-heart-'; // U+2665
			case '♡':
				'-heart-';
			case '←':
				'-left arrow-'; // U+2190
			case '<':
				'-less than-'; // U+003C
			case "*":
				'-multiply x-';
			case '.':
				'-period-'; // U+002E
			case "?":
				'-question mark-';
			case '→':
				'-right arrow-'; // U+2192
			case "“":
				'-start quote-';
			case '↑':
				'-up arrow-'; // U+2191
			default:
				(head.letterType == BOLD) ? letter.toUpperCase() : letter;
		}
	}
}

/**
 * What the letters should look like.
 *
 * Use `getPath()` to get the location!
 */
enum abstract LetterType(String)
{
	var DEFAULT = 'default';
	var BOLD = 'bold';

	/**
	 * Gets the location of the type.
	 * @return The location
	 */
	public function getPath():String
	{
		return 'ui/fonts/alphabet/' + this;
	}
}
