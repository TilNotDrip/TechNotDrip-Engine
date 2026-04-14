package funkin.data.strumline;

import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import funkin.input.FunkinControls;
import funkin.input.InputUtil;
import funkin.play.hud.HealthIcon;
import funkin.play.hud.strumline.NoteSprite;
import funkin.play.hud.strumline.Strumline;
import funkin.play.hud.strumline.SustainNoteSprite;
import funkin.sound.Conductor;
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
   * The health icon corresponding to the strumline.
   * Will be `null` if health icons are disabled through `data`.
   */
  public var healthIcon:HealthIcon;

  /**
   * The strumline sprite.
   */
  public var strumline:Strumline;

  /**
   * The conductor to use.
   */
  public var conductorInUse:Conductor;

  /**
   * Called when a Note gets hit.
   */
  public var onNoteHit:FlxTypedSignal<(note:NoteSprite, rating:String) -> Void> = new FlxTypedSignal<(note:NoteSprite, rating:String) -> Void>();

  /**
   * Called when a Note gets missed.
   */
  public var onNoteMiss:FlxTypedSignal<NoteSprite->Void> = new FlxTypedSignal<NoteSprite->Void>();

  /**
   * Called when a Sustain Note gets missed.
   */
  public var onSustainNoteMiss:FlxTypedSignal<SustainNoteSprite->Void> = new FlxTypedSignal<SustainNoteSprite->Void>();

  /**
   * Called when the health is supposed to update. The `Float` is what the health is supposed to change by.
   */
  public var onUpdateHealth:FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

  public function new(id:String, conductorInUse:Conductor)
  {
    this.id = id;
    this.conductorInUse = conductorInUse;

    var dataContent:String = Paths.content.json('gameplay/hud/funkin/strumline/$id');
    data = cast Json.parse(dataContent);

    if (data.renderStrumline)
    {
      strumline = new Strumline(this);

      strumline.y = Constants.STRUMLINE_Y_OFFSET;

      strumline.x = switch (data.strumlinePosition)
      {
        case 'left':
          MathUtil.center(FlxG.width / 2, strumline.width);
        case 'right':
          FlxG.width / 2 + MathUtil.center(FlxG.width / 2, strumline.width);
        default:
          0;
      }

      strumline.conductorInUse = conductorInUse;
      // strumline.setupNotes(parent.chart);

      if (!data.computerControlled)
      {
        onNoteHit.add(playerNoteHit);
        onNoteMiss.add(playerNoteMiss);
        onSustainNoteMiss.add(playerSustainMiss);
      }
    }

    if (data.renderIcon)
    {
      // TODO: change these variables once we got functional support for stages and characters.
      var iconID:String = id == 'opponent' ? 'dad' : 'bf';
      var iconDirection:IconDirection = id == 'opponent' ? LEFT : RIGHT;

      healthIcon = new HealthIcon(iconID, iconDirection);
    }
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
        return note.alive && input.direction == note.data.direction && Math.abs(note.data.time - input.time) < InputUtil.MISS_THRESHOLD;
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

        onNoteHit.dispatch(noteHit, rating);
        strumline.noteHit(noteHit, rating == 'sick');
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

  function playerNoteHit(note:NoteSprite, rating:String):Void
  {
    var healthChange:Float = switch (rating)
    {
      case 'sick':
        InputUtil.HEALTH_SICK_BONUS;
      case 'good':
        InputUtil.HEALTH_GOOD_BONUS;
      case 'bad':
        InputUtil.HEALTH_BAD_BONUS;
      case 'shit':
        InputUtil.HEALTH_SHIT_BONUS;
      default:
        0;
    }

    onUpdateHealth.dispatch(healthChange);
  }

  function playerNoteMiss(note:NoteSprite):Void
  {
    onUpdateHealth.dispatch(InputUtil.HEALTH_MISS_PENALTY);
  }

  function playerSustainMiss(sustainNote:SustainNoteSprite):Void
  {
    var penalty:Float = InputUtil.HEALTH_MISS_PENALTY;

    if (sustainNote.lengthLeft > 500) // Extra damage if theres more than 500 miliseconds left, i felt a lil evil >:)
    {
      // 0.15% extra penalty for each 100 miliseconds.
      var extraPenalty:Float = (InputUtil.HEALTH_MISS_PENALTY * 0.15) * Math.floor(sustainNote.lengthLeft / 100);
      extraPenalty = Math.max(extraPenalty,
        InputUtil.HEALTH_MISS_PENALTY * 3); // Maximizes at 3 times the original penalty, totaling to 4 times the original damage.
      penalty += extraPenalty;
    }

    onUpdateHealth.dispatch(penalty);
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
   * Whether the healthbar icon is rendered or not.
   * This is usually enabled by a Player. (Boyfriend, Pico, etc.)
   */
  var renderIcon:Bool;

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
