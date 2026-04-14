package funkin.ui;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import funkin.data.alphabet.AlphabetData;
import haxe.Json;

@:nullSafety
class Alphabet extends FunkinSprite
{
  /**
   * The ID representing the current atlas font.
   */
  public var atlasFontID(default, set):String = '';

  /**
   * Data for the current atlas font.
   */
  public var atlasFontData:Null<AlphabetData>;

  /**
   * The text that `this` Alphabet displays.
   */
  public var text(default, set):String = '';

  /**
   * The width of this text. 0 to make width free.
   */
  public var fieldWidth:Float = 0;

  /**
   * Alignment.
   */
  public var alignment(default, set):AlphabetAlignment = LEFT;

  var _textRects:Array<AlphabetRect> = [];
  var _wordMaxHeight:Float = 0;
  var _fontMaxHeight:Float = 0;

  public function new(x:Float, y:Float, ?text:String = '', ?fieldWidth:Float = 0, ?font:String)
  {
    super(x, y);

    _textRects = [];

    this.atlasFontID = font ?? Constants.DEFAULT_ATLAS_FONT;
    this.fieldWidth = fieldWidth ?? 0;
    this.text = text ?? '';
  }

  function populateAnimations():Void
  {
    if (text.length < 1)
      return;

    for (letter in text.split(''))
    {
      if (animation.exists(letter) || [' ', '\n'].contains(letter))
        continue;

      var prefix:String = getLetterPrefix(letter);
      var prefixLower:String = prefix.toLowerCase();

      var foundFrames:Bool = false;
      var lowercaseMatch:Null<String> = null;

      for (frame in frames.frames)
      {
        if (frame.name == null)
          continue;

        if (!foundFrames)
        {
          if (frame.name.startsWith(prefix))
          {
            foundFrames = true;
            continue;
          }

          if (lowercaseMatch == null && frame.name.toLowerCase().startsWith(prefixLower))
            lowercaseMatch = frame.name.substring(0, prefix.length);
        }
      }

      if (!foundFrames)
      {
        if (lowercaseMatch != null)
        {
          prefix = lowercaseMatch;
        }
        else
        {
          trace('[WARNING] No Atlas Letter found for ${letter}! Using fallback...');
          prefix = getLetterPrefix('?');
        }
      }

      animation.addByPrefix(letter, prefix, 24, true);
    }

    for (anim in animation.getAnimationList())
      anim.play(true);
  }

  function updateText():Void
  {
    // TODO: this code is REALLY scuffed, make this better later.

    for (rect in _textRects)
      rect.rect.put();

    _textRects.resize(0);

    if (text.length < 1)
      return;

    var words:Array<Array<Array<AlphabetRect>>> = [[[]]];
    var lastX:Float = 0;
    for (letter in text.split(''))
    {
      var curLine:Array<Array<AlphabetRect>> = words[words.length - 1];
      var curWord:Int = curLine.length - 1;
      switch (letter)
      {
        case ' ':
          lastX = 0;
          curLine.push([]);
          curWord++;
          continue;

        case '\n':
          lastX = 0;
          words.push([[]]);
          curLine = words[words.length - 1];
          continue;
      }

      // TODO: remove this once HaxeFlixel has been null-safed.
      @:nullSafety(Off)
      var anim:Null<FlxAnimation> = this.animation.getByName(letter);
      var frame:Null<FlxFrame> = frames.frames[anim?.frames[0] ?? 0];
      if (frame == null)
        continue;

      var rect:FlxRect = FlxRect.get(lastX, 0, frame.sourceSize.x, frame.sourceSize.y);

      for (offset in atlasFontData?.offsets ?? [])
      {
        if (offset?.character != letter)
          continue;

        rect.offset(offset?.x ?? 0, offset?.y ?? 0);
        break;
      }

      curLine[curWord]?.push({letter: letter, rect: rect});

      lastX = rect.right;
    }

    var curY:Float = 0;
    var realLines:Array<Array<AlphabetRect>> = [[]];
    while (words.length > 0)
    {
      var line:Null<Array<Array<AlphabetRect>>> = words.shift();
      if (line == null)
        continue;

      var lineWidth:Float = 0;
      while (line.length > 0)
      {
        var word:Null<Array<AlphabetRect>> = line.shift();
        if (word == null)
          continue;

        var width:Float = word[word.length - 1]?.rect.right ?? 0;

        if (fieldWidth > 0 && lineWidth + width >= (fieldWidth / this.scale.x))
        {
          line.insert(0, word);
          words.insert(0, line);
          break;
        }

        for (letter in word)
        {
          letter.rect.offset(lineWidth, 0);
          realLines[realLines.length - 1].push(letter);
        }

        // TODO: softcode this number
        lineWidth += 40;
        lineWidth += width;
      }
      realLines.push([]);
    }

    for (line in realLines)
    {
      // Skip it if the line is fully empty
      if (line.length == 0 && realLines.indexOf(line) == realLines.length - 1)
        continue;

      // Var for line height
      var currentLineHeight:Float = 0;
      for (letter in line)
      {
        currentLineHeight = Math.max(currentLineHeight, letter.rect.height);
      }

      // if the line is empty its gonna use the default height so newline actually takes vertical space
      if (currentLineHeight == 0)
      {
        currentLineHeight = _fontMaxHeight;
      }

      var fullWidth:Float = (fieldWidth <= 0) ? FlxG.width : fieldWidth;
      // If line is empty, width is 0
      var lineWidth:Float = (line.length > 0) ? line[line.length - 1].rect.right : 0;

      var xOffset:Float = switch (alignment)
      {
        case LEFT:
          0;
        case CENTER:
          (fullWidth / this.scale.x - lineWidth) / 2;
        case RIGHT:
          (fullWidth / this.scale.x - lineWidth);
      };

      for (letter in line)
      {
        letter.rect.offset(xOffset, 0);

        letter.rect.y += curY + (currentLineHeight - letter.rect.height);

        letter.rect.x *= this.scale.x;
        letter.rect.y *= this.scale.y;
        letter.rect.width *= this.scale.x;
        letter.rect.height *= this.scale.y;

        _textRects.push(letter);
      }

      // TODO : MAKE PADDING A VARIABLE
      curY += currentLineHeight + 5;
    }
  }

  override public function update(elapsed:Float):Void
  {
    var lettersDone:String = '';
    for (letter in text.split(''))
    {
      if (lettersDone.contains(letter))
        continue;

      // TODO: remove this once HaxeFlixel has been null-safed.
      @:nullSafety(Off)
      var anim:Null<FlxAnimation> = this.animation.getByName(letter);
      anim?.update(elapsed);
      lettersDone += letter;
    }

    super.update(elapsed);
  }

  override public function draw():Void
  {
    if (alpha == 0)
      return;

    for (camera in this.getCamerasLegacy())
    {
      if (!camera.visible || !camera.exists || !isOnScreen(camera))
        continue;

      drawLetters(camera);

      #if FLX_DEBUG
      FlxBasic.visibleCount++;
      #end
    }

    #if FLX_DEBUG
    if (FlxG.debugger.drawDebug)
      drawDebug();
    #end
  }

  override public function isOnScreen(?camera:FlxCamera):Bool
  {
    return true;
  }

  var letterMatrixes:Array<FlxMatrix> = [];

  function drawLetters(camera:FlxCamera):Void
  {
    var mat:FlxMatrix = this._matrix;
    mat.identity();

    var point:FlxPoint = FlxPoint.weak(width / 2, height / 2);

    mat.translate(-point.x, -point.y);

    var doFlipX:Bool = this.checkFlipX();
    var doFlipY:Bool = this.checkFlipY();

    if (doFlipX)
    {
      mat.scale(-1, 1);
      mat.translate(frame.sourceSize.x, 0);
    }

    if (doFlipY)
    {
      mat.scale(1, -1);
      mat.translate(0, frame.sourceSize.y);
    }

    mat.translate(point.x, point.y);
    mat.scale(scale.x, scale.y);

    point.put();

    if (angle != 0)
    {
      // TODO: find a way to also angle the positions.
      updateTrig();
      mat.rotateWithTrig(_cosAngle, _sinAngle);
    }

    getScreenPosition(_point, camera);
    // _point.x += origin.x - offset.x;
    // _point.y += origin.y - offset.y;
    mat.translate(_point.x, _point.y);

    for (i => letter in _textRects)
    {
      if (letterMatrixes[i] == null)
        letterMatrixes[i] = new FlxMatrix();

      letterMatrixes[i].copyFrom(mat);
      letterMatrixes[i].translate(letter.rect.x, letter.rect.y);

      // TODO: remove this once HaxeFlixel has been null-safed.
      @:nullSafety(Off)
      var anim:Null<FlxAnimation> = this.animation.getByName(letter.letter);
      var frame:Null<FlxFrame> = frames.frames[anim?.curIndex ?? 0];
      if (frame == null)
        continue;

      camera.drawPixels(frame, null, letterMatrixes[i], colorTransform, blend, antialiasing, shader);
    }
  }

  function set_text(value:String):String
  {
    text = value;
    populateAnimations();
    updateText();
    return value;
  }

  function set_atlasFontID(value:String):String
  {
    atlasFontID = value;

    var path:String = 'ui/fonts/alphabet/${atlasFontID}';
    var jsonContent:String = Paths.content.json(path);

    loadFrames(path);
    atlasFontData = cast Json.parse(jsonContent);

    _fontMaxHeight = 0;
    for (frame in frames.frames)
    {
      if (frame.sourceSize.y > _fontMaxHeight)
        _fontMaxHeight = frame.sourceSize.y;
    }

    if (_fontMaxHeight == 0)
      _fontMaxHeight = 60;

    this.text = text;

    return atlasFontID;
  }

  function set_alignment(value:AlphabetAlignment):AlphabetAlignment
  {
    alignment = value;
    this.text = text;
    return value;
  }

  override function get_width():Float
  {
    var toReturn:Float = 0;

    for (letter in _textRects)
      toReturn = Math.max(letter.rect.right, toReturn);

    return toReturn;
  }

  override function get_height():Float
  {
    var toReturn:Float = 0;

    for (letter in _textRects)
      toReturn = Math.max(letter.rect.bottom, toReturn);

    return toReturn;
  }

  static function getLetterPrefix(letter:String):String
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
        letter;
    }
  }
}

enum AlphabetAlignment
{
  LEFT;
  CENTER;
  RIGHT;
}

typedef AlphabetRect =
{
  letter:String,
  rect:FlxRect
}
