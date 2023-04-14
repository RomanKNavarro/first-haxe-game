// WHOLE GAMEOVERSTATE PASTED HERE TOO. no comments are mine
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class GameOverState extends FlxState
{
	var score:Int = 0; // number of coins we've collected
	var win:Bool; // if we won or lost
	var titleText:FlxText; // the title text
	var messageText:FlxText; // the final score message text
	var scoreIcon:FlxSprite; // sprite for a coin icon
	var scoreText:FlxText; // text of the score
	var highscoreText:FlxText; // text to show the highscore
	var mainMenuButton:FlxButton; // button to go to main menu

	// WHAT'S UP WITH THIS COMMENT AND @PARAM?

	/**
	 * Called from PlayState, this will set our win and score variables
	 * @param	win		true if the player beat the boss, false if they died
	 * @param	score	the number of coins collected
	 */
	public function new(win:Bool, score:Int)
	{
		super();
		this.win = win;
		this.score = score;
	}

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = true;
		#end

		// create and add each of our items

		titleText = new FlxText(0, 20, 0, if (win) "You Win!" else "Game Over!", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		messageText = new FlxText(0, (FlxG.height / 2) - 18, 0, "Final Score:", 8);
		messageText.alignment = CENTER;
		messageText.screenCenter(FlxAxes.X);
		add(messageText);

		// coin icon is our score icon. Add to state.
		scoreIcon = new FlxSprite((FlxG.width / 2) - 8, 0, AssetPaths.coin__png);
		scoreIcon.screenCenter(FlxAxes.Y);
		add(scoreIcon);

		/*  ME: The Std class provides standard methods for manipulating basic types. 
			In this case, we are simply displaying the score */
		scoreText = new FlxText((FlxG.width / 2), 0, 0, Std.string(score), 8);
		scoreText.screenCenter(FlxAxes.Y);
		add(scoreText);

		// we want to see what the highscore is
		var highscore = checkHighscore(score);

		// put highscore in middle
		highscoreText = new FlxText(0, (FlxG.height / 2) + 10, 0, "Highscore: " + highscore, 8);
		highscoreText.alignment = CENTER;
		highscoreText.screenCenter(FlxAxes.Y);
		add(highscoreText);

		mainMenuButton = new FlxButton(0, FlxG.height - 32, "Main Menu", switchToMainMenu);
		mainMenuButton.screenCenter(FlxAxes.X);
		mainMenuButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(mainMenuButton);

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	/**
	 * This function will compare the new score with the saved highscore.
	 * If the new score is higher, it will save it as the new highscore, otherwise, it will return the saved highscore.
	 * @param	score	The new score
	 * @return	the highscore
	 */
	function checkHighscore(score:Int):Int
	{
		// if score is greater than high score, change it. Otherwise, leave it as is.
		var highscore:Int = score;
		if (FlxG.save.data.highscore != null && FlxG.save.data.highscore > highscore)
		{
			highscore = FlxG.save.data.highscore;
		}
		else
		{
			// data is less or there is no data; save current score
			FlxG.save.data.highscore = highscore;
		}
		return highscore;
	}

	/**
	 * When the user hits the main menu button, it should fade out and then take them back to the MenuState
	 */
	function switchToMainMenu():Void // void func: it returns nothing.
	{
		// anonymous callback func. that switches to MenuState() after done fading to black
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new MenuState());
		});
	}
}
