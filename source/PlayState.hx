package;

import flixel.FlxState;
import Paths.Paths;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

class PlayState extends FlxState
{
	var player:FlxSprite;
	var strumGrp:FlxTypedGroup<FlxSprite>;
	var strums:FlxSprite;

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
		
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

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
