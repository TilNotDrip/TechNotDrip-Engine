package funkin.play;

import flixel.util.FlxSort;
import funkin.data.song.Song;
import funkin.data.song.SongData;
import funkin.play.hud.Hud;
import funkin.sound.VoicesGroup;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.story.StoryModeHandler;

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
   * Collection of all HUD elements.
   */
  public var hud:Hud;

  /**
   * The current vocals used for `this`.
   */
  public var voices:VoicesGroup;

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
      throw new Exception("Chart was not loaded.");

    if (metadata == null)
      throw new Exception("Metadata was not loaded.");

    super();
  }

  override public function create():Void
  {
    // TODO: Remove this once we got the stage in.
    // Maybe we can repurpose for a minimal mode?

    var greyBG:FunkinSprite = new FunkinSprite();
    greyBG.loadTexture('#323232', Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5));
    greyBG.screenCenter();
    add(greyBG);

    hud = new Hud({
      ui: 'funkin',
      downScroll: false // TODO: THE DRILL YOU KNOW IT
    });
    hud.generateStrumlines();
    add(hud);

    generateSong();

    super.create();
  }

  /**
   * Generate everything song-related.
   */
  public function generateSong():Void
  {
    FlxG.sound.playMusic(Paths.content.audio('gameplay/songs/${song.id}/Inst'), 1, false);
    FlxG.sound.music.stop();

    voices = new VoicesGroup(song.id);
    voices.traceInfo();

    FlxG.sound.music.play();
    voices.play();

    conductor.setupBPMChanges(metadata.bpmChanges);
    conductor.sectionHit.add(voices.tryResync);
  }

  override public function update(elapsed:Float):Void
  {
    conductor.update();

    super.update(elapsed);

    // TODO: make a real debugging keybind for ending the song early.
    if (controls.justPressed.BACK || isSongFinished())
    {
      finishSong();
    }
  }

  /**
   * Check to see if the song is finished.
   * @return If the song is finished or not.
   */
  public function isSongFinished():Bool
  {
    for (sound in voices.sounds.concat([FlxG.sound.music]))
    {
      // Since `active` gets flipped when the sound is inactive, we can assume thats when it's finished.
      // Theoretically you can also trick the game by stopping all the sounds, which might be useful for modders.

      if (sound.active)
        return false;
    }

    return true;
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

      FlxG.switchState(FreeplayState.new);
    }
  }
}

typedef PlayStateParams =
{
  var song:Song;
  var difficulty:String;
  var variation:String;
}
