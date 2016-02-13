module src.containers.gameState;
import src.entities.map;
import src.entities.player;
import src.logic.ai;
import src.entities.ship;
import src.entities.planet;
import src.containers.vector2d;

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
	/** Moves queue position to next available position **/
	void moveQPosition() {
		if(++_queuePosition == _players.length){
			_queuePosition = 0;
		}
	}
	
	GameState dup() {
		GameState duplicateState;
		Player[] playersDup = duplicatePlayers();
		Planet[] planetsDup = duplicatePlanets(playersDup);
		//duplicate map
		Map mapDup = new Map(_map.size, planetsDup);
		duplicateState = new GameState(mapDup, playersDup, _queuePosition);
		return duplicateState;
	}
	
	/** Function used by duplicatePlayers function **/
	private Ship[] duplicateShips(Ship[] originShips) {
		Ship[] duplicates;
		foreach(Ship origin; originShips){
			duplicates ~= origin.dup();
		}
		return duplicates;
	}
	
	private Player[] duplicatePlayers() {
		Player[] duplicates;
		foreach(Player origin; _players) {
			if(AI ai = cast(AI)origin){
				duplicates ~= new AI(origin.uniqueId, &this, origin.knowledgeTree.dup, duplicateShips(origin.ships));
			} else {
				duplicates ~= new Player(origin.uniqueId, origin.name, origin.knowledgeTree.dup, duplicateShips(origin.ships));
			}
		}
		return duplicates;
	}
	
	private Planet[] duplicatePlanets(Player[] playersDup) {
		Planet[] duplicates;
		foreach(Planet origin; _map.planets){
			string name = origin.name;
			int uniqueId = origin.uniqueId;
			Vector2d pos = origin.position;
			float r = origin.radius;
			bool ba = origin.breathableAtmosphere;
			uint[8] pop = origin.population.dup;
			double food = origin.food;
			uint mu = origin.militaryUnits;
			Ship[] so = origin.shipOrders.dup;
			Planet pDup = new Planet(uniqueId, name, pos, r, ba, pop, food, mu, so);
			int originOwnerId = origin.owner ? origin.owner.uniqueId : -1;
			Player newOwner = findOwner(playersDup, originOwnerId);
			pDup.setOwner(newOwner);
			duplicates ~= pDup;
		}
		return duplicates;
	}
	
	private Player findOwner(Player[] playersDups, int ownerId) {
		if(ownerId == -1){
			return null;
		} else {
			foreach(p; playersDups){
				if(p.uniqueId == ownerId)
					return p;
			}
			throw new Exception("Cannot find planet owner");
		}
	}
}