package funkin.input.action;

enum FunkinActionType
{
  /**
   * Up Key for UI States.
   */
  UI_UP;

  /**
   * Down Key for UI States.
   */
  UI_DOWN;

  /**
   * Left Key for UI States.
   */
  UI_LEFT;

  /**
   * Right Key for UI States.
   */
  UI_RIGHT;

  /**
   * Up Key for PlayState.
   */
  NOTE_UP;

  /**
   * Down Key for PlayState.
   */
  NOTE_DOWN;

  /**
   * Left Key for PlayState.
   */
  NOTE_LEFT;

  /**
   * Right Key for PlayState.
   */
  NOTE_RIGHT;

  /**
   * The accept key. Used for selecting an item.
   */
  ACCEPT;

  /**
   * The back key. Used for going back a state.
   */
  BACK;

  /**
   * The pause key. Used for pausing the game.
   */
  PAUSE;

  /**
   * The reset key. Used for utterly annihilating Boyfriend's Testicles.
   */
  RESET;
}
