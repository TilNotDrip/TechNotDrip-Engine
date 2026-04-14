package funkin;

import flixel.FlxBasic;
import flixel.FlxGame;
import flixel.util.typeLimit.NextState;
import funkin.ui.PerformanceStats;
import funkin.ui.title.TitleState;
import lime.utils.Assets as LimeAssets;
import openfl.utils.Assets as OpenFlAssets;
#if FUNKIN_DISCORD_RPC
import funkin.api.discord.DiscordRPC;
#end

class FunkinGame extends FlxGame
{
  /**
   * The current instance of `FunkinGame`.
   */
  public static var instance:FunkinGame;

  /**
   * The FPS and Memory overlay at the top left of the screen.
   */
  public var performanceStats:PerformanceStats;

  final flxGameData:FlxGameInit = {
    width: 1280,
    height: 720,
    initState: TitleState.new,
    framerate: 60,
    showSplash: false,
    startFullscreen: false
  };

  public function new()
  {
    super(flxGameData.width, flxGameData.height, flxGameData.initState, flxGameData.framerate, flxGameData.framerate, !flxGameData.showSplash,
      flxGameData.startFullscreen);

    instance = this;
  }

  override function create(_):Void
  {
    super.create(_);

    performanceStats = new PerformanceStats();
    addChild(performanceStats);

    OpenFlAssets.cache.enabled = false;
    LimeAssets.cache.enabled = false;

    #if FLX_MOUSE
    FlxG.mouse.useSystemCursor = true;
    FlxG.mouse.visible = false;
    #end

    FlxG.fixedTimestep = false;

    FlxSprite.defaultAntialiasing = true;

    Save.instance.setOptionValues();

    #if FUNKIN_DISCORD_RPC
    DiscordRPC.loadDiscordConfig();
    DiscordRPC.initialize();
    DiscordRPC.largeImageText = 'Version: ' + Constants.TECHNOTDRIP_VERSION;
    #end

    stage.window.onClose.add(closeWindow);
  }

  override function onEnterFrame(_):Void
  {
    ticks = getTicks();
    _elapsedMS = ticks - _total;
    _total = ticks;

    if (soundTray != null && soundTray.active)
      soundTray.update(_elapsedMS);

    if (performanceStats != null)
      performanceStats.update(_elapsedMS / 1000);

    if (_lostFocus && FlxG.autoPause)
      return;

    if (FlxG.vcr.paused)
    {
      if (FlxG.vcr.stepRequested)
      {
        FlxG.vcr.stepRequested = false;
      }
      else if (_nextState == null)
      {
        #if FLX_DEBUG
        debugger.update();
        // If the interactive debug is active, the screen must
        // be rendered because the user might be doing changes
        // to game objects (e.g. moving things around).
        if (debugger.interaction.isActive())
        {
          draw();
        }
        #end

        return;
      }
    }

    step();

    #if FLX_DEBUG
    FlxBasic.visibleCount = 0;
    #end

    draw();

    #if FLX_DEBUG
    debugger.stats.visibleObjects(FlxBasic.visibleCount);
    debugger.update();
    #end
  }

  /**
   * Called when the game gets closed.
   */
  public function closeWindow():Void
  {
    trace('Bye Bye!');
    Save.instance.flush();
  }
}

typedef FlxGameInit =
{
  var width:Int;
  var height:Int;
  var initState:InitialState;
  var framerate:Int;
  var showSplash:Bool;
  var startFullscreen:Bool;
}
