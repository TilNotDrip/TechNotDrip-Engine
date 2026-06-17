package funkin.play.managers;

import flixel.util.FlxSort;

class JudgementManager
{
  /**
   * The default judgements used for the judgement manager.
   */
  public static final DEFAULT_JUDGEMENTS:Array<Judgement> = [
    new Judgement('sick', 45, 0.015),
    new Judgement('good', 90, 0.0075),
    new Judgement('bad', 135, 0),
    new Judgement('shit', 60, -0.01),
  ];

  /**
   * Singleton instance for `JudgementManager`.
   */
  public static var instance(get, never):JudgementManager;

  static var _instance:Null<JudgementManager> = null;

  static function get_instance():JudgementManager
  {
    if (_instance == null)
      _instance = new JudgementManager(DEFAULT_JUDGEMENTS.copy());

    return _instance;
  }

  /**
   * The judgements used for this manager.
   */
  public var judgements:Array<Judgement>;

  public function new(judgements:Array<Judgement>)
  {
    this.judgements = judgements;
    refresh();
  }

  /**
   * Gives a judgement based off of a difference.
   * @param difference The difference, in miliseconds.
   * @return The judgement. If `null`, it should be counted as a miss.
   */
  public function judge(difference:Float):Null<Judgement>
  {
    final absDifference:Float = Math.abs(difference);

    for (judgement in this.judgements)
    {
      if (absDifference <= judgement.threshold)
        return judgement;
    }

    return null;
  }

  /**
   * Calculates if a note should be counted as a miss.
   * @param time The time of the current conductor.
   * @param noteTime The current time of the note.
   * @return If it should be counted as a miss.
   */
  public function isMiss(time:Float, noteTime:Float):Bool
  {
    var lastJudgement:Null<Judgement> = this.judgements[this.judgements.length - 1];

    final hitWindowEnd:Float = noteTime + (lastJudgement?.threshold ?? 0);
    return time > hitWindowEnd;
  }

  function refresh():Void
  {
    this.judgements.sort((a, b) -> FlxSort.byValues(FlxSort.DESCENDING, a.threshold, b.threshold));
  }
}

class Judgement
{
  /**
   * The ID of this judgement.
   *
   * This will be used for grabbing any extra info.
   */
  public final id:String;

  /**
   * The maximum threshold of this judgement, in miliseconds.
   *
   * The gaps between judgements will be automatically calculated.
   */
  public var threshold:Float;

  /**
   * The amount of health that this judgement will give, as a percentage.
   */
  public var health:Float;

  /**
   * If hitting this judgement will cause a note splash to appear.
   */
  public var noteSplash:Bool;

  /**
   * If hitting this judgement will cause a combo break.
   */
  public var comboBreak:Bool;

  public function new(id:String, threshold:Float, health:Float, ?noteSplash:Bool, ?comboBreak:Bool)
  {
    this.id = id;
    this.threshold = threshold;
    this.health = health;

    this.noteSplash = noteSplash ?? false;
    this.comboBreak = comboBreak ?? false;
  }
}
