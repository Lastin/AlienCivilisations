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
import std.format;
import std.json;
import src.handlers.saveHandler;

enum MenuView : ubyte {
	Main,
	Pause,
	Save
}

class Menu : HorizontalLayout {
	private {
		ViewHandler _vh;
		Widget _btnsContainer;
		Widget _saveWidget;
		Button _newBtn;
		Button _loadBtn;
		Button _contBtn;
		Button _saveBtn;
		Button _menuBtn;
		Button _exitBtn;
		int _previousSelected = -1;
		bool _saving = false;
	}
	this(ViewHandler vh) {
		_vh = vh;
		backgroundImageId = "background";
		setLayout();
		//Fetch objects from layout
		_btnsContainer = childById("vl1").childById("hl1").childById("btnsContainer");
		_saveWidget = childById("vl1").childById("saveWidget");
		_saveWidget.visibility(Visibility.Gone);
		_newBtn = cast(Button)_btnsContainer.childById("newBtn");
		_loadBtn = cast(Button)_btnsContainer.childById("loadBtn");
		_contBtn = cast(Button)_btnsContainer.childById("contBtn");
		_saveBtn = cast(Button)_btnsContainer.childById("saveBtn");
		_menuBtn = cast(Button)_btnsContainer.childById("menuBtn");
		_exitBtn = cast(Button)_btnsContainer.childById("exitBtn");
		//Set button actions
		_newBtn.click = delegate (Widget source) {
			vh.setNewPlay();
			return true;
		};
		_loadBtn.click = delegate (Widget source) {
			//showSaveWidget();
			_saving = false;
			switchMenuView(MenuView.Save);
			return true;
		};
		_contBtn.click = delegate (Widget source) {
			vh.resumePlay();
			return true;
		};
		_saveBtn.click = delegate (Widget source) {
			//showSaveWidget(true);
			_saving = true;
			switchMenuView(MenuView.Save);
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
		initSaveMenu();
		switchMenuView(MenuView.Main);
	}
	/** Changes the visibility of buttons based on the desired look of menu **/
	void switchMenuView(MenuView view) {
		if(view == MenuView.Main){
			_newBtn.visibility(Visibility.Visible);
			_loadBtn.visibility(Visibility.Visible);
			_contBtn.visibility(Visibility.Gone);
			_saveBtn.visibility(Visibility.Gone);
			_menuBtn.visibility(Visibility.Gone);
			_saveWidget.visibility(Visibility.Gone);
			_btnsContainer.visibility(Visibility.Visible);
		} else if(view == MenuView.Pause) {
			_newBtn.visibility(Visibility.Gone);
			_loadBtn.visibility(Visibility.Gone);
			_contBtn.visibility(Visibility.Visible);
			_saveBtn.visibility(Visibility.Visible);
			_menuBtn.visibility(Visibility.Visible);
			_saveWidget.visibility(Visibility.Gone);
			_btnsContainer.visibility(Visibility.Visible);
		} else {
			_saveWidget.visibility(Visibility.Visible);
			_btnsContainer.visibility(Visibility.Gone);
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
					ListWidget {
						id: "slotsList"
					}
					HorizontalLayout {
						layoutWidth: fill
						Button {
							id: loadSlot
							text: "Load save"
						}
						HSpacer {}
						Button {
							id: deleteSlot
							text: "Delete save"
						}
						HSpacer {}
						Button {
							id: saveToSlot
							text: "Write to slot"
						}
						Button {
							id: cancelBtn
							text: "Cancel"
						}
					}
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
	private void initSaveMenu() {
		//Fetch buttons from layout
		Button loadSlot = cast(Button)_saveWidget.childById("loadSlot");
		Button deleteSlot = cast(Button)_saveWidget.childById("deleteSlot");
		Button saveToSlot = cast(Button)_saveWidget.childById("saveToSlot");
		Button cancelBtn = cast(Button)_saveWidget.childById("cancelBtn");
		//Hide and show proper content
		loadSlot.visibility(Visibility.Invisible);
		deleteSlot.visibility(Visibility.Invisible);
		saveToSlot.visibility(Visibility.Invisible);
		//_btnsContainer.visibility(Visibility.Gone);
		//Initialise adapter and add elements
		ListWidget lw = cast(ListWidget)_saveWidget.childById("slotsList");
		WidgetListAdapter wla = new WidgetListAdapter();
		lw.adapter = wla;
		bool[15] usedSlots = SaveHandler.usedSlots();
		foreach(int i, used; usedSlots) {
			HorizontalLayout listElement = new HorizontalLayout();
			listElement.backgroundColor(0x737373);
			listElement.layoutWidth(FILL_PARENT);
			listElement.padding(2);
			listElement.margins(2);
			auto whom = new TextWidget("whom", ""d).textColor(0xFFFFFF).fontSize(14);
			listElement.addChild(whom);
			listElement.addChild(new HSpacer());
			auto date = new TextWidget("date", ""d).textColor(0xFFFFFF).fontSize(14);
			listElement.addChild(date);
			if(used) {
				try {
					File file = SaveHandler.readSlot(i);
					JSONValue json = JSONParser.fileToJSON(file);
					dstring saveDate = to!dstring(json["date"].str);
					string p1 = json["gameState"]["players"][0]["name"].str;
					string p2 = json["gameState"]["players"][1]["name"].str;
					dstring players = to!dstring(p1 ~ " VS. " ~ p2);
					whom.text(players);
					date.text(saveDate);
				} catch(JSONException exception) {
					debug writeln(exception.toString);
					date.text("Read error"d);
				}
			} else {
				whom.text(to!dstring(format("Slot %s", i)));
				date.text("Empty"d);
			}
			wla.add(listElement);
		}
		//Set actions on selection change
		lw.itemSelected  = delegate (Widget source, int itemIndex) {
			if(_saving){
				saveToSlot.visibility(Visibility.Visible);
			}
			if(_previousSelected > -1){
				lw.itemWidget(_previousSelected).backgroundColor(0x737373);
			}
			wla.itemWidget(itemIndex).backgroundColor(0x999999);
			if(usedSlots[itemIndex]) {
				loadSlot.visibility(Visibility.Visible);
				deleteSlot.visibility(Visibility.Visible);
			} else {
				loadSlot.visibility(Visibility.Invisible);
				deleteSlot.visibility(Visibility.Invisible);
			}
			_previousSelected = itemIndex;
			return true;
		};
		//Set buttons actions
		cancelBtn.click = delegate (Widget source) {
			_saveWidget.visibility(Visibility.Gone);
			_btnsContainer.visibility(Visibility.Visible);
			return true;
		};
		saveToSlot.click = delegate (Widget source) {
			if(_vh.play) {
				int slot = lw.selectedItemIndex;
				JSONValue json = JSONParser.playToJSON(_vh.play);
				SaveHandler.saveJSON(slot, json);
				usedSlots[slot] = true;
				string p1 = json["gameState"]["players"][0]["name"].str;
				string p2 = json["gameState"]["players"][1]["name"].str;
				dstring players = to!dstring(p1 ~ " VS. " ~ p2);
				dstring saveDate = to!dstring(json["date"].str);
				wla.itemWidget(slot).childById("whom").text(players);
				wla.itemWidget(slot).childById("date").text(saveDate);
				loadSlot.visibility(Visibility.Visible);
				deleteSlot.visibility(Visibility.Visible);
			}
			return true;
		};
		loadSlot.click = delegate (Widget source) {
			int slot = lw.selectedItemIndex;
			_vh.loadPlay(slot);
			_saveWidget.visibility(Visibility.Gone);
			_btnsContainer.visibility(Visibility.Visible);
			return true;
		};
		deleteSlot.click = delegate (Widget source) {
			int slot = lw.selectedItemIndex;
			SaveHandler.deleteSave(slot);
			wla.itemWidget(slot).childById("whom").text(to!dstring(format("Slot %s", slot)));
			wla.itemWidget(slot).childById("date").text("Empty"d);
			deleteSlot.visibility(Visibility.Invisible);
			loadSlot.visibility(Visibility.Invisible);
			usedSlots[slot] = false;
			return true;
		};
		_saveWidget.visibility(Visibility.Visible);
	}
}