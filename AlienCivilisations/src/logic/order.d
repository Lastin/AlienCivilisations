module src.logic.orderable;

import src.entities.branch;

interface Orderable {
	bool execute();
}

class KnowledgeOrder : Orderable {
	Branch branch;
	int leaf;
	this(Branch b, int l){
		branch = b;
	}
	bool execute(){
		return false;
	}
}

