module src.logic.orderable;

import src.entities.branch;

interface Orderable {
	bool execute();
}

class KnowledgeOrder : Orderable {
	private Branch _branch;
	private int _leaf;
	this(Branch branch, int leaf){
		_branch = branch;
		_leaf = leaf;
	}
	//Returns true if order has been completed
	bool execute(){
		return false;
	}
}

