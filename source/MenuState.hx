package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

// using code completion automatically adds proper package. Nice.
// a "FlxState" subclass. When your game is running, one - and only one - state will be the active state.
class MenuState extends FlxState
{
	// When a state is loaded, its create() function is called. This is where you want to initialize all of the things in your state.
	override public function create()
	{
		var playButton:FlxButton; // this is a FlxButton variable, "playButton"
		playButton = new FlxButton(0, 0, "Play", clickPlay); // and here is the FlxButton object itself, assigned to playButton variable.
		add(playButton);
		playButton.screenCenter(); // CENTER the button on-screen
		super.create();
	}

	// update() is where all the real magic happens - it is called every 'frame' in your game (by default 60 times per second)
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	// all functions should be global, outside of create() and update():
	function clickPlay()
	{
		FlxG.switchState(new PlayState()); // switches the state from whatever the current state is (MenuState) to a new instance of PlayState
	}
}
