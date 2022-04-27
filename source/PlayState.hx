package;

import Note.Note;
import flixel.FlxState;
import Paths.Paths;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
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

	override public function create()
	{
		super.create();

		player = new FlxSprite(100, FlxG.height - 150);
		player.frames = Paths.sparrowAtlas('Characters', 'skeleton');
		player.setGraphicSize(Std.int(player.width * 6));
		player.animation.addByPrefix('idle', 'Idle', 24, true);
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
			song = Song.loadJson('Test');
		}

		getSong();

		//play music :)
		FlxG.sound.playMusic(Paths.music('Test'));		
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
				var daStrumTime:Float = songNotes[0];
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 2);

				note = new Note(daStrumTime, daNoteData);

				noteGrp.add(note);
			}
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;

		//debug
		if(FlxG.keys.justPressed.SEVEN){
			FlxG.switchState(new ChartingState());
		}

		//update note pos
		noteGrp.forEachAlive(function(daNote:Note){
			daNote.x = (strumGrp.members[Math.floor(Math.abs(daNote.noteData))].x - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(song.speed, 2));
		});

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
			}

			if (!strumHold[spr.ID]){
				spr.animation.play('idle');
			}
		});
	}
}
