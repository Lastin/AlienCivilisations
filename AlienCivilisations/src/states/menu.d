module src.states.menu;

import dlangui;
import std.stdio;
import src.states.play;
import src.handlers.gameManager;

class Menu : VerticalLayout {
	this(GameManager gm, bool pause){
		auto title = new TextWidget(null, "Alien Civilisations"d);
		title.fontSize = 30;
		title.padding = Rect(30, 30, 30, 30);
		title.margins = Rect(5, 5, 5, 200);
		auto playButton = new Button(null, "Start new"d);
		auto contButton = new Button(null, "Continue"d);
		auto loadButton = new Button(null, "Load save"d);
		auto saveButton = new Button(null, "Save game"d);
		auto exitButton = new Button(null, "Exit"d);
		playButton.padding = Rect(10, 10, 10, 10);
		contButton.padding = Rect(10, 10, 10, 10);
		loadButton.padding = Rect(10, 10, 10, 10);
		saveButton.padding = Rect(10, 10, 10, 10);
		exitButton.padding = Rect(10, 10, 10, 10);
		margins = Rect(200,20,200,20);
		title.alignment(Align.Right | Align.Center);
		addChild(title);
		addChild(playButton);
		addChild(loadButton);
		if(pause){
			addChild(contButton);
			addChild(saveButton);
		}
		addChild(exitButton);
		exitButton.click = delegate (Widget src){
			window.close();
			return true;
		};
	}
}