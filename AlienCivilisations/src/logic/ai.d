module src.logic.ai;

import src.entities.knowledgeTree;
import src.entities.map;
import src.entities.planet;
import src.entities.player;
import src.logic.hypotheticalWorld;

class AI : Player{
	this(State* state, KnowledgeTree knowledgeTree){
		super(state, "Artificial Player", knowledgeTree);
	}
}