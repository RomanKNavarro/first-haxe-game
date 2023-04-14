package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

var inCombat:Bool = false;
var combatHud:CombatHUD;

class PlayState extends FlxState
{
	// new flags to determine if level is won or lost:
	var ending:Bool;
	var won:Bool;

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

		hud = new HUD();
		add(hud);

		combatHud = new CombatHUD();
		add(combatHud);

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

	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			startCombat(enemy);
		}
	}

	function startCombat(enemy:Enemy)
	{
		inCombat = true;
		player.active = false;

		enemies.active = false;
		combatHud.initCombat(health, enemy);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		/* We don't want to allow anything else to go on if we're
			ending the game and getting ready to switch states: */
		if (ending)
		{
			return;
		}

		if (inCombat)
		{
			// if (!combatHud.visible)
			// {
			// 	health = combatHud.playerHealth;
			// 	hud.updateHUD(health, money);
			// 	if (combatHud.outcome == VICTORY)
			// 	{
			// 		combatHud.enemy.kill();
			// 	}
			// 	else
			// 	{
			// 		combatHud.enemy.flicker();
			// 	}
			// 	inCombat = false;
			// 	player.active = true;
			// 	enemies.active = true;
			// }
			// CHANGE OUR LOGIC FROM THIS ^ TO THIS v to accomodate for loss/win scenarios:

			if (!combatHud.visible)
			{
				health = combatHud.playerHealth; // why does combatHud have it's own health?
				hud.updateHUD(health, money);
				if (combatHud.outcome == DEFEAT)
				{
					ending = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
					// fade to black if defeat
				}
				else
				{
					if (combatHud.outcome == VICTORY)
					{
						combatHud.enemy.kill();
						if (combatHud.enemy.type == BOSS)
						{
							won = true;
							ending = true;
							FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
							// if victory, fade to black again lol
						}
					}
					else
					{
						combatHud.enemy.flicker();
					}
					inCombat = false;
					player.active = true;
					enemies.active = true;
				}
			}
		}
		else
		{
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(player, walls);

			enemies.forEachAlive(checkEnemyVision);

			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}
}
