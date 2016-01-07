module src.logic.ai;
import src.entities.player;
import src.entities.planet;
import src.entities.map;
import src.logic.knowledgeTree;
import src.containers.hypotheticalWorld;

class AI : Player{
	this(KnowledgeTree knowledgeTree){
		super("AI", knowledgeTree);
		//HypotheticalWorld hw = new HypotheticalWorld(knowledgeTree, planets, map);
	}
}