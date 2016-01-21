module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.handlers.containers;

class AI : Player{
	private GameState* _realState;
	this(GameState* realState, KnowledgeTree knowledgeTree) {
		super("AI", knowledgeTree);
		_realState = realState;
	}
}