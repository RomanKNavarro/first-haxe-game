package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		/* NEW: when game starts we launch it in whatever state it was last in -fullscreen or not.
			What does save.bind do? */
		var startFullscreen:Bool = false;
		var save:FlxSave = new FlxSave();
		save.bind("TurnBasedRPG");

		#if desktop
		if (save.data.fullscreen != null)
		{
			startFullscreen = save.data.fullscreen;
		}
		#end

		super();
		// what's addChild() again? why don't we add our other states as well?
		// addChild(new FlxGame(320, 240, MenuState)); <change this to this v. What are the extra args?

		// addChild(new FlxGame(320, 240, MenuState, 1, 60, 60, false, startFullscreen));
		addChild(new FlxGame(320, 240, MenuState, false, startFullscreen));

		// what happens here? idk
		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}

		// OLD
		// load our stored volume (yes, as in SOUND volume) value (if there's any) when the game starts.
		// var save = new FlxSave();
		// save.bind("TurnBasedRPG"); // what value does this refer to?
		// if (save.data.volume != null)
		// {
		// 	FlxG.sound.volume = save.data.volume;
		// }
		save.close();
	}
}
