module src.entities.player;

import src.entities.planet;
import src.handlers.gameManager;
import src.logic.knowledgeTree;

class Player {
	private Planet[] planets;
	private string name;
	private GameManager gameManager;
	private KnowledgeTree knowledgeTree;
	private bool locked = true;

	this(GameManager gameManager, Planet[] planets, string name, KnowledgeTree knowledgeTree){
		this.gameManager = gameManager;
		this.knowledgeTree = knowledgeTree;
	}

	public KnowledgeTree getKnowledgeTree(){
		return knowledgeTree;
	}
	public Planet[] getPlanets(){
		return planets;
	}
	public string getName(){
		return name;
	}
}