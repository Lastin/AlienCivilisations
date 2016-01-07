module src.states.menu;

import dlangui;
import std.stdio;
import src.states.play;
import src.states.gameFrame;

class Menu : VerticalLayout {
	static GameFrame gameframe;
	this(bool pause, GameFrame gameframe){
		this.gameframe = gameframe;
		auto title = new TextWidget(null, "Alien Civilisations"d);
		title.fontSize = 30;
		title.padding = Rect(30, 30, 30, 30);
		title.margins = Rect(5, 5, 5, 200);
		auto playButton = new Button("playButton", "Start new"d);
		auto contButton = new Button("contButton", "Continue"d);
		auto loadButton = new Button("loadButton", "Load save"d);
		auto saveButton = new Button("saveButton", "Save game"d);
		auto exitButton = new Button("exitButton", "Exit"d);
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
		playButton.click = delegate (Widget src){
			if(gameframe !is null){
				gameframe.setState(new Play());
			} else {
				writeln("Game frame is not initialised");
			}
			return true;
		};
	}

	public void enableButtons(bool b){
		for(int i=0; i<childCount; i++){
			child(i).clickable = b;
		}
	}

}