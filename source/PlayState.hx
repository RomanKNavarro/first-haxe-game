package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	var hud:HUD;
	var money:Int = 0;
	var health:Int = 3;

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

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();

		map.loadEntities(placeEntities, "entities");

		add(player);
		FlxG.camera.follow(player, TOPDOWN, 1);

		// HUD ADDED TO STATE:
		hud = new HUD();
		add(hud);

		super.create();
	}

	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);

			case "coin":
				coins.add(new Coin(x + 4, y + 4));

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

			// update our hud
			money++;
			hud.updateHUD(health, money);
		}
	}

	function checkEnemyVision(enemy:Enemy)
	{
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

		FlxG.collide(enemies, walls);
		enemies.forEachAlive(checkEnemyVision);
	}
}
