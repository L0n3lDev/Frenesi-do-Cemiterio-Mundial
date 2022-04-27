package;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Original Author: ninjaMuffin99 / (obs: you're a legend bro, i want to be like you when i grow up :P) ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////
import flixel.FlxG;
import flixel.FlxSprite;

class Note extends FlxSprite
{
	public var strumTime:Float;
	public var noteData:Int;

	public function new(?strumTime:Float, ?noteData:Int)
	{
		super();

		x += 2000;
		y = FlxG.height - 420;

		this.noteData = noteData;
		this.strumTime = strumTime;

		// load Graphic
		loadGraphic(Paths.image("Skins", 'default'), true, 23, 27);
		animation.add('note', [3]);
		setGraphicSize(Std.int(width * 6));
		updateHitbox();

		switch (noteData)
		{
			case 1:
				y += 200;
		}

		animation.play('note');
	}
}
