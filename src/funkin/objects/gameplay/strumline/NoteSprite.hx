package funkin.objects.gameplay.strumline;

import funkin.shaders.gameplay.RGBShader;
import funkin.structures.SongStructure;

class NoteSprite extends FunkinSprite
{
	/**
	 * Data for the current note.
	 */
	public var data:NoteData;

	/**
	 * The current rgb shader.
	 */
	public var rgbShader:RGBShader;

	public function new()
	{
		super();
		loadNoteFrames();
	}

	public function setupNoteSprite(data:NoteData):Void
	{
		this.data = data;

		playAnimation(cast(data.direction, NoteDirection).name);
	}

	public function loadNoteFrames():Void
	{
		// TODO: make this softcoded
		loadFrames('gameplay/strumline/default/notes');
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		for (direction in NoteDirection.allDirections)
			addAnimation(direction.name, direction.color);
	}
}
