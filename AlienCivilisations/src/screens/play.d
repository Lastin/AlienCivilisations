﻿/**
This module implements play screen.
It consists of the Play and AnimatedBackground class.

It uses AppFrame to display animated background and combinations of various layouts for HUD
It hold the reference to view handler, to switch to main menu on ESCAPE button press.

There are two constructors available:
-without camera position in argument, is for new game. Camera position is set to human player's planet position
-with camera position is for existing game state, loaded from game save or loaded back from pause menu

Game manager is used to handle end of turns.
Mouse events and keyboard events are overriden to custom functions.

Selected planet is update in animated background when user clicks with mouse.
Animated background hold the reference to the planet list directly, to get
planet positions and sizes more efficiently when rendering


Author: Maksym Makuch
 **/

module src.screens.play;

import dlangui;
import src.containers.gameState;
import src.containers.point2d;
import src.entities.branch;
import src.entities.knowledgeTree;
import src.entities.planet;
import src.entities.player;
import src.entities.ship;
import src.handlers.gameManager;
import src.handlers.jsonParser;
import src.handlers.viewHanlder;
import src.logic.ai;
import src.screens.menu;
import std.datetime;
import std.format;
import std.math;
import std.stdio;

class Play : AppFrame {
	protected {
		ViewHandler _vh;
		//Vectors used for camera
		bool _rightDown = false;
		Point2D _startPosition;
		Point2D _endPosition;
		Point2D _cameraPosition;
		//Other
		GameManager _gm;
		GameState _gameState;
		Planet _selectedPlanet;
		//Widgets often reused
		AnimatedBackground _animatedBackground;
		DrawableRef _drawableRef;
		Widget _mainContainer;
		Widget _planetInfoContainer;
		Widget _playerStatsContainer;
		Widget _playersPlanetOptions;
		ListWidget _shipOrdersList;
		ListWidget _aiActionsList;
		WidgetListAdapter _solAdapter;
		WidgetListAdapter _ailAdapter;
		PopupWidget _currentPopup;
		bool _end = false;
	}
	/** Constructor for start of the new game **/
	this(ViewHandler vh, GameManager gm = null, int width = 0, int height = 0){
		_vh = vh;
		addChild(getLayout());
		if(!gm) {
			_gm = new GameManager();
			initialiseObjects(true, width, height);
		} else {
			_gm = gm;
			initialiseObjects(false);
		}
		assignButtonsActions();
		updatePlayerStats();
	}
	/** Constructor for loading from save or switching back from menu **/
	this(ViewHandler vh, GameManager gm, Point2D camPos) {
		this(vh, gm);
		_cameraPosition = camPos;
		_endPosition = _cameraPosition.dup;
	}
	/** Updates the AI information displayed in the AI action list widget **/
	private void updateAIInfo() {
		addAIAction(format("AI owns %s miliary ships", _gameState.ai.militaryShips.length));
		addAIAction(format("AI owns %s inhabitation ships", _gameState.ai.inhabitationShips.length));
	}
	/** Initialises objects and fetches elements of GUI to object fields. Additionally checks if AI should make move first **/
	void initialiseObjects(bool initCam = true, int width = 0, int height = 0) {
		_gameState = _gm.state;
		_mainContainer = childById("verticalContainer").childById("horizontalContainer");
		_playerStatsContainer = _mainContainer.childById("vr1").childById("hr1");
		//Planet informations
		_planetInfoContainer = _mainContainer.childById("rvp").childById("hr2").childById("vr2").childById("planetInfoContainer");
		_planetInfoContainer.visibility(Visibility.Invisible);
		_playersPlanetOptions = _planetInfoContainer.childById("ppo");
		_shipOrdersList = cast(ListWidget)_playersPlanetOptions.childById("shipOrdersList");
		_solAdapter = new WidgetListAdapter();
		_shipOrdersList.ownAdapter = _solAdapter;
		//AI actions list
		_aiActionsList = cast(ListWidget)childById("verticalContainer").childById("hr3").childById("aiActionsList");
		_ailAdapter = new WidgetListAdapter();
		_aiActionsList.ownAdapter = _ailAdapter;
		updateAIInfo();
		//set camera positions
		if(initCam) {
			float tempX = 0;
			float tempY = 0;
			Planet[] playerPlanets = _gameState.map.playerPlanets(_gameState.human.uniqueId);
			if(playerPlanets.length > 0) {
				tempX = playerPlanets[0].position.x;
				tempY = playerPlanets[0].position.y;
			}
			_cameraPosition = Point2D(tempX - width / 2, tempY - height / 2);
			_endPosition = _cameraPosition.dup;
			debug {
				writefln("camera initial position: %s %s", tempX, tempY);
			}
		}
		//set background
		_animatedBackground = new AnimatedBackground(&_cameraPosition, _gameState);
		_drawableRef = _animatedBackground;
		//check if AI starts and makes it's turn if true
		if(cast(AI)_gm.state.currentPlayer) {
			debug writeln("Starting player AI");
			_gm.endTurn(this);
		}
	}
	/** Assigns functions to the buttons and mouse/keyboard events **/
	private void assignButtonsActions(){
		Widget endTurnButton = _playerStatsContainer.childById("endTurnButton");
		Widget inhabitButton = _planetInfoContainer.childById("inhabitButton");
		Widget attackButton = _planetInfoContainer.childById("attackButton");
		Widget convertUnitsButton = _planetInfoContainer.childById("convertUnitsButton");
		Widget orderMilShipBtn = _planetInfoContainer.childById("orderMilitaryShip");
		Widget orderInhShipBtn = _planetInfoContainer.childById("orderInhabitShip");
		Widget knowledgeTreeButton = childById("verticalContainer").childById("hr3").childById("vr3").childById("knowledgeTreeButton");
		//Assign button actions, and default handlers
		mouseEvent = &handleMouseEvent;
		keyEvent = delegate (Widget source, KeyEvent event) {
			if(_end)
				return false;
			if(event.action == KeyAction.KeyDown &&
				event.keyCode == KeyCode.ESCAPE) {
				switchPopup(null);
				_vh.setPauseMenu(this);
				return true;
			}
			return false;
		};
		endTurnButton.click = delegate (Widget source) {
			if(_end)
				return false;
			_ailAdapter.clear();
			switchPopup(null);
			_gm.endTurn(this);
			updatePlanetInfo(_selectedPlanet);
			updatePlayerStats();
			if(_ailAdapter.itemCount < 1) {
				addAIAction("No actions takes");
			}
			checkIfEnd();
			return true;
		};
		inhabitButton.click = delegate (Widget source) {
			if(_gameState.human.inhabitationShips.length < 1){
				string title = "Inhabitation ship needed";
				string message = "You need inhabitation ship to inhabit a planet\n" ~ 
					"Order production of inhabitation ship on one of your planets\n" ~
					"Production uses resources otherwise spent on food production!";
				switchPopup(infoPopup(title, message));
			} else {
				_gameState.human.inhabitPlanet(_selectedPlanet);
				updatePlanetInfo(_selectedPlanet);
				updatePlayerStats();
			}
			return true;
		};
		attackButton.click = delegate (Widget source) {
			debug writeln("trigger attack popup");
			switchPopup(attackPlanetPopup());
			return true;
		};
		convertUnitsButton.click = delegate (Widget source) {
			switchPopup(convertUnitsPopup());
			return true;
		};
		orderMilShipBtn.click = delegate (Widget source) {
			if(_selectedPlanet.militaryUnits < 1){
				string title = "Insufficient military units";
				string message =
					"Convert civil units of the selected planet into military units first.\n" ~
					"Military units can then be loaded onto a ship.";
				switchPopup(infoPopup(title, message));
			} else {
				switchPopup(orderMilitaryShipPopup());
			}
			return true;
		};
		orderInhShipBtn.click = delegate (Widget source) {
			_selectedPlanet.addShipOrder(ShipType.Inhabitation);
			updatePlanetInfo(_selectedPlanet);
			string title = "Done!";
			string message = "One inhabitation ship has been order to be produced on planet " ~ _selectedPlanet.name;
			switchPopup(infoPopup(title, message));
			return true;
		};
		_shipOrdersList.itemClick = delegate (Widget source, int itemIndex) {
			debug writeln(itemIndex);
			return true;
		};
		knowledgeTreeButton.click = delegate (Widget source){
			if(_end)
				return false;
			switchPopup(knowledgeTreePopup());
			return true;
		};
	}
	/** Handles mouse movements and clicks **/
	bool handleMouseEvent(Widget source, MouseEvent event) {
		if(_end)
			return false;
		if(event.action == MouseAction.ButtonDown) {
			if(event.button == MouseButton.Left) {
				auto relativeMousePosition = Point2D(
					_cameraPosition.x + event.x,
					_cameraPosition.y + event.y);
				debug writefln("Mouse Pos X: %s Y: %s", relativeMousePosition.x, relativeMousePosition.y);
				Planet clickedOn;
				if(!_currentPopup || !_currentPopup.isPointInside(event.x, event.y)){
					clickedOn = _gameState.map.collides(relativeMousePosition, 1, 0);
					switchPopup(null);
					_selectedPlanet = clickedOn;
					_animatedBackground.setSelectedPlanet(_selectedPlanet);
					updatePlanetInfo(_selectedPlanet);
				}
			}
		}
		if(event.button == MouseButton.Right){
			if(event.action == MouseAction.ButtonUp) {
				_rightDown = false;
				_endPosition.x = _cameraPosition.x;
				_endPosition.y = _cameraPosition.y;
			}
			else if(event.action == MouseAction.ButtonDown) {
				_rightDown = true;
				_startPosition.x = event.x;
				_startPosition.y = event.y;
			}
		}
		else if(_rightDown && event.action == MouseAction.Move) {
			_cameraPosition.x = to!int(_endPosition.x + (_startPosition.x - event.x));
			_cameraPosition.y = to!int(_endPosition.y + (_startPosition.y - event.y));
			//check x boundaries
			if(_cameraPosition.x < 0 - (width / 2)) {
				_cameraPosition.x = 0 - (width / 2);
			}
			else if(_cameraPosition.x > _gameState.map.size + (width / 2)) {
				_cameraPosition.x = to!int(_gameState.map.size) + (width / 2);
			}
			//check y boundaries
			if(_cameraPosition.y < 0 - (height / 2)) {
				_cameraPosition.y = 0 - (height / 2);
			}
			else if(_cameraPosition.y > _gameState.map.size + (height / 2)) {
				_cameraPosition.y = to!int(_gameState.map.size) + (height / 2);
			}
			//writefln("X: %s Y: %s", _cameraPosition.x, _cameraPosition.y);
		}
		else if(event.action == MouseAction.Wheel){
		}
		return true;
	}

	/** 
	 * Widgets and layouts sections
 	**/

	/** Returns knowledge tree window **/
	private Widget knowledgeTreePopup(){
		Widget popup = defaultPopup("Knowledge Tree Development");
		TableLayout tl = new TableLayout();
		tl.colCount(5);
		tl.padding(10);
		tl.addChild(new HSpacer());
		Branch[] branches = _gameState.human.knowledgeTree.branches;
		foreach(Branch each; branches){
			TextWidget bn = new TextWidget(null, to!dstring(each.name));
			bn.fontWeight(FontWeight.Bold);
			bn.padding(5);
			bn.fontSize(15);
			bn.textColor(0xFFFFFF);
			bn.backgroundColor(0x333333);
			tl.addChild(bn);
		}
		TextWidget desc1 = new TextWidget(null, "BRANCH LEVEL"d);
		desc1.fontWeight(FontWeight.Bold);
		desc1.padding(5);
		desc1.fontSize(15);
		desc1.textColor(0xFFFFFF);
		desc1.backgroundColor(0x333333);
		tl.addChild(desc1);
		foreach(Branch each; branches){
			TextWidget lvl = new TextWidget(null, to!dstring(each.level) ~ "/5"d);
			lvl.padding(5);
			lvl.fontSize(14);
			lvl.textColor(0xFFFFFF);
			tl.addChild(lvl);
		}
		TextWidget desc2 = new TextWidget(null, "EFFECTIVENESS"d);
		desc2.fontWeight(FontWeight.Bold);
		desc2.padding(5);
		desc2.fontSize(15);
		desc2.textColor(0xFFFFFF);
		desc2.backgroundColor(0x333333);
		tl.addChild(desc2);
		foreach(Branch each; branches){
			TextWidget eff = new TextWidget(null, to!dstring(each.effectiveness));
			eff.padding(5);
			eff.fontSize(14);
			eff.textColor(0xFFFFFF);
			tl.addChild(eff);
		}
		TextWidget desc3 = new TextWidget(null, "CURRENT POINTS"d);
		desc3.fontWeight(FontWeight.Bold);
		desc3.padding(5);
		desc3.fontSize(15);
		desc3.textColor(0xFFFFFF);
		desc3.backgroundColor(0x333333);
		tl.addChild(desc3);
		foreach(Branch each; branches){
			TextWidget eff = new TextWidget(null, to!dstring(each.points));
			eff.padding(5);
			eff.fontSize(14);
			eff.textColor(0xFFFFFF);
			tl.addChild(eff);
		}
		TextWidget desc4 = new TextWidget(null, "NEXT LVL IN"d);
		desc4.fontWeight(FontWeight.Bold);
		desc4.padding(5);
		desc4.fontSize(15);
		desc4.textColor(0xFFFFFF);
		desc4.backgroundColor(0x333333);
		tl.addChild(desc4);
		foreach(Branch each; branches){
			dstring pointsNeeded = each.full ? "FULL"d : to!dstring(each.nextExp);
			TextWidget eff = new TextWidget(null, to!dstring(pointsNeeded));
			eff.padding(5);
			eff.fontSize(14);
			eff.textColor(0xFFFFFF);
			tl.addChild(eff);
		}
		tl.addChild(new HSpacer());
		//upgrade buttons
		ListWidget lw = new ListWidget();
		WidgetListAdapter wla = new WidgetListAdapter();
		lw.adapter = wla;
		lw.maxHeight = 100;
		Button[] buttons;
		foreach(i, Branch each; branches){
			buttons ~= new Button(to!string(i), "Upgrade"d);
			if(each.full){
				buttons[i].enabled(false);
				buttons[i].text("FULL");
			}
			tl.addChild(buttons[i]);
		}
		auto dgt = delegate (BranchName bn){
			if(_gameState.human.knowledgeTree.addOrder(bn)){
				auto lastOrder = _gameState.human.knowledgeTree.orders[$-1];
				//TODO: add refreshing the list
				auto text = format("Upgrade %s to level %s", lastOrder[0], lastOrder[1]);
				TextWidget element = new TextWidget(null, to!dstring(text));
				element.padding(2);
				element.margins(2);
				element.textColor(0xFFFFFF);
				element.backgroundColor(0x737373);
				wla.add(element);
				if(auto nimsg = popup.childById("queueEmpty")) {
					nimsg.visibility(Visibility.Gone);
				}

			}
			return true;
		};

		// Assign buttons actions, because inside the loop same lambda is assigned to all
		buttons[0].click = delegate (Widget source) => dgt(BranchName.Energy);
		buttons[1].click = delegate (Widget source) => dgt(BranchName.Food);
		buttons[2].click = delegate (Widget source) => dgt(BranchName.Military);
		buttons[3].click = delegate (Widget source) => dgt(BranchName.Science);
		popup.addChild(tl);
		//separator
		popup.addChild(new VSpacer().backgroundColor(0x333333));
		//DEVELOPMENT ORDERS
		TextWidget ot = new TextWidget(null, "Development orders"d);
		ot.fontWeight(FontWeight.Bold);
		ot.padding(5);
		ot.fontSize(15);
		ot.textColor(0xFFFFFF);
		popup.addChild(ot);

		auto orders = _gameState.human.knowledgeTree.orders;
		if(orders.length < 1){
			TextWidget element = new TextWidget("queueEmpty", "Queue is empty"d);
			element.padding(2);
			element.margins(2);
			element.textColor(0xFFFFFF);
			element.backgroundColor(0x737373);
			popup.addChild(element);
		} else {
			foreach(order ; orders){
				auto text = format("Upgrade %s to level %s", order[0], order[1]);
				TextWidget element = new TextWidget(null, to!dstring(text));
				element.padding(2);
				element.margins(2);
				element.textColor(0xFFFFFF);
				element.backgroundColor(0x737373);
				wla.add(element);
			}
		}
		popup.addChild(lw);
		//
		return popup;
	}
	/** Returns widget with options to attack a planet **/
	private Widget attackPlanetPopup(){
		if(_gameState.human.militaryShips.length < 1){
			string msg = 
				"You do not have any military ships that could be used to \n" ~
				"perform the attack. Produce the ships on one of your planets.\n";
			return infoPopup("Insufficient military ships", msg);
		}
		Widget popupWindow = defaultPopup("Execute military attack");
		ListWidget shipsList = new ListWidget;
		WidgetListAdapter wla = new WidgetListAdapter();
		shipsList.adapter = wla;
		bool[] selected;
		foreach(MilitaryShip ship; _gameState.human.militaryShips) {
			HorizontalLayout hl = new HorizontalLayout();
			hl.addChild(new CheckBox("checkBox"));
			hl.addChild(new TextWidget(null, "Military units onboard: " ~ to!dstring(ship.onboard)).textColor(0xFFFFFF));
			hl.backgroundColor(0x737373);
			hl.padding(2);
			hl.margins(2);
			wla.add(hl);
			selected ~= false;
		}
		shipsList.itemClick = delegate (Widget source, int index) {
			selected[index] = !selected[index];
			auto cb = cast(CheckBox)wla.itemWidget(index).childById("checkBox");
			cb.checked = selected[index];
			return true;
		};
		popupWindow.addChild(shipsList);
		//Confirmation button
		Button confirmBtn = new Button(null, "Attack the planet using selected ships."d);
		confirmBtn.click = delegate (Widget source) {
			foreach(i, ship; _gameState.human.militaryShips){
				if(selected[i]){
					_gameState.human.attackPlanet(ship, _selectedPlanet);
				}
			}
			switchPopup(null);
			updatePlanetInfo(_selectedPlanet);
			checkIfEnd();
			return true;
		};
		HorizontalLayout btnContainer = new HorizontalLayout();
		btnContainer.addChild(new HSpacer());
		btnContainer.addChild(confirmBtn);
		popupWindow.addChild(btnContainer);
		return popupWindow;
	}
	/** Display end of game widget and lock actions if either of the players is dead **/
	private void checkIfEnd() {
		PlayerEnum dead = _gameState.deadPlayer();
		if(dead == PlayerEnum.None)
			return;
		_end = true;
		_selectedPlanet = null;
		updatePlanetInfo(_selectedPlanet);
		uint colour = 0x666633; //draw bg
		VerticalLayout vl = new VerticalLayout();
		vl.padding(Rect(50, 20, 50, 20));
		HorizontalLayout titleBar = new HorizontalLayout();
		titleBar.layoutWidth(FILL_PARENT);
		string text = "DRAW";
		if(dead == PlayerEnum.Human) {
			colour = 0x990000;
			text = "DEFEAT";
		}
		else if(dead == PlayerEnum.AI) {
			colour = 0x3399ff;
			text = "VICTORY";
		}
		else {
			text = "VICTORY";
		}
		titleBar.addChild(new HSpacer());
		TextWidget t1 = new TextWidget(null, to!dstring(text));
		t1.fontSize(25);
		titleBar.addChild(t1);
		titleBar.addChild(new HSpacer());
		vl.addChild(titleBar);
		vl.backgroundColor(colour);
		Button rtrn = new Button(null, "Return"d);
		rtrn.click = delegate(Widget action){
			switchPopup(null);
			_vh.setMainMenu();
			return true;
		};
		vl.addChild(new VSpacer());
		vl.addChild(rtrn);
		vl.addChild(new VSpacer());
		switchPopup(vl);
	}
	private void showStats() {
		//Future work: add displaying statistics after ending of the match
	}
	/** Returns widget for putting an order of ship on the planet **/
	private Widget orderMilitaryShipPopup(){
		Widget popupWindow = defaultPopup("Order military ship production");
		//Information table
		TableLayout infoTable = new TableLayout();
		infoTable.colCount(2);
		TextWidget tw1 = new TextWidget(null, "Military units onboard:"d);
		tw1.fontWeight(FontWeight.Bold);
		tw1.fontSize(15);
		tw1.textColor(0xFFFFFF);
		//
		TextWidget total = new TextWidget();
		total.fontSize(15);
		total.textColor(0xFFFFFF);
		//
		infoTable.addChild(tw1);
		infoTable.addChild(total);
		//
		TextWidget maxInfo = new TextWidget();
		maxInfo.fontSize(15);
		maxInfo.textColor(0xFF0000);
		maxInfo.visibility(Visibility.Invisible);
		//
		ScrollBar slider = new ScrollBar(null, Orientation.Horizontal);
		slider.pageSize(1);
		//Set slider properties depending on player properties
		int maxCapacity = Ship.capacity(_gameState.human);
		if(_selectedPlanet.militaryUnits < 100) {
			slider.minValue = 100 / _selectedPlanet.militaryUnits;
		}
		else if(_selectedPlanet.militaryUnits > maxCapacity) {
			double temp = to!double(maxCapacity) / _selectedPlanet.militaryUnits;
			debug writefln("Temp: %s", temp);
			slider.maxValue = to!int(temp * 100.0);
			maxInfo.text = "Units to be added to a new ship limited to the max capacity."d;
			maxInfo.visibility(Visibility.Visible);
		}
		slider.position = slider.minValue;
		auto sliderToUnits = delegate {
			double percent = (slider.position + 1.0) / 100;
			return to!int(_selectedPlanet.militaryUnits * percent);
		};
		total.text(to!dstring(sliderToUnits()));
		//Handler for slider movements
		slider.scrollEvent = delegate(AbstractSlider source, ScrollEvent event) {
			total.text(to!dstring(sliderToUnits()));
			return true;
		};
		//Extra info
		MultilineTextWidget mtw2 = new MultilineTextWidget(null, "Select number of military units from selected planet \nto be added to a new ship"d);
		mtw2.fontSize(15);
		mtw2.textColor(0xFFFFFF);
		MultilineTextWidget mtw3 = new MultilineTextWidget(null, "Constructing the ship uses resources of the planet, \notherwise spent for production of food"d);
		mtw3.fontSize(15);
		mtw3.textColor(0xFFFFFF);
		//Buttons container
		HorizontalLayout buttonContainer = new HorizontalLayout();
		buttonContainer.layoutWidth = FILL_PARENT;
		Button apply = new Button(null, "Apply"d);
		Button cancel = new Button(null, "Cancel"d);
		buttonContainer.addChild(new HSpacer());
		buttonContainer.addChild(apply);
		buttonContainer.addChild(cancel);
		apply.click = delegate(Widget action){
			double percent = (slider.position + 1.0) / 100;
			int result = to!int(_selectedPlanet.militaryUnits * percent);
			_selectedPlanet.addShipOrder(ShipType.Military, result);
			updatePlanetInfo(_selectedPlanet);
			updatePlayerStats();
			switchPopup(null);
			return true;
		};
		cancel.click = delegate(Widget action){
			switchPopup(null);
			return true;
		};
		//Add children to layout
		popupWindow.addChild(infoTable);
		popupWindow.addChild(slider);
		popupWindow.addChild(maxInfo);
		popupWindow.addChild(mtw2);
		popupWindow.addChild(mtw3);
		popupWindow.addChild(buttonContainer);
		return popupWindow;
	}
	/** Returns popup widget for converting units **/
	private Widget convertUnitsPopup(){
		Widget popupWindow = defaultPopup("Convert civil units into military");
		//Conversion info
		TableLayout infoContainer = new TableLayout();
		infoContainer.padding(10);
		infoContainer.colCount(2);
		infoContainer.layoutWidth(FILL_PARENT);
		//Row 1
		TextWidget tw1 = new TextWidget(null, "Convert percent:"d);
		tw1.textFlags(TextFlag.Underline);
		tw1.fontWeight(FontWeight.Bold);
		tw1.fontSize(15);
		tw1.textColor(0xFFFFFF);
		TextWidget perc = new TextWidget(null, "1%"d);
		perc.fontSize(15);
		perc.textColor(0xFFFFFF);
		//Row 2
		TextWidget tw2 = new TextWidget(null, "Military units:"d);
		tw2.textFlags(TextFlag.Underline);
		tw2.fontWeight(FontWeight.Bold);
		tw2.fontSize(15);
		tw2.textColor(0xFFFFFF);
		TextWidget milUnits = new TextWidget(null, to!dstring(_selectedPlanet.percentToNumber(1)));
		milUnits.fontSize(15);
		milUnits.textColor(0xFFFFFF);
		//Row 3
		TextWidget tw3 = new TextWidget(null, "Civil units left on planet:"d);
		tw3.textFlags(TextFlag.Underline);
		tw3.fontWeight(FontWeight.Bold);
		tw3.fontSize(15);
		tw3.textColor(0xFFFFFF);
		TextWidget civLeft = new TextWidget(null, to!dstring(_selectedPlanet.populationSum - _selectedPlanet.percentToNumber(1)));
		civLeft.fontSize(15);
		civLeft.textColor(0xFFFFFF);
		//add to table
		infoContainer.addChild(tw1);
		infoContainer.addChild(perc);
		infoContainer.addChild(tw2);
		infoContainer.addChild(milUnits);
		infoContainer.addChild(tw3);
		infoContainer.addChild(civLeft);
		//Slider and its actions
		ScrollBar slider = new ScrollBar(null, Orientation.Horizontal);
		slider.position(0);
		slider.pageSize(1);
		slider.scrollEvent = delegate(AbstractSlider source, ScrollEvent event){
			perc.text = to!dstring(source.position+1) ~ "%"d;
			auto ptn = _selectedPlanet.percentToNumber(source.position+1);
			milUnits.text = to!dstring(ptn);
			civLeft.text = to!dstring(_selectedPlanet.populationSum - ptn);
			
			return true;
		};
		//Info
		TextWidget extraInfo = new TextWidget(null, "*Only units from 2nd and 3rd age group are converted"d);
		extraInfo.textColor = 0xFFFFFF;
		extraInfo.padding = 7;
		//Buttons and their actions
		HorizontalLayout buttonContainer = new HorizontalLayout();
		buttonContainer.layoutWidth = FILL_PARENT;
		Button apply = new Button(null, "Apply"d);
		Button cancel = new Button(null, "Cancel"d);
		buttonContainer.addChild(new HSpacer());
		buttonContainer.addChild(apply);
		buttonContainer.addChild(cancel);
		//Assign button actions
		apply.click = delegate(Widget action){
			_selectedPlanet.convertUnits(slider.position+1);
			switchPopup(null);
			updatePlayerStats();
			updatePlanetInfo(_selectedPlanet);
			return true;
		};
		cancel.click = delegate(Widget action){
			switchPopup(null);
			return true;
		};
		//Add elements to popup window
		popupWindow.addChild(infoContainer);
		popupWindow.addChild(slider);
		popupWindow.addChild(extraInfo);
		popupWindow.addChild(buttonContainer);
		return popupWindow;
	}
	/** Returns the generic template of popup Widget **/
	private Widget defaultPopup(string title){
		VerticalLayout layout = new VerticalLayout;
		//Title bar
		HorizontalLayout titleBar = new HorizontalLayout();
		titleBar.layoutWidth(FILL_PARENT);
		titleBar.backgroundColor(0x404040);
		TextWidget titleText = new TextWidget(null, to!dstring(title));
		titleText.fontSize(17);
		titleText.textColor(0xFFFFFF);
		titleBar.addChild(titleText);
		//Layout properties
		layout.addChild(titleBar);
		layout.padding(0);
		layout.minWidth(400);
		layout.backgroundColor(0x4B4B4B);
		return layout;
	}
	/** Returns generic popup for displaying informations on the screen **/
	private Widget infoPopup(string title, string message){
		Widget popup = defaultPopup(title);
		MultilineTextWidget msg = new MultilineTextWidget(null, to!dstring(message));
		msg.padding(10);
		msg.fontSize(15);
		msg.textColor(0xFFFFFF);
		HorizontalLayout btnCont = new HorizontalLayout();
		btnCont.layoutWidth(FILL_PARENT);
		Button btn = new Button(null, "OK"d);
		btn.padding(10);
		btn.click = delegate (Widget source) {
			switchPopup(null);
			return true;
		};
		btnCont.addChild(new HSpacer());
		btnCont.addChild(btn);
		popup.addChild(msg);
		popup.addChild(new VSpacer());
		popup.addChild(btnCont);
		return popup;
	}
	/** Parses the string to layout and returns it as a Widget **/
	private Widget getLayout(){
		auto layout =
			q{
			VerticalLayout {
				id: verticalContainer
				layoutHeight: fill
				layoutWidth: fill
				HorizontalLayout {
					id: horizontalContainer
					layoutHeight: fill
					layoutWidth: fill
					VerticalLayout {
						id: vr1
						HorizontalLayout {
							id: hr1
							backgroundColor: 0x80969696
							padding: 5
							Button {
								id: endTurnButton
								text: "END TURN"
								padding: 15
								margins: Rect { 10 10 30 10}
							}
							TextWidget {
								fontWeight: 800
								fontSize: 120%
								textColor: white
								text: "Total population:"
							}
							TextWidget {
								id: totalPopulation
								text: ""
								fontSize: 120%
								textColor: white
								padding: Rect {5 10 30 10}
							}
							TextWidget {
								fontWeight: 800
								fontSize: 120%
								textColor: white
								text: "Total military units:"
							}
							TextWidget {
								id: totalMilitaryUnits
								text: ""
								fontSize: 120%
								textColor: white
								padding: Rect {5 10 30 10}
							}
							TextWidget {
								fontWeight: 800
								fontSize: 120%
								textColor: white
								text: "Inhabitation ships:"
							}
							TextWidget {
								id: inhabitationShipCount
								text: ""
								fontSize: 120%
								textColor: white
								padding: Rect {5 10 30 10}
							}
						}
					}
					HSpacer {}
					VerticalLayout {
						id: rvp
						layoutHeight: fill
						HorizontalLayout {
							id: hr2
							layoutHeight: fill
							VerticalLayout {
								id: vr2
								layoutHeight: fill
								VSpacer {}
								VerticalLayout {
									id: planetInfoContainer
									backgroundColor: 0x80969696
									TextWidget {
										padding: 10
										id: planetName
										text : ""
										fontWeight: 800
										fontSize: 20
										textColor: white
									}
									TableLayout {
										id: planetInfoTable
										padding: 10
										colCount: 2
										TextWidget {
											fontWeight: 800
											textColor: white
											text: "Capacity:"
										}
										TextWidget {
											id: planetCapacity
											textColor: white
											text : "0"
										}
										TextWidget {
											fontWeight: 800
											textColor: white
											text: "Population:"
										}
										TextWidget {
											id: planetPopulation
											textColor: white
											text : "0"
										}
										TextWidget {
											fontWeight: 800
											textColor: white
											text: "Military units:"
											
										}
										TextWidget {
											id: militaryUnits
											textColor: white
											text : "0"
										}
										TextWidget {
											fontWeight: 800
											textColor: white
											text: "Productivity:"
													
										}
										TextWidget {
											id: productivity
											textColor: white
											text : "0"
										}
									}
									Button {
										id: inhabitButton
										text: "Inhabit"
										padding: 10
										margins: 10
									}

									Button {
										id: attackButton
										text: "Attack"
										padding: 10
										margins: 10
									}
									VerticalLayout {
										id: ppo
										Button {
											id: convertUnitsButton
											text: "Convert units"
											padding: 10
											margins: 10
										}
										Button {
											id: orderMilitaryShip
											text: "Order military ship"
											padding: 10
											margins: 10
										}
										Button {
											id: orderInhabitShip
											text: "Order inhabitation ship"
											padding: 10
											margins: 10
										}
										TextWidget {
											id: olt
											fontWeight: 800
											textColor: white
											text: "Ship orders"
										}
										ListWidget {
											id: shipOrdersList
											maxHeight: 200
											padding: 5
										}
									}
								}
								VSpacer {}
							}
						}
					}
				}
				VSpacer{}
				HorizontalLayout {
					layoutWidth: fill
					id: hr3
					VerticalLayout {
						id: vr3
						layoutHeight: fill
						VSpacer{}
						Button {
							id: knowledgeTreeButton
							text: "KNOWLEDGE TREE"
							padding: 20
							margins: 10
						}
					}
					HSpacer {}
					ListWidget {
						backgroundColor: 0x80969696
						id:aiActionsList
						maxHeight: 200
						minHeight: 200
						padding: 5
					}
				}
			}
		};
		return parseML(layout);
	}
	/** Switches popup shown in window, to see only one at a time **/
	protected void switchPopup(Widget popup){
		window.removePopup(_currentPopup);
		if(_currentPopup) {
			_currentPopup.destroy();
		}
		if(!popup){
			_currentPopup = null;
		} else {
			_currentPopup = window.showPopup(popup, this);
		}
	}
	/** Adds item to the AI action list **/
	void addAIAction(string action, uint colour = 0x737373){
		HorizontalLayout sohl = new HorizontalLayout();
		sohl.margins(2);
		sohl.layoutWidth(FILL_PARENT);
		VerticalLayout sovl = new VerticalLayout();
		MultilineTextWidget mltw = new MultilineTextWidget(null, to!dstring(action));
		mltw.minHeight(50);
		mltw.textColor(0xFFFFFF);
		sovl.addChild(mltw);
		sohl.addChild(sovl);
		sohl.addChild(new HSpacer());
		sohl.backgroundColor(colour);
		_ailAdapter.add(sohl);
	}
	/** Updates information in right hand panel about selected planet **/
	void updatePlanetInfo(Planet planet) {
		if(planet) {
			_planetInfoContainer.visibility = Visibility.Visible;
			_planetInfoContainer.childById("planetName").text = to!dstring(planet.name);
			_planetInfoContainer.childById("planetName").textFlags = TextFlag.Underline;
			_planetInfoContainer.childById("planetCapacity").text = to!dstring(planet.capacity);
			_planetInfoContainer.childById("planetPopulation").text = to!dstring(planet.populationSum);
			_planetInfoContainer.childById("militaryUnits").text = to!dstring(planet.militaryUnits);
			if(planet.owner == _gameState.human) {
				_planetInfoContainer.childById("productivity").text = to!dstring(planet.calculateWorkforce);
				_playersPlanetOptions.visibility(Visibility.Visible);
				_planetInfoContainer.childById("inhabitButton").visibility(Visibility.Gone);
				_planetInfoContainer.childById("attackButton").visibility(Visibility.Gone);
				_solAdapter.clear();
				if(planet.shipOrders.length > 0) {
					_playersPlanetOptions.childById("olt").visibility(Visibility.Visible);
					foreach(Ship ship; planet.shipOrders) {
						HorizontalLayout sohl = new HorizontalLayout();
						sohl.padding(2);
						sohl.margins(2);
						sohl.layoutWidth(FILL_PARENT);
						VerticalLayout sovl = new VerticalLayout();
						if(auto ms = cast(MilitaryShip)ship){
							sovl.addChild(new TextWidget(null, "Military ship"d).textColor(0xFFFFFF));
						} else {
							sovl.addChild(new TextWidget(null, "Inhabitation ship"d).textColor(0xFFFFFF));
						}
						sovl.addChild(new TextWidget(null, "Units: " ~ to!dstring(ship.onboard)).textColor(0xFFFFFF));
						sovl.addChild(new TextWidget(null, "Cost: "d ~ to!dstring(ship.buildCost)).textColor(0xFFFFFF));
						int stepsRequired = planet.stepsToCompleteOrder(ship);
						sovl.addChild(new TextWidget(null, "Steps required: "d ~ to!dstring(stepsRequired)).textColor(0xFFFFFF));
						sohl.addChild(sovl);
						sohl.addChild(new HSpacer());
						VerticalLayout br = new VerticalLayout();
						Button cancelBtn = new Button(null, "Cancel"d);
						cancelBtn.click = delegate (Widget source) {
							writeln("clicked order cancelation");
							return true;
						};
						br.addChild(cancelBtn);
						sohl.addChild(br);
						sohl.backgroundColor(0x737373);
						_solAdapter.add(sohl);
					}
				} else {
					_playersPlanetOptions.childById("olt").visibility(Visibility.Gone);
				}

			} else {
				_planetInfoContainer.childById("productivity").text = "unknown"d;
				_playersPlanetOptions.visibility(Visibility.Gone);
				if(planet.owner == _gameState.ai) {
					_planetInfoContainer.childById("attackButton").visibility(Visibility.Visible);
					_planetInfoContainer.childById("inhabitButton").visibility(Visibility.Gone);
				} else {
					_planetInfoContainer.childById("attackButton").visibility(Visibility.Gone);
					_planetInfoContainer.childById("inhabitButton").visibility(Visibility.Visible);
				}
			}
		}
		else {
			_planetInfoContainer.visibility = Visibility.Invisible;
		}

	}
	/** Updates information, about player, in the overhead panel **/
	void updatePlayerStats() {
		uint populationTotal = 0;
		uint militaryUnitTotal = 0;
		int playerId = _gameState.human.uniqueId;
		foreach(Planet p; _gameState.map.playerPlanets(playerId)) {
			populationTotal += p.populationSum;
			militaryUnitTotal += p.militaryUnits;
		}
		_playerStatsContainer.childById("totalPopulation").text = to!dstring(populationTotal);
		_playerStatsContainer.childById("totalMilitaryUnits").text = to!dstring(militaryUnitTotal);
		_playerStatsContainer.childById("inhabitationShipCount").text = to!dstring(_gameState.human.inhabitationShips.length);
	}
	/** Invalidates after drawing, to require another drawing **/
	override void animate(long interval) {
		invalidate();
	}
	/** Returns the drawable background casted to DrawableRef type **/
	@property override DrawableRef backgroundDrawable() const {
		return cast(DrawableRef)_drawableRef;
	}
	/** Returns animated background **/
	@property AnimatedBackground animatedBackground() {
		return _animatedBackground;
	}
	/** Returns the camera position **/
	@property Point2D cameraPosition() {
		return _cameraPosition;
	}
	/** Returns the real game state **/
	@property GameState gameState() {
		return _gameState;
	}
	/** Returns the game manager **/
	@property GameManager gameManager() {
		return _gm;
	}
}


/** This class is used to render the background in the play screen. **/
class AnimatedBackground : Drawable {

	private DrawableRef[] _background;
	private Point2D* _cameraPosition;
	private Planet[] _planets;
	private Planet _selected;
	private GameState _state;

	this(Point2D* cameraPosition, GameState state) {
		_cameraPosition = cameraPosition;
		_state = state;
		_planets = _state.map.planets;
		_background ~= drawableCache.get("noise1.tiled");
		_background ~= drawableCache.get("noise2.tiled");
		_background ~= drawableCache.get("noise3.tiled");
	}
	/** Sets selected planet to given argument **/
	void setSelectedPlanet(Planet selected){
		_selected = selected;
	}
	/** Use Drawing buffer to draw the objects on the screen **/
	override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
		SysTime frameStart = Clock.currTime();
		Rect noisePos;
		int startX, startY;
		for(int i=0, offset=7; i<3; i++, offset -= 2) {
			startX = to!int(0-_cameraPosition.x/offset);
			startY = to!int(0-_cameraPosition.y/offset);
			noisePos = Rect(startX, startY, rc.right, rc.bottom);
			_background[i].drawTo(buf, noisePos, state, tilex0, tiley0);
		}
		DrawBufRef image = drawableCache.getImage("earth");
		foreach(Planet planet; _planets) {
			//If a planet is selected, draw lines
			if(_selected && _selected != planet) {
				int relX = to!int(_selected.position.x - _cameraPosition.x);
				int relY = to!int(_selected.position.y - _cameraPosition.y);
				int x = to!int(planet.position.x - _cameraPosition.x);
				int y = to!int(planet.position.y - _cameraPosition.y);
				//Set colour of the line
				uint colour = 0x0033cc;
				if(planet.owner){
					if(planet.owner == _state.human)
						colour = 0x006600;
					else
						colour = 0xe60000;
				}
				buf.drawLine(Point(x-1,y), Point(relX-1, relY), colour);
				buf.drawLine(Point(x,y-1), Point(relX, relY-1), colour);
				buf.drawLine(Point(x,y), Point(relX, relY), colour);
			}
		}
		foreach(Planet planet; _planets) {
			int radius = to!int(planet.radius);
			int x = to!int(planet.position.x - _cameraPosition.x);
			int y = to!int(planet.position.y - _cameraPosition.y);
			buf.drawRescaled(Rect(x-radius, y-radius, x+radius, y+radius), image, Rect(0,0,image.width,image.height));
		}
	}
	@property override int width() {
		return 1;
	}
	@property override int height() {
		return 1;
	}
}