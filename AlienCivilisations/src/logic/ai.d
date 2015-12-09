module src.logic.ai;
import src.entities.player;
import src.entities.planet;
import src.entities.map;
import src.handlers.gameManager;
import src.logic.knowledgeTree;
import src.containers.hypotheticalWorld;

class AI : Player{
	this(GameManager gameManager, Planet[] planets, KnowledgeTree knowledgeTree, Map map){
		super(gameManager, planets, "Artificial Player", knowledgeTree);
		HypotheticalWorld hw = new HypotheticalWorld(knowledgeTree, planets, map);
	}
}