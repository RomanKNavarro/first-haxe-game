/* the FSM works by saying that a given machine (or entity) can only be in one state at a time. 
	For our enemies, we're going to give them 2 possible states: Idle and Chase. When they can't 'see' 
	the player, they will be Idle - wandering around aimlessly. Once the player is in view, however, they 
	will switch to the Chase state and run towards the player. */
class FSM
{
	public var activeState:Float->Void;

	public function new(initialState:Float->Void)
	{
		activeState = initialState;
	}

	public function update(elapsed:Float)
	{
		activeState(elapsed);
	}
}
