module src.entities.player;

import src.entities.planet;
import src.entities.ship;
import src.logic.knowledgeTree;
import src.logic.branch;

class Player {
	private Planet[] _planets;
	private Ship[] _ships;
	private string _name;
	private KnowledgeTree _knowledgeTree;

	this(string name, KnowledgeTree knowledgeTree){
		this.knowledgeTree = knowledgeTree;
		this.name = name;
	}

	@property KnowledgeTree knowledgeTree(){
		return _knowledgeTree;
	}

	@property Planet[] planets(){
		return _planets;
	}

	@property string name(){
		return _name;
	}

	void addPlanet(Planet p){
		_planets ~= p;
	}

	void finishTurn(){
		//int
	}
}