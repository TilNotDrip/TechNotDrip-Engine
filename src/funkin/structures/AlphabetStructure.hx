package funkin.structures;

typedef AlphabetStructure =
{
	var offsets:Array<AlphabetOffsetStructure>;
}

typedef AlphabetOffsetStructure =
{
	> ObjectStructure.PointStructure,
	var character:String;
}
