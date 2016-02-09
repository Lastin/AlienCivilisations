module src.handlers.viewHanlder;
import src.screens.menu;
import src.screens.play;
import dlangui.platforms.common.platform;
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
	~this() {
		_menu.destroy;
		if(_play){
			_play.destroy();
		}
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
	void setPlay() {
		if(_play)
			_window.mainWidget = _play;
	}
}