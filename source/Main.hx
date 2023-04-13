package;

import flixel.FlxGame;
import openfl.display.Sprite;

// THIS CLASS INITIALIZES THE GAME
class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 240, MenuState)); // ensure that our game starts at the menu
		// we change (0, 0) to (320, 240) to zoom in!
	}
}
