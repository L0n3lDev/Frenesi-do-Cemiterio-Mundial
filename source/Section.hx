package;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Original Author: ninjaMuffin99 / (obs: you're a legend bro, i want to be like you when i grow up :P) ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////

typedef TpfSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
    var runnerSection:Bool;
	var bpm:Float;
    var changeBPM:Bool;
}

class Section
{
    public var sectionNotes:Array<Dynamic> = [];
    public var lengthInSteps:Int = 16;
    public var runnerSection:Bool = false;
}
