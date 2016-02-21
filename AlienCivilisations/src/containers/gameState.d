module src.containers.gameState;
import src.entities.map;
import src.entities.player;
import src.logic.ai;
import src.entities.ship;
import src.entities.planet;
import src.containers.vector2d;

enum PlayerEnum : ubyte {
	None,
	Human,
	AI,
	Both
}
/** Container for current, or hypothetical game state, holding references to all essential data **/
class GameState {
	private {
		Map _map;
		Player[] _players;
		size_t _queuePosition;
	}
	
	this(Map map, Player[] players, size_t queuePosition) {
		_map = map;
		_players = players;
		_queuePosition = queuePosition;
	}
	@property Map map() {
		return _map;
	}
	@property Player[] players() {
		return _players;
	}
	@property Player currentPlayer() {
		return _players[_queuePosition];
	}
	@property Player human(){
		return _players[0];
	}
	@property AI ai(){
		return cast(AI)_players[1];
	}
	@property size_t queuePosition() const {
		return _queuePosition;
	}
	@property PlayerEnum deadPlayer() {
		bool humanDead = human.dead(_map.planets);
		bool aiDead = ai.dead(_map.planets);
		if(!aiDead && !humanDead)
			return PlayerEnum.None;
		if(!aiDead && humanDead)
			return PlayerEnum.Human;
		if(!humanDead && aiDead)
			return PlayerEnum.AI;
		return PlayerEnum.Both;
	}
	/** Moves queue position to next available position **/
	void moveQPosition() {
		if(++_queuePosition == _players.length){
			_queuePosition = 0;
		}
	}
	
	GameState dup() const {
		GameState duplicateState;
		Player[] playersDup = duplicatePlayers(duplicateState);
		Planet[] planetsDup = _map.duplicatePlanets(playersDup);//duplicatePlanets(playersDup);
		//duplicate map
		Map mapDup = new Map(_map.size, planetsDup);
		duplicateState = new GameState(mapDup, playersDup, _queuePosition);
		return duplicateState;
	}
	
	private Player[] duplicatePlayers(GameState duplicateState) const {
		Player[] duplicates;
		foreach(const Player origin; _players) {
			if(AI ai = cast(AI)origin){
				duplicates ~= new AI(origin.uniqueId, &duplicateState, origin.knowledgeTree.dup, origin.ships);
			} else {
				duplicates ~= new Player(origin.uniqueId, origin.name, origin.knowledgeTree.dup, origin.ships);
			}
		}
		return duplicates;
	}
}