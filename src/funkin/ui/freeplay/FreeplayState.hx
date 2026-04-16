package funkin.ui.freeplay;

import funkin.data.song.Song;
import funkin.data.week.Week;
import funkin.play.PlayState;
import funkin.ui.freeplay.backingcards.BackingCard;
import funkin.ui.freeplay.backingcards.BoyfriendBackingCard;
import funkin.ui.freeplay.dj.FreeplayDJ;
import funkin.ui.menu.MenuState;
import funkin.ui.shaders.AngleMask;
import funkin.ui.shaders.StrokeShader;

class FreeplayState extends FunkinState
{
  /**
   * Current Selection.
   */
  public var curSelected:Int = -1;

  /**
   * Current Difficulty.
   */
  public var curDifficulty:String = '';

  /**
   * Current Variation.
   */
  public var curVariation:String = '';

  /**
   * The songs.
   */
  public var songs:Array<Song>;

  /**
   * The songs that are available with the current filter.
   */
  public var filteredSongs:Array<Song>;

  /**
   * All difficulties available.
   */
  public var difficultiesAvailable:Array<String> = [];

  /**
   * The thing behind the DJ
   */
  public var backingCard:BackingCard;

  /**
   * The Freeplay DJ.
   */
  public var dj:FreeplayDJ;

  /**
   * The dad in the bg.
   */
  public var bgDad:FunkinSprite;

  /**
   * ze angle mask shader
   */
  public var angleMaskShader:AngleMask;

  /**
   * The thing that says Official OST.
   */
  public var ostName:FlxText;

  /**
   * The song capsules. These are the things you actually select.
   */
  public var grpCapsules:FlxTypedGroup<FreeplayCapsule>;

  /**
   * Difficulty sprites and arrows are in here.
   */
  public var difficultySelector:DifficultyGroup;

  /**
   * Should there be an intro?
   */
  public var skipIntro:Bool = false;

  /**
   * Blocks the inputs, like selecting and moving.
   */
  public var blockInputs:Bool = false;

  /**
   * Is the random song playing?
   */
  public var isRandomPlaying:Bool = false;

  /**
   * The Song Position of the last song. To be used when switching between random and normal songs.
   */
  public var lastSongPos:Float = 0;

  override public function create():Void
  {
    #if FUNKIN_DISCORD_RPC
    DiscordRPC.details = 'Freeplay Menu';
    #end

    songs = [];
    filteredSongs = [];
    difficultiesAvailable = [];

    for (week in Week.fetchAllWeeks())
    {
      for (song in week.songs)
      {
        for (difficulty in song.getDifficulties(null))
        {
          if (!difficultiesAvailable.contains(difficulty))
            difficultiesAvailable.push(difficulty);
        }
        songs.push(song);
      }
    }

    angleMaskShader = new AngleMask();

    backingCard = new BoyfriendBackingCard(this);
    add(backingCard);

    bgDad = new FunkinSprite(backingCard.pinkBack.width * 0.74, 0).loadTexture('ui/freeplay/freeplayBGdad');
    bgDad.setGraphicSize(0, FlxG.height);
    bgDad.updateHitbox();
    bgDad.shader = angleMaskShader;

    var blackOverlay:FlxSprite = new FlxSprite(387.76).makeGraphic(Std.int(bgDad.width), Std.int(bgDad.height), FlxColor.BLACK);
    blackOverlay.setGraphicSize(0, FlxG.height);
    blackOverlay.updateHitbox();
    blackOverlay.shader = bgDad.shader;

    add(blackOverlay);
    add(bgDad);

    dj = new FreeplayDJ('bf');
    add(dj);

    difficultySelector = new DifficultyGroup(20, 70, difficultiesAvailable);
    difficultySelector.visible = false;
    add(difficultySelector);

    grpCapsules = new FlxTypedGroup<FreeplayCapsule>();
    add(grpCapsules);

    var randomCapsule:FreeplayCapsule = new FreeplayCapsule();
    randomCapsule.init('Random');
    grpCapsules.add(randomCapsule);

    var overhangStuff:FlxSprite = new FlxSprite(0, -100).makeGraphic(FlxG.width, 164, FlxColor.BLACK);
    add(overhangStuff);

    var sillyStroke:StrokeShader = new StrokeShader(0xFFFFFFFF, 2, 2);

    var fnfFreeplay:FlxText = new FlxText(8, 8, 0, 'FREEPLAY', 48);
    fnfFreeplay.font = Paths.location.get('ui/fonts/vcr.ttf');
    fnfFreeplay.visible = false;
    fnfFreeplay.shader = sillyStroke;
    add(fnfFreeplay);

    ostName = new FlxText(8, 8, FlxG.width - 8 - 8, 'OFFICIAL OST', 48);
    ostName.font = Paths.location.get('ui/fonts/vcr.ttf');
    ostName.alignment = RIGHT;
    ostName.visible = false;
    ostName.shader = sillyStroke;
    add(ostName);

    generateCapsules();
    changeSelection();
    changeDifficulty();

    super.create();

    if (!skipIntro)
    {
      blockInputs = true;

      backingCard.startIntroTween();

      bgDad.visible = false;

      for (i in grpCapsules.members)
        i.visible = false;

      blackOverlay.x = FlxG.width;
      FlxTween.tween(blackOverlay, {x: 387.76}, 0.7, {
        ease: FlxEase.quintOut,
        onUpdate: (_) ->
        {
          angleMaskShader.extraColor = bgDad.color;
        }
      });

      overhangStuff.y = -overhangStuff.height;
      FlxTween.tween(overhangStuff, {y: -100}, 0.3, {ease: FlxEase.quartOut});

      dj.introDone.add(() ->
      {
        blockInputs = false;

        FlxTween.color(bgDad, 0.6, 0xFF000000, 0xFFFFFFFF, {ease: FlxEase.expoOut});
        backingCard.introDone();

        bgDad.visible = true;

        for (i in grpCapsules.members)
          i.visible = true;

        difficultySelector.visible = true;

        new FlxTimer().start(1 / 24, (_) ->
        {
          fnfFreeplay.visible = true;
          ostName.visible = true;

          new FlxTimer().start(1.5 / 24, (_) ->
          {
            sillyStroke.width = 0;
            sillyStroke.height = 0;
          });
        });
      });
    }
  }

  override public function beatHit():Void
  {
    dj.beatHit();
  }

  override public function update(elapsed:Float):Void
  {
    // FINE CRUSHER ARE YOU HAPPY
    // yes
    conductor.update();
    super.update(elapsed);

    if (!blockInputs)
    {
      if (controls.justPressed.ACCEPT)
      {
        if (curSelected == -1)
          doRandom();
        else
          enterSong();
      }

      if (controls.justPressed.BACK)
      {
        FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
        FlxG.switchState(MenuState.new);
      }

      if (controls.waitAndRepeat().UI_UP)
        changeSelection(-1);

      if (controls.waitAndRepeat().UI_DOWN)
        changeSelection(1);

      if (controls.waitAndRepeat().UI_LEFT)
        changeDifficulty(-1);

      if (controls.waitAndRepeat().UI_RIGHT)
        changeDifficulty(1);
    }
  }

  /**
   * Generates the capsules.
   * @return Void
   */
  public function generateCapsules():Void
  {
    for (i => capsule in grpCapsules.members)
    {
      if (i != 0)
        capsule.kill();
    }

    for (song in filteredSongs)
    {
      var capsule:FreeplayCapsule = grpCapsules.recycle(() ->
      {
        return new FreeplayCapsule();
      });

      capsule.init(song.getDisplayName(), song.metadatas.get('default').icon);
    }

    changeSelection();
  }

  /**
   * Changes the current song selection.
   * @param index How much to change it by?
   */
  public function changeSelection(?index:Int = 0):Void
  {
    curSelected = FlxMath.wrap(curSelected + index, -1, filteredSongs.length - 1);

    if (curSelected == -1)
    {
      conductor.changeBPM(145);
      conductor.resetBPMChanges();
      var songPosToSetTo:Float = lastSongPos;
      lastSongPos = FlxG.sound.music.time;
      FlxG.sound.playMusic(Paths.content.audio('ui/freeplay/freeplayRandom'));
      FlxG.sound.music.time = songPosToSetTo;
      FlxG.sound.music?.fadeIn(2, 0, 1);
      isRandomPlaying = true;
    }
    else if (isRandomPlaying)
    {
      conductor.changeBPM(102);
      conductor.resetBPMChanges();
      var songPosToSetTo:Float = lastSongPos;
      lastSongPos = FlxG.sound.music?.time;
      FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
      FlxG.sound.music.time = songPosToSetTo;
      FlxG.sound.music?.fadeIn(2, 0, 1);
      isRandomPlaying = false;
    }

    for (i => capsule in grpCapsules.members)
    {
      i += 1;

      var curSelectedWithRandom:Int = curSelected + 1;

      capsule.selected = i == curSelectedWithRandom + 1;

      capsule.lerpPos.y = capsule.intendedY(i - curSelectedWithRandom);
      capsule.lerpPos.x = 270 + (60 * (Math.sin(i - curSelectedWithRandom)));

      if (i < curSelectedWithRandom)
        capsule.lerpPos.y -= 100; // another 100 for good measure
    }

    lookForCurrrentVariation();
  }

  /**
   * Changes the current difficulty.
   * @param index How much to change it by?
   */
  public function changeDifficulty(?index:Int = 0):Void
  {
    var difficulties:Array<String> = filteredSongs[curSelected]?.getDifficulties(null) ?? difficultiesAvailable;
    var curIndex:Int = difficulties.indexOf(curDifficulty);

    curIndex = FlxMath.wrap(curIndex + index, 0, difficulties.length - 1);

    curDifficulty = difficulties[curIndex];
    difficultySelector.changeDifficulty(curDifficulty, index);
    lookForCurrrentVariation();
    filterSongs();
  }

  /**
   * Filters songs by difficulty.
   */
  public function filterSongs():Void
  {
    var filterBefore:Array<Song> = filteredSongs.copy();
    filteredSongs = [];

    var shouldUpdateCapsules:Bool = false;
    for (i => song in songs)
    {
      if (song.getDifficulties(null).contains(curDifficulty))
        filteredSongs.push(song);

      if (!shouldUpdateCapsules && song != filterBefore[i])
        shouldUpdateCapsules = true;
    }

    if (filterBefore.length != filteredSongs.length)
      shouldUpdateCapsules = true;

    if (shouldUpdateCapsules)
      generateCapsules();
  }

  /**
   * Looks for the current variation.
   */
  public function lookForCurrrentVariation():Void
  {
    if (filteredSongs[curSelected] != null)
    {
      for (variation in filteredSongs[curSelected].getVariations())
      {
        if (filteredSongs[curSelected]?.getDifficulties(variation)?.contains(curDifficulty) ?? false)
        {
          curVariation = variation;
          break;
        }
      }
    }
  }

  /**
   * Enters a random song, if possible.
   */
  public function doRandom():Void
  {
    if (filteredSongs.length == 0)
    {
      FlxG.sound.play(Paths.content.audio('ui/menu/cancelMenu'));
      trace('No songs currently available!');
      return;
    }

    curSelected = FlxG.random.int(0, filteredSongs.length - 1);
    changeSelection();
    enterSong();
  }

  /**
   * Enters selected song.
   */
  public function enterSong():Void
  {
    FlxG.sound.play(Paths.content.audio('ui/menu/confirmMenu'));
    dj.confirm();
    grpCapsules.members[curSelected + 1]?.confirm();
    backingCard.confirm();
    FlxG.sound.music.stop();
    blockInputs = true;

    new FlxTimer().start(2, (_) ->
    {
      FlxG.switchState(() -> new PlayState({
        song: filteredSongs[curSelected],
        variation: curVariation,
        difficulty: curDifficulty
      }));
    });
  }

  override public function destroy():Void
  {
    if (isRandomPlaying)
    {
      conductor.changeBPM(102);
      conductor.resetBPMChanges();
      var songPosToSetTo:Float = lastSongPos;
      lastSongPos = FlxG.sound.music?.time;
      FlxG.sound.playMusic(Paths.content.audio('ui/menu/freakyMenu'));
      FlxG.sound.music.time = songPosToSetTo;
      FlxG.sound.music?.fadeIn(2, 0, 1);
      isRandomPlaying = false;
    }
  }
}
