module src.screens.menu;

import dlangui;
import std.stdio;
import src.screens.play;
import core.thread;
import src.handlers.jsonParser;
import std.file;
import std.path;
import std.algorithm;
import std.array;
import src.handlers.viewHanlder;

enum MenuView : ubyte {
	Main,
	Pause
}

class Menu : HorizontalLayout {
	private {
		Widget _btnsContainer;
		Button _newBtn;
		Button _loadBtn;
		Button _contBtn;
		Button _saveBtn;
		Button _menuBtn;
		Button _exitBtn;
	}
	this(ViewHandler vh) {
		backgroundImageId = "background";
		setLayout();
		//Fetch objects from layout
		Widget btnsContainer = childById("vl1").childById("hl1").childById("btnsContainer");
		_newBtn = cast(Button)btnsContainer.childById("newBtn");
		_loadBtn = cast(Button)btnsContainer.childById("loadBtn");
		_contBtn = cast(Button)btnsContainer.childById("contBtn");
		_saveBtn = cast(Button)btnsContainer.childById("saveBtn");
		_menuBtn = cast(Button)btnsContainer.childById("menuBtn");
		_exitBtn = cast(Button)btnsContainer.childById("exitBtn");
		//Set button actions
		_newBtn.click = delegate (Widget source) {
			vh.setNewPlay();
			return true;
		};
		_loadBtn.click = delegate (Widget source) {
			readSlots();
			return true;
		};
		_contBtn.click = delegate (Widget source) {
			vh.setPlay();
			return true;
		};
		_saveBtn.click = delegate (Widget source) {
			_btnsContainer.visibility(Visibility.Gone);
			//TODO: add saving functions
			return true;
		};
		_menuBtn.click = delegate (Widget source) {
			switchMenuView(MenuView.Main);
			return true;
		};
		_exitBtn.click = delegate (Widget source) {
			window.close();
			return true;
		};
		switchMenuView(MenuView.Main);
	}

	void setPlayObject(Play play){

	}
	/** Changes the visibility of buttons based on the desired look of menu **/
	void switchMenuView(MenuView view) {
		if(view == MenuView.Main){
			_newBtn.visibility(Visibility.Visible);
			_loadBtn.visibility(Visibility.Visible);
			_contBtn.visibility(Visibility.Gone);
			_saveBtn.visibility(Visibility.Gone);
			_menuBtn.visibility(Visibility.Gone);
		} else {
			_newBtn.visibility(Visibility.Gone);
			_loadBtn.visibility(Visibility.Gone);
			_contBtn.visibility(Visibility.Visible);
			_saveBtn.visibility(Visibility.Visible);
			_menuBtn.visibility(Visibility.Visible);
		}
	}
	/** Sets the layout of the main widget in window to menu **/
	private void setLayout() {
		layoutWidth(FILL_PARENT);
		layoutHeight(FILL_PARENT);
		addChild(new HSpacer());
		auto layout =
		q{
			VerticalLayout {
				id: vl1
				alignment: center
				layoutHeight: fill
				VSpacer {}
				TextWidget {
					text: "Alien Civilisations"
					textColor: "white"
					fontSize: 400%
					fontWeight: 800
					padding: 40
				}
				VerticalLayout {
					id: "saveWidget"
					backgroundColor: 0x80969696
					margins: 20
				}
				HorizontalLayout {
					id: hl1
					alignment: center
					layoutWidth: fill
					HSpacer {}
					VerticalLayout {
						id: btnsContainer
						Button {
							id: newBtn
							text: "NEW GAME"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: loadBtn
							text: "LOAD SAVE"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: contBtn
							text: "CONTINUE"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: saveBtn
							text: "SAVE"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: menuBtn
							text: "MAIN MENU"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						Button {
							id: exitBtn
							text: "EXIT GAME"
							margins: 10
							fontSize: 150%
							padding: Rect {100, 15, 100, 15}
						}
						margins: 10
					}
					HSpacer {}
				}
				VSpacer {}
			}
		};
		addChild(parseML(layout));
		addChild(new HSpacer());
	}
	/** Reads the save files and shows the widget to save/read files **/
	private void showSaveWidget(){
		Widget sw = childById("vl1").childById("saveWidget");
		ListWidget lw = new ListWidget();
		WidgetListAdapter wla = new WidgetListAdapter();
		lw.adapter = wla;
		sw.visibility(Visibility.Visible);
	}
	/** Reads files from save directory **/
	private File[] readSlots() {
		string saveLocation = expandTilde("~/Documents/ACSaves");
		if(!exists(saveLocation))
			mkdirRecurse(saveLocation);
		auto files = dirEntries(saveLocation, SpanMode.shallow).filter!(f => f.name.endsWith(".save"));
		File[] slots;
		foreach(f; files)
			writeln(f.name);
		return slots;
	}
}