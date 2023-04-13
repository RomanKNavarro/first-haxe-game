package;

// NEW COIN CLASS
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Coin extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		// loadGraphic(AssetPaths.coin__png, false, 8, 8); // make our coins 8x8 pixels
		loadGraphic("assets/images/coin.png", false, 8, 8);
	}

	/*  adds cool effect to the coin: it rises vertically and fades away.
		why do we override kill()? it normally sets an object's "alive" and "exists" properties to false. 
		In this case, we want to set only "alive" to false. Objects whose exists == false don't get drawn
		or updated. 
	 */
	override function kill()
	{
		alive = false;
		/* add cool animation. It's duration is 0.33 secs. When the animation ends, we destroy with finishKill(),
			removing it from the screen. The type of the onComplete callback is FlxTween->Void (receives a single 
			FlxTween argument and returns nothing). Here, we name that "_" to indicate we don't care ab. it.
		 */
		FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_)
	{
		exists = false;
	}
}
