module src.states.state;

import derelict.glfw3.glfw3;

interface State {
	public void interact(GLFWwindow* window, int key, int scancode, int action, int mods);
	public void render() ;
}

