module src.logic.ai;
import src.entities.player;
import std.container.dlist;
import src.entities.planet;
import src.handlers.gameManager;
import src.logic.knowledgeTree;

class AI : Player{
	this(GameManager gameManager, DList!Planet planets, KnowledgeTree knowledgeTree){
		super(gameManager, planets, "Artificial Player", knowledgeTree);
	}

	private float skillEvaluation(){

	}
	private float populationEvaluation(){

	}
	private float militaryEvaluation(){

	}
}