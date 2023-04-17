package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class MenuState extends FlxState
{
	var titleText:FlxText;
	var optionsButton:FlxButton;

	override public function create()
	{
		var playButton:FlxButton;

		titleText = new FlxText(20, 0, 0, "HaxeFlixel\nTutorial\nGame", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(X);
		add(titleText);

		playButton = new FlxButton(0, 0, "Play", clickPlay);
		// make sound when play button is pressed. It's that simple!
		playButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		playButton.x = (FlxG.width / 2) - playButton.width - 10;
		playButton.y = FlxG.height - playButton.height - 10;
		add(playButton);

		optionsButton = new FlxButton(0, 0, "Options", clickOptions);
		optionsButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav); // sound for options button
		optionsButton.x = (FlxG.width / 2) + 10;
		optionsButton.y = FlxG.height - optionsButton.height - 10;
		add(optionsButton);

		/* NEW CONDITIONAL FOR MUSIC. We put this in create() b/c we want the music to play as soon as the 
			game starts. We are also checking to see if the music is already playing so we don't restart it
			unnecessarily */
		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			// FlxG.sound.playMusic(AssetPaths.HaxeFlixel_Tutorial_Game__ogg, 1, true);
			FlxG.sound.playMusic("assets/music/HaxeFlixel_Tutorial_Game.ogg", 1, true);
		}

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function clickPlay()
	{
		FlxG.switchState(new PlayState());
	}

	function clickOptions()
	{
		FlxG.switchState(new OptionsState());
	}
}
