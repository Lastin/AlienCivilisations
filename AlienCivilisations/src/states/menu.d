module src.states.menu;

import dlangui;
import std.stdio;
import src.states.play;
import src.states.gameState;
import src.gameFrame;

class Menu : VerticalLayout, GameState {
	static GameFrame gameFrame;
	this(GameFrame gameFrame, string title="menu", Play play = null){
		super(title);
		this.gameFrame = gameFrame;
		auto heading = new TextWidget(null, "Alien Civilisations"d);
		heading.fontSize = 30;
		heading.padding = Rect(30, 30, 30, 30);
		heading.margins = Rect(5, 5, 5, 200);
		heading.alignment(Align.Right | Align.Center);
		addChild(heading);
		addButtons(play);
	}

	private void addButtons(Play play){
		if(play){
			auto contButton = new Button("contButton", "Continue"d);
			auto saveButton = new Button("saveButton", "Save game"d);
			contButton.padding = Rect(10, 10, 10, 10);
			saveButton.padding = Rect(10, 10, 10, 10);
			addChild(contButton);
			addChild(saveButton);
			contButton.click = delegate (Widget source){
				gameFrame.setState(play);
				return true;
			};
		}
		auto playButton = new Button("playButton", "Start new"d);
		auto loadButton = new Button("loadButton", "Load save"d);
		auto exitButton = new Button("exitButton", "Exit"d);
		playButton.padding = Rect(10, 10, 10, 10);
		loadButton.padding = Rect(10, 10, 10, 10);
		exitButton.padding = Rect(10, 10, 10, 10);
		addChild(playButton);
		addChild(loadButton);
		addChild(exitButton);
		exitButton.click = delegate (Widget source){
			window.close();
			return true;
		};
		playButton.click = delegate (Widget source){
			gameFrame.setState(new Play(gameFrame));
			return true;
		};
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