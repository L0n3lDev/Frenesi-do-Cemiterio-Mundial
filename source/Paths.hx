package;

import flixel.graphics.frames.FlxAtlasFrames;

class Paths 
{
    static function getPath(library:String, type:String, file:String, ext:String)
    {
        return 'assets/$library/$type/$file.$ext';
    }

	static public function sparrowAtlas(type:String, file:String)
    {
		return FlxAtlasFrames.fromSparrow(getPath('images', type, file, 'png'), getPath('images', type, file, 'xml'));
    }

    static public function image(type:String, file:String)
    {
        return getPath('images', type, file, 'png');
    }
}