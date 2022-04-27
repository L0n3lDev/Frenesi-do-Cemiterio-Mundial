package;

import Section.TpfSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import flixel.FlxG;

using StringTools;

typedef TpfSong = 
{
    var name:String;
    var notes:Array<TpfSection>;
    var bpm:Float;
    var speed:Float;
}

class Song
{
    public var name:String;
    public var notes:Array<TpfSection>;
    public var bpm:Float;
    public var speed:Float;

    public static function loadJson(name:String):TpfSong
    {
		// LOAD A JSON FILE HERE
		var rawJson = Assets.getText(Paths.json(name)).trim();

        while (!rawJson.endsWith("}"))
        {
            rawJson = rawJson.substr(0, rawJson.length - 1);
        }

		trace('loading: $rawJson');

        return parseJson(rawJson);
    }

    public static function parseJson(rawJson:String):TpfSong
    {
		// PARSE THE JSON FILE
        var json:TpfSong = cast JsonParser.parse(rawJson).song;

        trace('parsed: $json');

        return json;      
    }
}