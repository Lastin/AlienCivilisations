module handlers.knowledgeTree;

class KnowledgeTree {
	private string[] classes = ["Food", "Science", "Military", "Energy"];
	private string[][] subClasses = [
		["Agricultural economics", "Agricultural Engineering", "Argonomy", "Animal Science"],
		["Automation", "Biology", "Chemistry", "Mathematics", "Physics"],
		["Defence", "Offence", "Enervating", "Spying", "Intimidation"],
		["Fossil fuels", "Hydro power", "Nuclear", "Solar power", "Wind"]];

	private int[][] levels;

	this(){
		levels = [[1,1,1,1,1],[1,1,1,1,1],[1,1,1,1,1],[1,1,1,1,1]];
	}

}