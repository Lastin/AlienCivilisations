module src.main;

import dlangui;
import src.states.menu;
import src.states.play;
import src.states.gameState;
import src.handlers.gameManager;

mixin APP_ENTRY_POINT;

extern (C) int UIAppMain(string[] args){
	Window window = Platform.instance.createWindow("Alien Civilisations", null, WindowFlag.Resizable, 1024, 768);
	/*auto vl = new VerticalLayout();
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
	vl.margins = Rect(200,20,200,20);
	title.alignment(Align.Right | Align.Center);
	vl.addChild(title);
	vl.addChild(playButton);
	vl.addChild(loadButton);
	vl.addChild(exitButton);
	window.mainWidget = vl;
	exitButton.click = delegate (Widget src){
		window.close();
		return true;
	};*/
	GameManager gm = new GameManager();
	window.mainWidget = new Menu(gm);
	window.show();
	return Platform.instance.enterMessageLoop();
}