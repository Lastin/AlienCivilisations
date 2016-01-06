module src.states.play;

import std.stdio;
import src.states.gameState;
import src.handlers.gameManager;

class Play : GameState {
	this(GameManager gm){
		super(gm);
	}
	public void render(){

	}
	public void keyInteract(int key, int action){
		writeln("key in play");
	}
	public void mouseInteract(int button, int action, int mods){
		writeln("mouse in play");
	}
}