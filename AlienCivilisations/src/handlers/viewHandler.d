/**
This module implements custom view handler.
It handles the switching between different views on the screen and
destroys the object where necessary.

Author: Maksym Makuch
 **/

module src.handlers.viewHanlder;

import dlangui.platforms.common.platform;
import src.containers.gameState;
import src.containers.point2d;
import src.handlers.gameManager;
import src.handlers.jsonParser;
import src.handlers.saveHandler;
import src.screens.menu;
import src.screens.play;
import src.screens.tutorial;
import std.json;
import std.stdio;

class ViewHandler {
	private {
		Window _window;
		Menu _menu;
		Play _play;
	}
	this(Window window) {
		_window = window;
	}
	/** Class destoys the play object (if exists) and it's contents. Depricated, as library handles it since last update. **/
	deprecated void destroyResources() {
		if(_play) {
			_play.removeAllChildren();
			_play.animatedBackground.releaseRef();
			_play.animatedBackground.destroy();
			_play = null;
		}
		_menu.removeAllChildren();
		_menu = null;
	}
	/** Sets the displayed screen to the main menu **/
	void setMainMenu() {
		_menu = new Menu(this);
		_window.mainWidget = _menu;
	}
	/** Sets the displayed screen to the pause menu **/
	void setPauseMenu(Play play) {
		_play = new Play(this, play.gameManager,play.cameraPosition);
		Menu menu = new Menu(this);
		menu.switchMenuView(MenuView.Pause);

		_window.mainWidget = menu;
	}
	/** Initialises new Play object and sets the displayed screen to new play **/
	void setNewPlay(int width, int height) {
		_play = new Play(this, null, width, height);
		_window.mainWidget = _play;
	}
	/** Parses the tutorial save file to Play class and sets the displayed screen to tutorial screen. **/
	void setTutorial() {
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
	/** If play exists, sets screen display to it **/
	void resumePlay() {
		if(_play)
			_window.mainWidget = _play;
	}
	/** Initialises play from the save file, and displays it on the screen **/
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
	/** Returns the Play object, or null if not initialised **/
	@property Play play() {
		return _play;
	}
}