package;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Original Author: ninjaMuffin99 / (obs: you're a legend bro, i want to be like you when i grow up :P) /// 
////////////////////////////////////////////////////////////////////////////////////////////////////////////

import flixel.FlxState;
import flixel.FlxG;
import openfl.net.FileReference;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxGridOverlay;
import Note.Note;
import Song.TpfSong;
import Section.TpfSection;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import haxe.Json;
import flixel.math.FlxMath;

using StringTools;

class ChartingState extends MusicBeatState
{
    var _file:FileReference;

    var curSection:Int = 0;

    public static var lastSection:Int = 0;

    var strumLine:FlxSprite;
    var curSong:String = 'Test';

    var gridSize:Int = 40;

    var gridBG:FlxSprite;
    var selector:FlxSprite;

	private var lastNote:Note;
    var addedNotes:FlxTypedGroup<Note>;

    var _song:TpfSong;

    var currentSelectedNote:Array<Dynamic>;

    var tempBpm:Float = 0;

    override function create()
    {
        curSection = lastSection;

        FlxG.mouse.visible = true;

        if (PlayState.song != null){
            _song = PlayState.song;
        }else{
            _song = {
				name: 'Blank',
				notes: [],
                bpm: 100,
                speed: 1,
            }
        }

        gridBG = FlxGridOverlay.create(gridSize, gridSize, gridSize * 16, gridSize * 2);
        gridBG.screenCenter(Y);
        add(gridBG);

        addedNotes = new FlxTypedGroup<Note>();

        tempBpm = _song.bpm;

        addSection();
        updateGrid();
        loadSong(_song.name);
        //Conductor.changeBPM(_song.bpm);
        //Conductor.mapBPMChanges(_song);

        strumLine = new FlxSprite().makeGraphic(4, FlxG.width);
        add(strumLine);

        selector = new FlxSprite().makeGraphic(gridSize, gridSize);
        add(selector);

        add(addedNotes);

        super.create();
    }

    function addSection(lengthInSteps:Int = 16):Void
    {
        var sec:TpfSection = {
            sectionNotes: [],
            lengthInSteps: lengthInSteps,
            runnerSection: false,
            bpm: _song.bpm,
        }
        _song.notes.push(sec);
    }

    function loadSong(name:String)
    {
        if (FlxG.sound.music != null){
            FlxG.sound.music.stop();
        }

        FlxG.sound.playMusic(Paths.music(name), 0.6);

        FlxG.sound.music.pause();

        FlxG.sound.music.onComplete = function(){
            FlxG.sound.music.pause();
            FlxG.sound.music.time = 0;   
            changeSection();
        };
    }

    var updatedSection:Bool = false;

    function stepStartTime(step):Float
    {
        return _song.bpm / (step / 4) / 60;
    }

    function sectionStartTime():Float
    {
        var bpm:Float = _song.bpm;
        var daPos:Float = 0;
        for (i in 0...curSection)
        {
            daPos += 4 * (1000 * 60 / bpm);
        }

        return daPos;
    }

    function getXfromStrum(strumTime:Float):Float 
    {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.x, gridBG.x + gridBG.width);
    }

    function getStrumTime(yPos:Float):Float 
    {
        return FlxMath.remapToRange(yPos, gridBG.x , gridBG.x + gridBG.width, 0, 16 * Conductor.stepCrochet);
    }

    override function update(elapsed:Float)
    {
        //debugStuff
        FlxG.watch.addQuick('section', curSection);
        FlxG.watch.addQuick('song', _song.notes[curSection]);

        Conductor.songPosition = FlxG.sound.music.time;

		strumLine.x = getXfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1)){

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

            changeSection(curSection + 1, false);
            FlxG.log.add('newSection');
        }

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(addedNotes))
			{
				addedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						deleteNote(note);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.y < gridBG.y + gridBG.height
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.x < gridBG.x + (gridSize * _song.notes[curSection].lengthInSteps)) 
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.y < gridBG.y + gridBG.height
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.x < gridBG.x + (gridSize * _song.notes[curSection].lengthInSteps))
		{
			selector.x = Math.floor(FlxG.mouse.x / gridSize) * gridSize;
            selector.alpha = 1;
			selector.y = Math.floor(FlxG.mouse.y / gridSize) * gridSize;
		}else{
            selector.alpha = 0;
        }

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.song = _song;
			FlxG.sound.music.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.pause();
			}
			else
			{
				FlxG.sound.music.play();
			}
		}

        //changeSection :)
        if (FlxG.keys.anyJustPressed([D, RIGHT])){
            changeSection(curSection + 1);
        }

        if (FlxG.keys.anyJustPressed([A, LEFT])){
            changeSection(curSection - 1);
        }
        //end

        //saveChart
        if (FlxG.keys.justPressed.S){
            saveLevel();
        }

		if (FlxG.sound.music.time < 0)
			FlxG.sound.music.time = 0;

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.sound.music.pause();

			FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
        }

		_song.bpm = tempBpm;

        super.update(elapsed);
    }

    function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
    {
        if (_song.notes[sec] != null)
        {
            curSection = sec;

            updateGrid();

            if(updateMusic){
                FlxG.sound.music.pause();
				FlxG.sound.music.time = sectionStartTime();
            }

            updateGrid();
        }
        else
            trace('nullSection');
    }

    function updateGrid():Void
    {
        remove(gridBG);
        gridBG = FlxGridOverlay.create(gridSize, gridSize, gridSize * _song.notes[curSection].lengthInSteps, gridSize * 2);
        add(gridBG);

		while (addedNotes.members.length > 0)
		{
			addedNotes.remove(addedNotes.members[0], true);
		}

        var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

        for (i in sectionInfo)
        {
            var daNoteInfo = i[1];
            var daStrumTime = i[0];

            var note:Note = new Note(daStrumTime, daNoteInfo % 2);
            note.setGraphicSize(gridSize, gridSize);
            note.updateHitbox();
            note.y = Math.floor(daNoteInfo * gridSize);
			note.x = Math.floor(getXfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

            addedNotes.add(note);
        }
    }

    function deleteNote(note:Note):Void
    {
        lastNote = note;
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % 2 == note.noteData)
			{
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
    }

    private function addNote():Void
    {
        var noteStrum = getStrumTime(selector.x) + sectionStartTime();
        var noteData = Math.floor(FlxG.mouse.y / gridSize);

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData]);

        updateGrid();
    }

    //save the chart now :)
	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.name + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}