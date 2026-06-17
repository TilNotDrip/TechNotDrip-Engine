package funkin.play.managers;

import flixel.FlxBasic;
import funkin.data.song.PlaySong;
import funkin.data.song.SongFormat;
import funkin.input.InputUtil;
import funkin.play.hud.notes.NoteSprite;
import funkin.play.hud.notes.Playfield;

class ChartManager extends FlxBasic
{
  /**
   * The strumline data used in this chart.
   */
  public var strumlineData:Array<StrumlineData>;

  final parent:PlayState;

  var notesAvailable:Map<StrumlineData, Array<SongNote>>;

  public function new(parent:PlayState)
  {
    this.parent = parent;
    strumlineData = parent.song.loadStrumlineData();

    notesAvailable = [];

    super();

    createPlayfields();
    reloadChart();
  }

  function reloadChart():Void
  {
    notesAvailable.clear();

    for (data in strumlineData)
    {
      var notes:Null<Array<SongNote>> = parent.chart.notes.get(data.id);
      if (notes == null)
        continue;

      notesAvailable.set(data, notes.copy());

      final playfield:Null<Playfield> = parent.hud.playfields.getFirst(playfield -> playfield.data == data);
      if (playfield != null)
        playfield.speed = parent.chart.speed;
    }
  }

  function createPlayfields():Void
  {
    for (data in strumlineData)
    {
      if (!data.showPlayfield)
        continue;

      parent.hud.createPlayfield(data, parent.conductor);
    }
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);

    for (data => notes in notesAvailable)
    {
      final playfield:Null<Playfield> = parent.hud.playfields.getFirst(playfield -> playfield.data == data);

      var i:Int = 0;
      while (notes.length > i)
      {
        final note:SongNote = notes[i];
        final noteSprite:Null<NoteSprite> = playfield?.notes.group.getFirst(sprite -> sprite.data == note && sprite.alive);

        final shouldRender:Bool = noteSprite != null || (playfield?.isNoteOnScreen(note) ?? false);
        final shouldHit:Bool =
          {
            if (data.computerControlled)
              parent.conductor.curStepDecimal >= note.step;
            else
              false; // TODO: implement
          };

        if (!shouldRender && !shouldHit)
          break;

        if (shouldHit)
        {
          if (noteSprite != null)
            playfield?.hit(noteSprite);

          notes.remove(note);
        }
        else if (JudgementManager.instance.isMiss(parent.conductor.time, note.getTime(parent.conductor)))
        {
          if (noteSprite != null)
            playfield?.miss(noteSprite);

          notes.remove(note);
        }
        else if (shouldRender && noteSprite == null)
        {
          playfield.constructNote(note);
        }

        i++;
      }
    }
  }
}
