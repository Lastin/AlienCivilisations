module src.entities.player;

import src.entities.planet;
import src.entities.ship;
import src.logic.knowledgeTree;
import src.logic.branch;

class Player {
	private Planet[] planets;
	private Ship[] ships;
	private uint military_units = 0;
	private string name;
	private KnowledgeTree knowledgeTree;

	this(string name, KnowledgeTree knowledgeTree){
		this.knowledgeTree = knowledgeTree;
		this.name = name;
	}

	public KnowledgeTree getKnowledgeTree(){
		return knowledgeTree;
	}
	public Planet[] getPlanets(){
		return planets;
	}
	public void addPlanet(Planet p){
		planets ~= p;
	}
	public string getName(){
		return name;
	}
	public void finishTurn(){
		//int
	}
	public void makeShip(){
		uint sci = knowledgeTree.getBranch("Science").getBranchLevel();
		uint eng = knowledgeTree.getBranch("Energy").getBranchLevel();
		uint mil = knowledgeTree.getBranch("Military").getBranchLevel();
		Ship s = new Ship(this, sci, eng, mil);
		military_units -= s.addUnits(military_units);
		if(!s.empty()){
			ships ~= s;
		}
	}
	public void callUp(uint percent, Planet p){
		if(p.getOwner == this){
			military_units += p.militarise(percent);
		}
	}
}