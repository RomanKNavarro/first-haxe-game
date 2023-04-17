//  WHOLE ASS OPTIONS MENU COPIED.
package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class OptionsState extends FlxState
{
	// define our screen elements
	var titleText:FlxText;
	var volumeBar:FlxBar;
	var volumeText:FlxText;
	var volumeAmountText:FlxText;
	var volumeDownButton:FlxButton;
	var volumeUpButton:FlxButton; // VOLUME UP needs fixing
	var clearDataButton:FlxButton;
	var backButton:FlxButton;

	// what is this?
	/* this is super interesting. It's called "conditional compilation". By running 
		"lime test html5 -D desktop", the game will run w/ a fullscreen button in the options.
		As for why this code is dark, idk. It works fine. */
	#if desktop
	var fullscreenButton:FlxButton;
	#end

	// why override again?
	override public function create():Void
	{
		// setup and add our objects to the screen
		titleText = new FlxText(0, 20, 0, "Options", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		// volume text
		volumeText = new FlxText(0, titleText.y + titleText.height + 10, 0, "Volume", 8);
		volumeText.alignment = CENTER;
		volumeText.screenCenter(FlxAxes.X);
		add(volumeText);

		// the volume buttons will be smaller than 'default' buttons
		// x, y, text, callback
		volumeDownButton = new FlxButton(8, volumeText.y + volumeText.height + 2, "+", clickVolumeDown);
		volumeDownButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		// volumeDownButton.loadGraphic("assets/images/button.png", true, 20, 20);
		volumeDownButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(volumeDownButton);

		volumeUpButton = new FlxButton(FlxG.width - 28, volumeDownButton.y, "-", clickVolumeUp);
		volumeUpButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		// volumeDownButton.loadGraphic("assets/images/button.png", true, 20, 20);
		volumeUpButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(volumeUpButton);

		// a FlxBar object made out of our volume buttons. Cool
		volumeBar = new FlxBar(volumeDownButton.x + volumeDownButton.width + 4, volumeDownButton.y, LEFT_TO_RIGHT, Std.int(FlxG.width - 64),
			Std.int(volumeUpButton.height));
		volumeBar.createFilledBar(0xff464646, FlxColor.WHITE, true, FlxColor.WHITE);
		add(volumeBar);

		// here's how we get the volume's value
		volumeAmountText = new FlxText(0, 0, 200, (FlxG.sound.volume * 100) + "%", 8);
		volumeAmountText.alignment = CENTER;
		volumeAmountText.borderStyle = FlxTextBorderStyle.OUTLINE;
		volumeAmountText.borderColor = 0xff464646;
		volumeAmountText.y = volumeBar.y + (volumeBar.height / 2) - (volumeAmountText.height / 2);
		volumeAmountText.screenCenter(FlxAxes.X);
		add(volumeAmountText);

		/* fullscreen button, with a big callback func that uses ternary. If clicked, it's text changes from 
			"WINDOWED" to 'FULLSCREEN'. Easy. */
		#if desktop
		fullscreenButton = new FlxButton(0, volumeBar.y + volumeBar.height + 8, FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED", clickFullscreen);
		fullscreenButton.screenCenter(FlxAxes.X);
		add(fullscreenButton);
		#end

		// clear data button. Pressing it deletes the currently saved games. Wow.
		clearDataButton = new FlxButton((FlxG.width / 2) - 90, FlxG.height - 28, "Clear Data", clickClearData);
		clearDataButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(clearDataButton);

		backButton = new FlxButton((FlxG.width / 2) + 10, FlxG.height - 28, "Back", clickBack);
		backButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(backButton);

		// update our bar to show the current volume level
		updateVolume();

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	/* don't understand why "#if desktop" is needed here. Guess so we don't accidently use it for 
		when not on DESKTOP lol */
	#if desktop
	function clickFullscreen()
	{
		FlxG.fullscreen = !FlxG.fullscreen;
		fullscreenButton.text = FlxG.fullscreen ? "FULLSCREEN" : "WINDOWED";
		/* now this is interesting: we save the fullscreen value so the game can remember if the user is 
			windowed or on fullscreen for the next time they load up the game */
		FlxG.save.data.fullscreen = FlxG.fullscreen;
	}
	#end

	/**
	 * The user wants to clear the saved data - we just call erase on our save object and then reset the volume to .5
	 */
	function clickClearData()
	{
		FlxG.save.erase();
		FlxG.sound.volume = 0.5;
		updateVolume();
	}

	/**
	 * The user clicked the back button - close our save object, and go back to the MenuState
	 */
	function clickBack()
	{
		FlxG.save.flush();
		FlxG.camera.fade(FlxColor.BLACK, .33, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}

	/**
	 * The user clicked the down button for volume - we reduce the volume by 10% and update the bar
	 */
	function clickVolumeDown()
	{
		FlxG.sound.volume -= 0.1;
		FlxG.save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	/**
	 * The user clicked the up button for volume - we increase the volume by 10% and update the bar
	 */
	function clickVolumeUp()
	{
		FlxG.sound.volume += 0.1;
		FlxG.save.data.volume = FlxG.sound.volume;
		updateVolume();
	}

	/**
	 * Whenever we want to show the value of volume, we call this to change the bar and the amount text
	 */
	function updateVolume()
	{
		var volume:Int = Math.round(FlxG.sound.volume * 100);
		volumeBar.value = volume;
		volumeAmountText.text = volume + "%";
	}
}
