module src.logic.ai;
import src.entities.player;
import src.entities.planet;
import src.handlers.gameManager;
import src.logic.knowledgeTree;

class AI : Player{
	this(GameManager gameManager, Planet[] planets, KnowledgeTree knowledgeTree){
		super(gameManager, planets, "Artificial Player", knowledgeTree);
	}
}