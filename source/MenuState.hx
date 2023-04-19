package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var titleText:FlxText;
	var playButton:FlxButton;
	var optionsButton:FlxButton;
	// if in desktop, show this exitButton for when in fullscreen.
	#if desktop
	var exitButton:FlxButton;
	#end

	override public function create()
	{
		// exit desktop button with clickExit() callback func. for when the user is in fullsreen
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
		// optionsButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav); // sound for options button
		optionsButton.x = (FlxG.width / 2) + 10;
		optionsButton.y = FlxG.height - optionsButton.height - 10;
		add(optionsButton);

		#if desktop
		exitButton = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
		exitButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		add(exitButton);
		#end

		/* 	NEW CONDITIONAL FOR MUSIC. We put this in create() b/c we want the music to play as soon as the
			game starts. We are also checking to see if the music is already playing so we don't restart it
			unnecessarily */
		if (FlxG.sound.music == null) // don't restart the music if it's already playing
		{
			#if flash
			// FlxG.sound.playMusic(AssetPaths.HaxeFlixel_Tutorial_Game__ogg, 1, true);
			FlxG.sound.playMusic("assets/music/HaxeFlixel_Tutorial_Game.mp3", 1, true);
			#else
			FlxG.sound.playMusic("assets/music/HaxeFlixel_Tutorial_Game.ogg", 1, true);
			#end
		}

		// make menu fade in from black in 0.33 of a second (fast)
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	} // callback func used on line 24 by our exit button

	function clickPlay()
	{
		// WHAT DOES THIS DO? fade out when switching states.
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new PlayState());
		});
	}

	function clickOptions()
	{
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new OptionsState());
		});
		// FlxG.switchState(new OptionsState());
	}

	#if desktop
	function clickExit()
	{
		// System.exit(0);
		// Sys.exit(0);
		openfl.system.System.exit(0);
		// return;
	}
	#end
}
