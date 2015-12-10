module src.logic.ai;
import src.entities.player;
import src.entities.planet;
import src.entities.map;
import src.handlers.gameManager;
import src.logic.knowledgeTree;
import src.containers.hypotheticalWorld;

class AI : Player{
	this(GameManager gameManager, KnowledgeTree knowledgeTree){
		super(gameManager, "AI", knowledgeTree);
		//HypotheticalWorld hw = new HypotheticalWorld(knowledgeTree, planets, map);
	}
}