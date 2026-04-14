package funkin.ui.options;

typedef OptionMenuData =
{
  /**
   * The option id that this option will change.
   */
  var id:String;

  var name:String;

  var description:String;

  var type:OptionMenuType;
}

typedef OptionCategory =
{
  /**
   * The category identifier, most of the times its usually just name but lowercase.
   */
  var id:String;

  /**
   * The category name.
   */
  var name:String;

  /**
   * The category description, explains what types of settings are in this category.
   */
  var description:String;

  /**
   * All of the options inside the category that will be customized by the user to their preference..
   */
  var options:Array<OptionMenuData>;
}

enum abstract OptionMenuType(String)
{
  /**
   * Displays a checkbox graphic showing whether the option is enabled or not.
   */
  var CHECKBOX = 'checkbox';

  /**
   * Displays the current preference for that option inbetween the 2 arrow graphics.
   */
  var SELECTION = 'selection';

  /**
   * Displays a slider with the current number selection below it.
   */
  var SLIDER = 'slider';
}
