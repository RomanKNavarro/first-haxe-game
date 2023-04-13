package;

import flixel.group.FlxGroup.FlxTypedGroup; // import groups (for our coins)
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	var player:Player;

	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	var coins:FlxTypedGroup<Coin>; // new var for the coins. This is a "group" to hold all the coins in.

	/* Groups are like arrays of Flixel objects which can be used in a lot of different ways. In this case,
		since our group will only be containing coins, we will make it a FlxTypedGroup<Coin>. */
	override public function create()
	{
		map = new FlxOgmo3Loader("assets/data/turnBasedRPG.ogmo", "assets/data/room-0011.json");

		// walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls = map.loadTilemap("assets/images/tiles.png", "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);

		// add our coin group to the state
		coins = new FlxTypedGroup<Coin>();
		add(coins);

		player = new Player();

		map.loadEntities(placeEntities, "entities");

		add(player);
		FlxG.camera.follow(player, TOPDOWN, 1);
		// MAKE THE CAMERA FOLLOW THE PLAYER AROUND. TOPDOWN ISN'T USER-CREATED
		super.create();
	}

	// remember: this func. simply adds our entities to the map
	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player")
		{
			player.setPosition(entity.x, entity.y);
		}
		/* put a coin into our group (in its respective spot) every time it encounters one 
			in our Ogmo file: */
		else if (entity.name == "coin")
		{
			coins.add(new Coin(entity.x + 4, entity.y + 4));
		}
	}

	// RUN THIS WHEN PLAYER OVERLAPS COIN
	function playerTouchCoin(player:Player, coin:Coin)
	{
		// make coin disappear when overlap. Where are the "alive" and "exists" prop.s defined?
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			coin.kill();
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.overlap(player, coins, playerTouchCoin);
		// if player overlaps a coin, run PlayerTouchCoin() (callback func as used here)

		FlxG.collide(player, walls);
	}
}
