package funkin.ui.overlay;

import h2d.Scene;

class FunkinOverlay extends Scene
{
  final performanceStats:PerformanceStats;
  final soundTray:SoundTray;

  public function new()
  {
    super();

    performanceStats = new PerformanceStats();
    addChild(performanceStats);

    soundTray = new SoundTray();
    addChild(soundTray);
  }
}
