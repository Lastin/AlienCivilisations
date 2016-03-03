﻿module src.handlers.viewHanlder;
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