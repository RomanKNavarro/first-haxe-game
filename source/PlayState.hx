package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	// NEW ENEMIES VAR.
	var enemies:FlxTypedGroup<Enemy>;

	var player:Player;

	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	var coins:FlxTypedGroup<Coin>;

	override public function create()
	{
		map = new FlxOgmo3Loader("assets/data/turnBasedRPG.ogmo", "assets/data/room-0011.json");

		walls = map.loadTilemap("assets/images/tiles.png", "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);

		coins = new FlxTypedGroup<Coin>();
		add(coins);

		// add the enemies into the state
		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();

		map.loadEntities(placeEntities, "entities");

		add(player);
		FlxG.camera.follow(player, TOPDOWN, 1);

		super.create();
	}

	// new cases added for the enemies
	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		// we replace all the if/elif statements w/ a switch statement for better readability.
		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);

			case "coin":
				coins.add(new Coin(x + 4, y + 4)); // what's up w/ the 4? same w/ the enemies

			// enemy cases:
			case "enemy":
				enemies.add(new Enemy(x + 4, y, REGULAR));

			case "boss":
				enemies.add(new Enemy(x + 4, y, BOSS));
		}
	}

	function playerTouchCoin(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			coin.kill();
		}
	}

	/* NOW TO IMPLEMENT ENEMY VISION LOGIC.
		"Note how we need to modify two enemy variables here (seesPlayer & playerPosition, in Enemy.hx) 
		for this. The default visibility (for vars, lol) in Haxe is private, so the compiler doesn't allow
		this. We will have to make them public instead" (MAKES SENSE): */
	function checkEnemyVision(enemy:Enemy)
	{
		// what is ray()?
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxG.overlap(player, coins, playerTouchCoin);
		FlxG.collide(player, walls);

		FlxG.collide(enemies, walls); // make enemies collide with walls
		enemies.forEachAlive(checkEnemyVision); //
	}
}
