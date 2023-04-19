package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	// "VIRTUALPAD" OBJECT FOR MOBILE
	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	var inCombat:Bool = false;
	var combatHud:CombatHUD;
	var coinSound:FlxSound;

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
		// add virtualPad to state
		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end

		#if FLX_MOUSE
		FlxG.mouse.visible = false; // MAKE MOUSE INVISIBLE DURING PLAY
		#end

		coinSound = FlxG.sound.load("assets/sounds/coin.wav");

		map = new FlxOgmo3Loader("assets/data/turnBasedRPG.ogmo", "assets/data/room-0022.json");

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

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
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
			coinSound.play(true);
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
		// remove the distraction of our virtual pad while combat is happening, as we can't move in combat
		#if mobile
		virtualPad.visible = false;
		#end

		inCombat = true;
		player.active = false;

		enemies.active = false;
		combatHud.initCombat(health, enemy);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ending)
		{
			return;
		}

		if (inCombat)
		{
			function doneFadeOut()
			{
				FlxG.switchState(new GameOverState(won, money));
			}

			if (!combatHud.visible)
			{
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				if (combatHud.outcome == DEFEAT)
				{
					ending = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
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
			// when out of combat, make virtual pad visible
			#if mobile
			virtualPad.visible = true;
			#end

			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(player, walls);

			enemies.forEachAlive(checkEnemyVision);

			FlxG.collide(enemies, walls);

			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}
}
