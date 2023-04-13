// NEW ENEMY CLASS, DIRECTLY PASTED IN WHOLE
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint; // for getting the player's position
import flixel.math.FlxVelocity;

// since we have two different types of enemies:
// what is enum? it's a class
enum EnemyType
{
	REGULAR;
	BOSS;
}

class Enemy extends FlxSprite
{
	// 40 walk speed, 70 chase speed.
	static inline var WALK_SPEED:Float = 40;
	static inline var CHASE_SPEED:Float = 70;

	// FSM AI STUFF:
	var brain:FSM;
	var idleTimer:Float;
	var moveDirection:Float;

	// MAKE THESE TWO public, used in PlayState.hx
	public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	/* what's this? it's a type variable, which we'll use to figure out which 
		enemy sprite to load, deal with, etc. */
	var type:EnemyType;

	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);
		this.type = type;
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		loadGraphic(graphic, true, 16, 16);
		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		animation.add("d_idle", [0]);
		animation.add("lr_idle", [3]);
		animation.add("u_idle", [6]);
		animation.add("d_walk", [0, 1, 0, 2], 6);
		animation.add("lr_walk", [3, 4, 3, 5], 6);
		animation.add("u_walk", [6, 7, 6, 8], 6);
		drag.x = drag.y = 10;
		setSize(8, 8);
		offset.x = 4;
		offset.y = 8;

		// more FSM stuff. "brain" is a FSM object.
		brain = new FSM(idle);
		idleTimer = 0;
		playerPosition = FlxPoint.get(); // get player's position
	}

	/*****************************************************************************/
	// two new func.s.
	// func when remaining idle:
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

	/*****************************************************************************/
	override public function update(elapsed:Float)
	{
		if (velocity.x != 0 || velocity.y != 0)
		{
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
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
		var action = "idle";

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

		brain.update(elapsed); // UPDATE THE BRAIN
		super.update(elapsed);
	}
}
