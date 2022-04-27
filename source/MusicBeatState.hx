package;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Original Author: ninjaMuffin99 / (obs: you're a legend bro, i want to be like you when i grow up :P) ///
////////////////////////////////////////////////////////////////////////////////////////////////////////////

import flixel.addons.ui.FlxUIState;
import Conductor.BPMChangeEvent;
import openfl.Lib;

class MusicBeatState extends FlxUIState
{
    private var lastStep = 0;
    private var lastBeat = 0;

    private var curStep = 0;
    private var curBeat = 0;

    override function create()
    {
        (cast (Lib.current.getChildAt(0), Main));

        super.create();
    }

    override function update(elapsed:Float)
    {
        updateCurStep();
        updateBeat();

        super.update(elapsed);
    }

    private function updateBeat():Void
    {
        lastBeat = curStep;
        curBeat = Math.floor(curStep / 4);
    }

    private function updateCurStep():Void
    {
        var lastChange:BPMChangeEvent = {
            stepTime: 0,
            songTime: 0,
            bpm: 0
        }

        for (i in 0...Conductor.bpmChangeMap.length)
        {
            if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime){
				lastChange = Conductor.bpmChangeMap[i];
            }
        }

		curStep = Std.int(lastChange.songTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet));
    }
}