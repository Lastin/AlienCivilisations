module src.entities.player;

import src.entities.ship;
import src.entities.knowledgeTree;
import src.entities.planet;
import src.handlers.gameManager;

class Player {
	private immutable string _name;
	private State* _state;
	private KnowledgeTree _knowledgeTree;
	private Ship[] _ships;
	private bool _locked = true;

	this(State* state, string name, KnowledgeTree knowledgeTree){
		_state = state;
		_name = name;
		_knowledgeTree = knowledgeTree;
	}
	/** Returns player's knowledge tree **/
	@property KnowledgeTree knowledgeTree(){
		return _knowledgeTree;
	}
	/** Self explanatory **/
	@property string name(){
		return _name;
	}
	/** Returns true if player moves are locked **/
	@property bool locked() const {
		return _locked;
	}

	@property Ship[] availableShips() {
		Ship[] available;
		foreach(Ship s; _ships){
			if(s.complete && !s.used){
				available ~= s;
			}
		}
		return available;
	}

	Player completeTurn(){

		return this;
	}

	Player orderInhabit(Planet planet){
		return this;
	}

	Player orderShip(ShipType type){
		return this;
	}

	Player orderDevelop(Branch branch, int leaf){
		return this;
	}
}