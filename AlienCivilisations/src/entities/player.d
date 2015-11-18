module entities.player;

import std.container.slist;
import entities.planet;
import handlers.gameManager;
import handlers.knowledgeTree;

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
		foreach(Planet planet; planets){
			planet.growPopulation();
		}
		knowledgeTree.develop();
	}
}