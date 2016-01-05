module src.states.play;

import std.stdio;
import src.states.state;
import src.handlers.gameManager;

class Play : State {
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