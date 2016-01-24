module src.logic.order;

import src.entities.branch;

class Order {
	private bool _completed = false;
	/** Tries to complete the order, returns true if completed **/
	abstract bool execute();
	@property bool completed() {
		return _completed;
	}
}

class KnowledgeOrder : Order {
	private Branch _branch;
	private int _leaf;
	this(Branch branch, int leaf) {
		_branch = branch;
		_leaf = leaf;
	}
	bool execute() {
		return false;
	}
}

