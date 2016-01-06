module src.states.menu;

import dlangui;
import std.stdio;
import src.states.gameState;
import src.states.play;
import src.handlers.gameManager;

class Menu : GameState {
	this(GameManager gm){
		super(gm);
		auto title = new TextWidget(null, "Alien Civilisations"d);
		title.fontSize = 30;
		title.padding = Rect(30, 30, 30, 30);
		auto playButton = new Button(null, "Start new"d);
		auto loadButton = new Button(null, "Load save"d);
		auto exitButton = new Button(null, "Exit"d);
		playButton.margins = Rect(5, 200, 5, 5);
		playButton.padding = Rect(10, 10, 10, 10);
		loadButton.padding = Rect(10, 10, 10, 10);
		exitButton.padding = Rect(10, 10, 10, 10);
		margins = Rect(200,20,200,20);
		title.alignment(Align.Right | Align.Center);
		addChild(title);
		addChild(playButton);
		addChild(loadButton);
		addChild(exitButton);
		exitButton.click = delegate (Widget src){
			window.close();
			return true;
		};
	}
}