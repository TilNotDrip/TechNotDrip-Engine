package funkin.events;

class ConductorEvent extends FunkinEvent
{
  /**
   * The type of conductor event.
   */
  public final type:ConductorEventType;

  /**
   * The current step.
   */
  public final curStep:Int;

  /**
   * The current beat.
   */
  public final curBeat:Int;

  /**
   * The current measure.
   */
  public final curMeasure:Int;

  public function new(type:ConductorEventType, conductor:Conductor)
  {
    this.type = type;
    super(false);

    this.curStep = conductor.curStep;
    this.curBeat = conductor.curBeat;
    this.curMeasure = conductor.curMeasure;
  }
}

enum ConductorEventType
{
  STEP;
  BEAT;
  MEASURE;
}
