package funkin.input;

class InputUtil
{
  // TODO: Move all the Health Bonus Variables into a Rating class.

  /**
   * The amount of health the player gains when hitting a note with the SICK rating.
   */
  public static final HEALTH_SICK_BONUS:Float = 1.5 / 100.0 * 2; // +1.0%

  /**
   * The amount of health the player gains when hitting a note with the GOOD rating.
   */
  public static final HEALTH_GOOD_BONUS:Float = 0.75 / 100.0 * 2; // +0.75%

  /**
   * The amount of health the player gains when hitting a note with the BAD rating.
   */
  public static final HEALTH_BAD_BONUS:Float = 0.0 / 100.0 * 2; // +0.0%

  /**
   * The amount of health the player gains when hitting a note with the SHIT rating.
   * If negative, the player will actually lose health.
   */
  public static final HEALTH_SHIT_BONUS:Float = -1.0 / 100.0 * 2; // -1.0%

  /**
   * The amount of health the player gains, while holding a hold note, per second.
   */
  public static final HEALTH_HOLD_BONUS_PER_SECOND:Float = 6.0 / 100.0 * 2; // +6.0% / second

  /**
   * The amount of health the player loses upon missing a note.
   */
  public static final HEALTH_MISS_PENALTY:Float = -4.0 / 100.0 * 2; // 4.0%

  /**
   * The maximum score a note can receive.
   */
  public static final MAX_SCORE:Int = 500;

  /**
   * The offset of the sigmoid curve for the scoring function.
   */
  public static final SCORING_OFFSET:Float = 54.99;

  /**
   * The slope of the sigmoid curve for the scoring function.
   */
  public static final SCORING_SLOPE:Float = 0.080;

  /**
   * The minimum score a note can receive while still being considered a hit.
   */
  public static final MIN_SCORE:Float = 9.0;

  /**
   * The score a note receives when it is missed.
   */
  public static final MISS_SCORE:Int = -10;

  /**
   * The threshold at which a note hit is considered perfect and always given the max score.
   */
  public static final PERFECT_THRESHOLD:Float = 5.0;

  /**
   * The threshold at which a note hit is considered missed.
   * `160ms`
   */
  public static final MISS_THRESHOLD:Float = 160.0;

  /**
   * The time within which a note is considered to have been hit with the Sick judgement.
   * `~25% of the hit window, or 45ms`
   */
  public static final SICK_THRESHOLD:Float = 45.0;

  /**
   * The time within which a note is considered to have been hit with the Good judgement.
   * `~55% of the hit window, or 90ms`
   */
  public static final GOOD_THRESHOLD:Float = 90.0;

  /**
   * The time within which a note is considered to have been hit with the Bad judgement.
   * `~85% of the hit window, or 135ms`
   */
  public static final BAD_THRESHOLD:Float = 135.0;

  /**
   * The time within which a note is considered to have been hit with the Shit judgement.
   * `100% of the hit window, or 160ms`
   */
  public static final SHIT_THRESHOLD:Float = 160.0;

  /**
   * Determine the score a note receives under a given scoring system.
   * @param msTiming The difference between the note's time and when it was hit.
   * @return The score the note receives.
   */
  public static function scoreNote(msTiming:Float):Int
  {
    var absTiming:Float = Math.abs(msTiming);

    return switch (absTiming)
    {
      case(_ > MISS_THRESHOLD) => true:
        MISS_SCORE;
      case(_ < PERFECT_THRESHOLD) => true:
        MAX_SCORE;
      default:
        // Fancy equation.
        var factor:Float = 1.0 - (1.0 / (1.0 + Math.exp(-SCORING_SLOPE * (absTiming - SCORING_OFFSET))));

        var score:Int = Std.int(MAX_SCORE * factor + MIN_SCORE);

        score;
    }
  }

  /**
   * Determine the judgement a note receives under a given scoring system.
   * @param msTiming The difference between the note's time and when it was hit.
   * @return The judgement the note receives.
   */
  public static function judgeNote(msTiming:Float):String
  {
    var absTiming:Float = Math.abs(msTiming);

    return switch (absTiming)
    {
      case(_ < SICK_THRESHOLD) => true:
        'sick';
      case(_ < GOOD_THRESHOLD) => true:
        'good';
      case(_ < BAD_THRESHOLD) => true:
        'bad';
      case(_ < SHIT_THRESHOLD) => true:
        'shit';
      default:
        'miss';
    }
  }
}
