module src.entities.player;

import src.entities.knowledgeTree;
import src.entities.planet;
import src.handlers.gameManager;

class Player {
	private immutable string _name;
	private KnowledgeTree _knowledgeTree;
	private bool _locked = true;

	this(string name, KnowledgeTree knowledgeTree){
		_name = name;
		_knowledgeTree = knowledgeTree;
	}
	/** Returns player's knowledge tree **/
	@property KnowledgeTree knowledgeTree(){
		return _knowledgeTree;
	}
	/** Player's written name **/
	@property string name(){
		return _name;
	}
	/** Returns true if player moves are locked **/
	@property bool locked() const {
		return _locked;
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

interface Owned {
	@property Player owner();
}