module src.containers.gameState;
import src.entities.map;
import src.entities.player;
import src.logic.ai;
import src.entities.ship;
import src.entities.planet;
import src.containers.point2d;
import std.stdio;

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
	/** Returns all players objects **/
	@property Player[] players() {
		return _players;
	}
	/** Returns current player object **/
	@property Player currentPlayer() {
		return _players[_queuePosition];
	}
	@property Player notCurrentPlayer() {
		return _players[_queuePosition+1 % _players.length];
	}
	@property int currentPlayerId() {
		return currentPlayer.uniqueId;
	}
	@property int currentPlayerEnum() {
		if(cast(AI)currentPlayer)
			return PlayerEnum.AI;
		return PlayerEnum.Human;
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
		if(humanDead && !aiDead)
			return PlayerEnum.Human;
		if(aiDead && !humanDead)
			return PlayerEnum.AI;
		return PlayerEnum.Both;
	}
	/** Moves queue position to next available position **/
	void moveQPosition() {
		_queuePosition = ++_queuePosition % _players.length;
		debug writefln("Queue position: %s", _queuePosition);
	}
	/** Returns duplicate of the state **/
	GameState dup() const {
		Player[] playersDup = duplicatePlayers();
		Planet[] planetsDup = _map.duplicatePlanets(playersDup);//duplicatePlanets(playersDup);
		//duplicate map
		Map mapDup = new Map(_map.size, planetsDup);
		return new GameState(mapDup, playersDup, _queuePosition);
	}
	
	private Player[] duplicatePlayers() const {
		Player[] duplicates;
		foreach(const Player origin; _players) {
			if(AI ai = cast(AI)origin){
				duplicates ~= new AI(origin.uniqueId, origin.knowledgeTree.dup, origin.ships);
			} else {
				duplicates ~= new Player(origin.uniqueId, origin.name, origin.knowledgeTree.dup, origin.ships);
			}
		}
		debug writefln("Duplicated %d players", duplicates.length);
		return duplicates;
	}
}