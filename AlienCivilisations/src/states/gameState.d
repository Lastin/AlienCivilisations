module src.states.gameState;

import dlangui;

interface GameState {
	public bool handleKeyInput(Widget source, KeyEvent event);
}

