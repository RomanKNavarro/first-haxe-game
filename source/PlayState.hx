package;

import flixel.FlxG; // import this for collision
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader; // NEW MODULE FOR HAXELIB ADDONS
import flixel.text.FlxText;
import flixel.tile.FlxTilemap; // NEW MODULE FOR OUR MAP

class PlayState extends FlxState
{
	var player:Player;

	// load up our ogmo map as a "FlxOgmo3Loader" object. Map and walls vars created.
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	override public function create()
	{
		// load up our room001.json file into our FlxOgmo3Loader object
		map = new FlxOgmo3Loader("assets/data/turnBasedRPG.ogmo", "assets/data/room-0011.json");
		// map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_003__json);

		// set our walls as our tiles.png file. GENERATE FlxTilemap from the 'walls' layer
		// this creates our tilemap itself
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE); // dont collide on tile 1 (our floor tile)
		walls.setTileProperties(2, ANY); // collide on tile 2 (our wall tile)
		add(walls); // add the tilemap to the state.

		// PLAYER PLACEMENT
		player = new Player();
		// ***********BUG HERE********** (placing inside the walls: no movement. Outside: perfect movement):
		map.loadEntities(placeEntities, "entities"); // place our player in the correct location
		/* We're simply telling our map object to loop through all of the entities in our 'entities'
			layer, and call our placeEntities() func for each one (which we're about to make now). */

		add(player);
		super.create();
	}

	// when we call loadEntities(), on our map, we call this func. on all of the entities.
	// what do "entities" include again? just the player for now
	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player")
			// if this func. is passed the player, set it's x & y to the entity's x & y values
		{
			player.setPosition(entity.x, entity.y);
			// place player in correct position, which we determined in the ogmo project itself.
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		/* check for collision. Since this is in update(), we check after every iteration if there is a 
			overlap between the player and the walls. */
		FlxG.collide(player, walls);
	}
}
