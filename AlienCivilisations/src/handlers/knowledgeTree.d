module handlers.knowledgeTree;
import std.container.dlist;

class KnowledgeTree {
	private string[] classes = ["Food", "Science", "Military", "Energy"];
	private string[][] subClasses = [
		["Agricultural economics", "Agricultural Engineering", "Argonomy", "Animal Science"],
		["Automation", "Biology", "Chemistry", "Mathematics", "Physics"],
		["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
		["Fossil fuels", "Hydro power", "Nuclear", "Solar power", "Wind"]];

	private int[] food = [0,0,0,0,0];
	private int[] science = [0,0,0,0,0];
	private int[] military = [0,0,0,0,0];
	private int[] energy = [0,0,0,0,0];

	private DList!int[] queue;

	this(){

	}

	public int[] getBranch(string branch){
		switch(branch){
			default:
				throw new Exception("unknown branch");
			case "Food":
				return food;
			case "Science":
				return science;
			case "Military":
				return military;
			case "Energy":
				return energy;
		}
	}

	public void develop(int civil_units){
		//l1 = 2
		//l2 = 4
		//l3 = 8
		//l4 = 16
		//l5 = 32
		//steps = (multiplier * 50,000) / civil_units
	}
}