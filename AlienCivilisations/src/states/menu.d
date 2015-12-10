module src.states.menu;

import std.stdio;
import derelict.glfw3.glfw3;
import src.states.state;
import src.states.play;
import src.handlers.gameManager;

class Menu : State {
	this(GameManager gm){
		super(gm);
	}
	public void render(){

	}
	public void keyInteract(GLFWwindow* window, int key, int scancode, int action, int mods){
		writeln(action);
		if(key == GLFW_KEY_F12){
			writeln("swithing state");
			gm.setState(new Play(gm));
		}
	}
	public void mouseInteract(GLFWwindow* window, int button, int action, int mods){
		writeln("mouse in menu");
	}
}