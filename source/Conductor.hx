package;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Original Author: ninjaMuffin99 / (obs: you're a legend bro, i want to be like you when i grow up :P) ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////

import Song.TpfSong;

typedef BPMChangeEvent = 
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
}
