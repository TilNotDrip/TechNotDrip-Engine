package funkin.ui.options;

import funkin.data.object.ObjectData;
import haxe.Json;

class OptionCheckbox extends FunkinSprite
{
  /**
   * Where is the checkbox config json located?
   * Can be overriden by scripts.
   */
  public static var CHECKBOX_PATH:String = 'ui/options/checkbox';

  /**
   * The current checkbox value.
   * If changed, an animation for said change will occur.
   */
  public var checkboxValue(default, set):Bool = false;

  /**
   * Gets called when the checkbox value changes.
   * Should be used for saving the value into data.
   */
  public var valueChanged:Null<Void->Void> = null;

  public function new(checkboxValue:Bool)
  {
    super();

    var structureContent:String = Paths.content.json(CHECKBOX_PATH);
    var structure:ObjectData = Json.parse(structureContent);
    FunkinSpriteUtil.createFromStructure(this, structure);

    this.checkboxValue = checkboxValue;
    finishAnimation();
  }

  function set_checkboxValue(value:Bool):Bool
  {
    checkboxValue = value;

    playAnimation((checkboxValue ? 'checked' : 'unchecked'), true);

    if (valueChanged != null)
    {
      valueChanged();
    }

    return value;
  }
}
