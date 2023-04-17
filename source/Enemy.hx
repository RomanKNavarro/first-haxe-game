package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint; // for getting the player's position
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;

using flixel.util.FlxSpriteUtil; // to make enemy flicker. Why do we need to import it in so many files?

// since we have two different types of enemies:
// what is enum? it's a class
enum EnemyType
{
	REGULAR;
	BOSS;
}

class Enemy extends FlxSprite
{
	var stepSound:FlxSound; // NEW: for enemy footsteps

	// 40 walk speed, 70 chase speed.
	static inline var WALK_SPEED:Float = 40;
	static inline var CHASE_SPEED:Float = 70;

	// FSM AI STUFF:
	var brain:FSM;
	var idleTimer:Float;
	var moveDirection:Float;

	// public var type:EnemyType; CHANGED FROM THIS < TO THIS v
	public var type(default, null):EnemyType;
	// MAKE THESE TWO public, as they are used in PlayState.hx
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	/* what's this? it's a type variable, which we'll use to figure out which
		enemy sprite to load, deal with, etc. */
	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);
		this.type = type;
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		loadGraphic(graphic, true, 16, 16);
		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		// THESE ANIMATIONS NOT WORKING
		// how does animation.add() work again?
		// we assign each animation (3 frames) a unique name. The ensuing list contains the frames.
		// what's the third arg (6) for the walking anim.s?
		// THIS IS GOOD
		animation.add("d_idle", [0]);
		animation.add("lr_idle", [3]);
		animation.add("u_idle", [6]);
		animation.add("d_walk", [0, 1, 0, 2], 6);
		animation.add("lr_walk", [3, 4, 3, 5], 6);
		animation.add("u_walk", [6, 7, 6, 8], 6);
		// what's this again?
		drag.x = drag.y = 10;
		setSize(8, 8);
		offset.x = 4;
		offset.y = 8;

		// more FSM stuff. "brain" is a FSM object.
		brain = new FSM(idle);
		idleTimer = 0;
		seesPlayer = false; // STRAIGHT OUTA GITHUB
		playerPosition = FlxPoint.get(); // get player's position

		// NEW: add footsteps to constructor. We set volume to 0.4 so they don't sound so annoying:
		// stepSound = FlxG.sound.load(AssetPaths.steps__wav, 0.4);
		stepSound = FlxG.sound.load("assets/sounds/steps.wav", 0.4);
		stepSound.proximity(x, y, FlxG.camera.target, FlxG.width * 0.6);
	}

	override public function update(elapsed:Float)
	{
		/* if enemy is flickering, we dont want it to move. MUST be
			at the top of the func. How does "return" alone stop it? */
		if (this.isFlickering())
			return;

		var action = "idle";
		if (velocity.x != 0 || velocity.y != 0)
		{
			action = "walk"; // <- ADDED THIS TOO
			/* NEW: PLAY SOUND WHEN ENEMY WALKS. Unlike for the player's footsteps, we only want to play
				these sounds at the location where the enemy is actually walking. Neat. */
			stepSound.setPosition(x + frameWidth / 2, y + height);
			stepSound.play();
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
					// WHERE TF IS FACING DEFINED AGAIN?
					facing = LEFT;
				else
					facing = RIGHT;
			}
			else
			{
				if (velocity.y < 0)
					facing = UP;
				else
					facing = DOWN;
			}
		}
		switch (facing)
		{
			case LEFT, RIGHT:
				animation.play("lr_" + action);
			case UP:
				animation.play("u_" + action);
			case DOWN:
				animation.play("d_" + action);
			case _:
		}
		brain.update(elapsed);
		super.update(elapsed);
	}

	/*****************************************************************************/
	// two new func.s.
	// func when remaining idle (not giving chase):
	function idle(elapsed:Float)
	{
		if (seesPlayer)
		{
			brain.activeState = chase; // if sees player, change activeState to chase()
		}
		// what this mean? the code for walking around in idleness
		else if (idleTimer <= 0)
		{
			// 95% of the time: choose a random direction to move in. How long do these intervals last?
			if (FlxG.random.bool(95))
			{
				moveDirection = FlxG.random.int(0, 8) * 45;
				velocity.setPolarDegrees(WALK_SPEED, moveDirection);
			}
			// TODO: the other 5%: just stand around.
			else
			{
				moveDirection = -1;
				velocity.x = velocity.y = 0;
			}
			idleTimer = FlxG.random.int(1, 4);
		}
		// AND this one too
		else
			idleTimer -= elapsed;
	}

	// func for when giving chase.
	function chase(elapsed:Float)
	{
		// continues giving chase to player even if far away. Normal? Yes.
		// continues giving chase 'til player is out of its sight (like turning a wall)
		if (!seesPlayer) // custom seesPlayer var.
		{
			brain.activeState = idle; // if player not see, remain aiming around aimlessly.
		}
		else
		{
			// otherwise, move towards the player's current location
			FlxVelocity.moveTowardsPoint(this, playerPosition, CHASE_SPEED);
		}
	}

	// NEW FUNC FOR use in combat hub: add enemy sprite to combat screen I guess? WTF is "if (this.type != type)"?
	public function changeType(type:EnemyType)
	{
		if (this.type != type)
		{
			this.type = type;
			var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
			loadGraphic(graphic, true, 16, 16);
		}
	}
	/*****************************************************************************/
}
