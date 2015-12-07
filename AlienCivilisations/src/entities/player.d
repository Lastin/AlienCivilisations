module src.entities.player;

import std.container.slist;
import src.entities.planet;
import src.handlers.gameManager;
import src.logic.knowledgeTree;

class Player {
	private SList!Planet planets;
	private string name;
	private GameManager gameManager;
	private KnowledgeTree knowledgeTree;

	this(GameManager gameManager, SList!Planet planets, string name, KnowledgeTree knowledgeTree){
		this.gameManager = gameManager;
		this.knowledgeTree = knowledgeTree;
	}

	private void finishTurn(){

	}

	public KnowledgeTree getKnowledgeTree(){
		return knowledgeTree;
	}

	public void endTurn(){
		//collect total civils, and develop, then grow
		/*int total_civil_units = 0;
		foreach(Planet planet; planets){
			total_civil_units += planet.getPopulation();
			planet.growPopulation();
		}
		knowledgeTree.develop(total_civil_units);*/
	}
}