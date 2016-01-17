module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.logic.hypotheticalWorld;

class AI : Player{
	private State* _realState;
	this(State* realState, KnowledgeTree knowledgeTree){
		super("Artificial Player", knowledgeTree);
		_realState = realState;
	}
}