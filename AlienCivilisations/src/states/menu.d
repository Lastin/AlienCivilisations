module src.states.menu;

import std.stdio;
import derelict.glfw3.glfw3;
import derelict.opengl3.gl;
import src.states.state;
import src.states.play;
import src.handlers.gameManager;

class Menu : State {
	this(GameManager gm){
		super(gm);
	}
	public void render(){

	}
	public void keyInteract(int key, int action){

	}
	public void mouseInteract(GLFWwindow* window, int button, int action, int mods){
		writeln("mouse in menu");
	}
}