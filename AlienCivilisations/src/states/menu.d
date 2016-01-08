module src.states.menu;

import dlangui;
import std.stdio;
import src.states.play;
import src.states.gameState;
import src.gameFrame;

class Menu : VerticalLayout, GameState {
	static GameFrame* gameFrame;
	this(GameFrame* gameFrame){
		//start menu
		this.gameFrame = gameFrame;
		auto title = new TextWidget(null, "Alien Civilisations"d);
		title.fontSize = 30;
		title.padding = Rect(30, 30, 30, 30);
		title.margins = Rect(5, 5, 5, 200);
		auto playButton = new Button("playButton", "Start new"d);
		auto loadButton = new Button("loadButton", "Load save"d);
		auto exitButton = new Button("exitButton", "Exit"d);
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
		playButton.click = delegate (Widget src){
			if(gameFrame !is null){
				gameFrame.setState(new Play(gameFrame));
			} else {
				writeln("Game frame is not initialised");
			}
			return true;
		};
	}

	this(GameFrame* gameFrame, Play play){
		//pause menu
		this(gameFrame);
		auto contButton = new Button("contButton", "Continue"d);
		auto saveButton = new Button("saveButton", "Save game"d);
		contButton.padding = Rect(10, 10, 10, 10);
		saveButton.padding = Rect(10, 10, 10, 10);
		addChild(contButton);
		addChild(saveButton);
	}

	public void enableButtons(bool b){
		for(int i=0; i<childCount; i++){
			child(i).clickable = b;
		}
	}

	public bool handleKeyInput(Widget source, KeyEvent event){
		return false;
	}

}