module src.containers.hypotheticalWorld;

import src.logic.knowledgeTree;
import src.logic.branch;
import src.entities.map;
import src.entities.planet;

class HypotheticalWorld {
	private KnowledgeTree kt;
	private Planet[] pplanets;
	private Map map;
	this(KnowledgeTree kt, Planet[] pplanets, Map map){
		this.kt = kt;
		this.pplanets = pplanets;
		this.map = map;
	}
}

