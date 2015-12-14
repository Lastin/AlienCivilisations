module src.states.state;

import std.stdio;
import std.range;
import std.conv;
import src.handlers.gameManager;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import derelict.glfw3.glfw3;

class State {
	GameManager gm;
	bool consoleEnabled = false;
	uint[] accChars;
	this(GameManager gm){
		this.gm = gm;
	}
	public abstract void keyInteract(int key, int action);
	public abstract void mouseInteract(GLFWwindow* window, int button, int action, int mods);
	public abstract void render();
	public void defaultKeyCallback(int key, int action){
		if(key == GLFW_KEY_GRAVE_ACCENT && action == GLFW_PRESS){
			consoleEnabled = !consoleEnabled;
			writeln("console: ", (consoleEnabled ? "enabled" : "disabled"));
		}
		else if(consoleEnabled && action == GLFW_PRESS){
			if(key == GLFW_KEY_ENTER && accChars.length > 0){
				writeln();
				writeln("you wrote: ", cast(string)accChars);
				accChars.destroy();
			}
			else if(key == GLFW_KEY_BACKSPACE && accChars.length > 0){
				write(repeat('\b', accChars.length));
				accChars = accChars[0 .. $-1];
				write(cast(string)accChars, " \b");
				stdout.flush();
			}
			//else here call custom option for each state
		}
		else {
			keyInteract(key, action);
		}
	}
	public void defaultCharCallback(uint codepoint){
		if(consoleEnabled && codepoint != GLFW_KEY_GRAVE_ACCENT){
			write(to!char(codepoint));
			stdout.flush();
			accChars ~= codepoint;
		}
	}
	public void renderConsole(GLFWwindow* window, int width, int height){
		if(!consoleEnabled)
			return;
		glColor4f(0.0f, 0.5f, 0.2f, 0.5f);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glBegin(GL_QUADS);
		glVertex2f(-1, 1);
		glVertex2f(-1, -0.5);
		glVertex2f(0.5, -0.5);
		glVertex2f(0.5, 1);
		gm.getFontRenderer().render_text2(cast(string)accChars,30,30, 10, 10);
		glEnd();

	}
}

