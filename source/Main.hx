package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		// what's addChild() again? why don't we add our other states as well?
		addChild(new FlxGame(320, 240, MenuState));

		// load our stored volume (yes, as in SOUND volume) value (if there's any) when the game starts.
		var save = new FlxSave();
		save.bind("TurnBasedRPG"); // what value does this refer to?
		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}
		save.close();
	}
}
