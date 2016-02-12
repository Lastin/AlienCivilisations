module src.handlers.viewHanlder;
import src.screens.menu;
import src.screens.play;
import dlangui.platforms.common.platform;
import std.stdio;
import src.handlers.saveHandler;
import std.json;
import src.handlers.containers;
import src.handlers.gameManager;
import src.handlers.jsonParser;

class ViewHandler {
	private {
		Window _window;
		Menu _menu;
		Play _play;
	}
	this(Window window) {
		_window = window;
	}
	~this() {
		if(_play){
			//_play.destroy();
		}
		_menu.destroy;
	}
	void setMainMenu() {
		_menu = new Menu(this);
		_window.mainWidget = _menu;
	}
	void setPauseMenu(Play play) {
		_play = play;
		_menu.switchMenuView(MenuView.Pause);
		_window.mainWidget = _menu;
	}
	void setNewPlay() {
		_play = new Play(this);
		_window.mainWidget = _play;
	}
	void resumePlay() {
		if(_play)
			_window.mainWidget = _play;
	}
	void loadPlay(int slot) {
		if(_play)
			_play.destroy();
		auto saveFile = SaveHandler.readSlot(slot);
		JSONValue jsave = JsonParser.parseFile(saveFile);
		GameState gs = JsonParser.jsonToState(jsave);
		GameManager gm = new GameManager(gs);
		Vector2d camPos = JsonParser.jsonToVec(jsave["cameraPosition"]);
		_play = new Play(this, gm, camPos);
		resumePlay();
	}
	@property Play play() {
		return _play;
	}
}