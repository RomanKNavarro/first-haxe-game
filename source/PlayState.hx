package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

using flixel.util.FlxSpriteUtil;

/* NEW MODULE ^^^^ (what's "using"?). Used to make enemy flicker for a little while after being defeated.
	This will allow us to use the APIs in the FlxSpriteUtil class, such as flicker(), which can be used 
	on any FlxObject. For more on how this works, take a look at the Haxe documentation. */
// combatHUD added to state:
var inCombat:Bool = false;
var combatHud:CombatHUD;

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

		// COMBATHUB ADDED:
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

	/* if player touches enemy, switch to combatHUD. We don't initiate if enemy is flickering (that is,
		if enemy is currently defeated) */
	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			startCombat(enemy);
		}
	}

	// func. to run when in combat. Simply set some variables to true
	function startCombat(enemy:Enemy)
	{
		inCombat = true; // set our inCombat "flag"
		player.active = false;
		// so that the enemy (ALL of them) and player sprites don't move around during combat
		enemies.active = false;
		combatHud.initCombat(health, enemy); // where is initCombat? line 177 in CombatHUD.hx
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// we don't want to check for collision when we're in combat (why is this necessary?)
		if (inCombat)
		{
			if (!combatHud.visible)
			{
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				if (combatHud.outcome == VICTORY)
				{
					combatHud.enemy.kill();
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
		else
		{
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(player, walls); // why don't these have a callback? I guess b/c nothing actually happens
			// FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			// check for collision between player and enemies.
			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}
}
