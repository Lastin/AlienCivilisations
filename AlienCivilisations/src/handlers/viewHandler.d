module src.handlers.viewHanlder;
import src.screens.menu;
import src.screens.play;
import dlangui.platforms.common.platform;
import std.stdio;
import src.handlers.saveHandler;
import std.json;
import src.handlers.gameManager;
import src.handlers.jsonParser;
import src.containers.gameState;
import src.containers.point2d;
import src.screens.tutorial;

class ViewHandler {
	private {
		Window _window;
		Menu _menu;
		Play _play;
	}
	this(Window window) {
		_window = window;
	}
	void destroyResources() {
		if(_play) {
			_play.removeAllChildren();
			_play.animatedBackground.releaseRef();
			_play.animatedBackground.destroy();
			_play = null;
		}
		_menu.removeAllChildren();
		_menu = null;
	}
	void setMainMenu() {
		_menu = new Menu(this);
		_window.mainWidget = _menu;
		/*if(_play) {
			_play.removeAllChildren();
			_play.animatedBackground.releaseRef();
			_play.animatedBackground.destroy();
			_play = null;
		}*/
	}
	void setPauseMenu(Play play) {
		_play = new Play(this, play.gameManager,play.cameraPosition);
		Menu menu = new Menu(this);
		menu.switchMenuView(MenuView.Pause);

		_window.mainWidget = menu;
	}
	void setNewPlay(int width, int height) {
		_play = new Play(this, null, width, height);
		_window.mainWidget = _play;
	}
	void setTutorial() {
		//auto tutSave = SaveHandler.readTutorial();
		string tutJSON = import("tutSave");
		JSONValue jsave = JSONParser.stringToJVAL(tutJSON);
		GameState gs = JSONParser.jsonToState(jsave);
		GameManager gm = new GameManager(gs);
		Point2D camPos = JSONParser.jsonToPoint(jsave["cameraPosition"]);
		Tutorial tut = new Tutorial(this, gm, camPos);
		_play = tut;
		resumePlay();
		tut.updateTutorial();
	}
	void resumePlay() {
		if(_play)
			_window.mainWidget = _play;
	}
	void loadPlay(int slot) {
		if(_play)
			_play.destroy();
		auto saveFile = SaveHandler.readSlot(slot);
		JSONValue jsave = JSONParser.fileToJSON(saveFile);
		GameState gs = JSONParser.jsonToState(jsave);
		GameManager gm = new GameManager(gs);
		Point2D camPos = JSONParser.jsonToPoint(jsave["cameraPosition"]);
		_play = new Play(this, gm, camPos);
		resumePlay();
	}
	@property Play play() {
		return _play;
	}
}