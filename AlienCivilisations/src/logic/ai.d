module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.logic.hypotheticalWorld;

class AI : Player{
	private HypotheticalWorld _hypoWorld;
	private Player[] _players;
	private Map map;
	this(KnowledgeTree knowledgeTree, Map map, Player[] players){
		super("AI", knowledgeTree, map);
		_hypoWorld = new HypotheticalWorld(map, _players);
	}
}