package;

import Note.Note;
import flixel.FlxState;
import flixel.util.FlxColor;
import Paths.Paths;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.group.FlxGroup.FlxTypedGroup;
import Song.TpfSong;
import Section.TpfSection;

class PlayState extends MusicBeatState
{
	var player:FlxSprite;

	public static var song:TpfSong;

	//strums
	var strumGrp:FlxTypedGroup<FlxSprite>;
	var strums:FlxSprite;

	//Notes
	var noteGrp:FlxTypedGroup<Note>;
	var note:Note;
	private var unspawnNotes:Array<Note> = []; //prevent lag

	var miss:Int = 0;

	override public function create()
	{
		super.create();

		player = new FlxSprite(100, FlxG.height - 150);
		player.frames = Paths.sparrowAtlas('Characters', 'skeleton');
		player.setGraphicSize(Std.int(player.width * 6));
		player.animation.addByPrefix('idle', 'Idle', 24, true);
		player.animation.addByPrefix('miss', 'Miss', 12, false);
		player.animation.play('idle');
		add(player);

		// adding the strumGrp
		strumGrp = new FlxTypedGroup<FlxSprite>();
		add(strumGrp);

		// PLACEHOLDER CODE, make a function pls :)
		for (i in 0...2) //amount of strums
		{
			strums = new FlxSprite(250, FlxG.height - 420 + (200 * i)).loadGraphic(Paths.image("Skins", 'default'), true, 23, 27);
			strums.setGraphicSize(Std.int(strums.width * 6));
			strums.ID = i;

			strums.animation.add('idle', [0]);
			strums.animation.add('strumed', [1, 2], 30, false);

			strums.updateHitbox();

			strums.animation.play('idle');
			strumGrp.add(strums);
		}

		if (song == null){
			song = Song.loadJson("Test");
		}

		getSong();

		//play music :)
		FlxG.sound.playMusic(Paths.music(song.name));		
	}
	
	function getSong()
	{
		var songData = song;

		// adding the Notes
		noteGrp = new FlxTypedGroup<Note>();
		add(noteGrp);

		var noteData:Array<TpfSection>;

		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var daStrumTime:Float = songNotes[0];
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 2);

				note = new Note(daStrumTime, daNoteData);

				unspawnNotes.push(note);
			}
		}

		unspawnNotes.sort(sortByStrum);
	}

	function sortByStrum(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;

		//debug
		if(FlxG.keys.justPressed.SEVEN){
			FlxG.switchState(new ChartingState());
		}
		FlxG.watch.addQuick('misses:', miss);

		//update note pos
		noteGrp.forEachAlive(function(daNote:Note){
			daNote.x = (strumGrp.members[Math.floor(Math.abs(daNote.noteData))].x - 0.45 * (Conductor.songPosition - daNote.strumTime) * 1.5);//FlxMath.roundDecimal(song.speed, 2));
		});

		//add the Notes
		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				noteGrp.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		controls();
	}

	function controls()
	{
		// PLACEHOLDER CONTROLS :)
		var strumHold:Array<Bool> = [FlxG.keys.pressed.F, FlxG.keys.pressed.J];
		var strumPress:Array<Bool> = [FlxG.keys.justPressed.F, FlxG.keys.justPressed.J];

		strumGrp.forEach(function(spr:FlxSprite) 
		{
			if (strumPress[spr.ID]){
				spr.animation.play('strumed');

				//check for player hits
				noteGrp.forEach(function(daNote:Note){
					if (FlxG.overlap(daNote, spr))
					{
						trace('Hit');
						noteHit(daNote);
						noteGrp.remove(daNote);
					}
				});
			}

			if (!strumHold[spr.ID]){
				spr.animation.play('idle');
			}

			//some other checks
			noteGrp.forEach(function(daNote:Note)
			{
				// if ya miss something
				if (daNote.x + daNote.width < spr.x && daNote.alpha == 1){
					trace('Miss');
					miss++;
					player.animation.play('miss');
					player.animation.finishCallback = function(end:String)
					{
						player.animation.play('idle');
					};
					daNote.alpha = 0.5;
				}

				//if note is out of the screen
				if (daNote.x <= -FlxG.width){
					noteGrp.remove(daNote);
					trace('removed Da Note');
				}
			});
		});
	}

	function noteHit(curNote:Note)
	{
		var noteDiff:Float = Math.abs(curNote.strumTime - Conductor.songPosition);

		var noteRating:String;

		if (noteDiff > 135) // way early
			noteRating = "bad";

		else if (noteDiff > 65) // your kinda there
			noteRating = "good";

		else if (noteDiff < -65) // little late
			noteRating = "good";

		else if (noteDiff < -135) // Reeeeally late
			noteRating = "bad";

		else 
			noteRating = "perfect";

		trace(noteRating + 'Hit');
	}
}
