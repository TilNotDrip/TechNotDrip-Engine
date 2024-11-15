package funkin.structures;

typedef WeekStructure = {
    var name:String;

    @:optional
    var motto:String;

    var songs:Array<String>;

    @:optional
    var displayCharacters:Array<StoryCharacter>;

    @:optional
    var weekBG:String; // NOTE: Should be a path or #HEX.
}

typedef StoryCharacter = {
    var path:String;

    var position:Array<PositionStructure>;

    var animations:Array<AnimationStructure>;
}