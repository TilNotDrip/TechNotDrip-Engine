package funkin.data.alphabet;

import funkin.data.object.ObjectData;

typedef AlphabetData =
{
  var offsets:Array<AlphabetDataOffsets>;
}

typedef AlphabetDataOffsets =
{
  > PointData,
  var character:String;
}
