// NEW CLASS FOR THE HUD
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

// class extends FlxTypedGroup<FlxSprite> so that it can hold all of our FlxSprite objects.
class HUD extends FlxTypedGroup<FlxSprite>
{
	// items that our HUD will be composed of:
	var background:FlxSprite;
	var healthCounter:FlxText;
	var moneyCounter:FlxText;
	var healthIcon:FlxSprite;
	var moneyIcon:FlxSprite;

	public function new()
	{
		// this is a void func: it returns nothing.
		super();
		background = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK); // black background
		background.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE); // white line at bottom
		healthCounter = new FlxText(16, 2, 0, "3 / 3", 8);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1); // health counter
		moneyCounter = new FlxText(0, 2, 0, "0", 8);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1); // border added to money counter
		// set health icon in the middle of the health counter:
		// healthIcon = new FlxSprite(4, healthCounter.y + (healthCounter.height / 2) - 4, AssetPaths.health__png);
		healthIcon = new FlxSprite(4, healthCounter.y + (healthCounter.height / 2) - 4, "assets/images/health.png");
		// do same with new money icon
		// moneyIcon = new FlxSprite(FlxG.width - 12, moneyCounter.y + (moneyCounter.height / 2) - 4, AssetPaths.coin__png);
		moneyIcon = new FlxSprite(FlxG.width - 12, moneyCounter.y + (moneyCounter.height / 2) - 4, "assets/images/coin.png");
		moneyCounter.alignment = RIGHT; // align money counter to right
		moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
		add(background);
		add(healthIcon);
		add(moneyIcon);
		add(healthCounter);
		add(moneyCounter);
		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	// func. to update our HUD as needed:
	public function updateHUD(health:Int, money:Int)
	{
		healthCounter.text = health + " / 3"; // healthCounter is equal to current health (init value is 3)
		moneyCounter.text = Std.string(money); // what is std.string()?
		moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
	}
}
