module src.screens.tutorial;

import src.screens.play;
import src.handlers.viewHanlder;
import src.handlers.gameManager;
import src.containers.point2d;
import dlangui;
import std.stdio;
import src.entities.planet;

class Tutorial : Play {
	private int _stage = -1;
	private PopupWidget _currentPopup;
	private Window _window;
	private ViewHandler _vh;
	private {
		bool _movementEnabled = false;
		bool _selectionEnabled = false;
		bool _deselectionEnabled = false;
		Widget _endTurnButton;
		Widget _inhabitButton;
		Widget _attackButton;
		Widget _convertUnitsButton;
		Widget _orderMilShipBtn;
		Widget _orderInhShipBtn;
		Widget _knowledgeTreeButton;
	}

	this(ViewHandler vh, GameManager gm, Point2D camPos, Window window) {
		super(vh, gm, camPos);
		_window = window;
		_vh = vh;
		init();
		updateTutorial();
	}
	private void init() {
		keyEvent = delegate (Widget source, KeyEvent event) {
			return false;
		};
		_endTurnButton = _playerStatsContainer.childById("endTurnButton");
		_inhabitButton = _planetInfoContainer.childById("inhabitButton");
		_attackButton = _planetInfoContainer.childById("attackButton");
		_convertUnitsButton = _planetInfoContainer.childById("convertUnitsButton");
		_orderMilShipBtn = _planetInfoContainer.childById("orderMilitaryShip");
		_orderInhShipBtn = _planetInfoContainer.childById("orderInhabitShip");
		_knowledgeTreeButton = childById("verticalContainer").childById("hr3").childById("vr3").childById("knowledgeTreeButton");
		_endTurnButton.enabled(false);
		_inhabitButton.enabled(false);
		_attackButton.enabled(false);
		_convertUnitsButton.enabled(false);
		_orderMilShipBtn.enabled(false);
		_orderInhShipBtn.enabled(false);
		_knowledgeTreeButton.enabled(false);
	}
	private Widget tutWid(string text, int size) {
		HorizontalLayout hl = new HorizontalLayout();
		hl.minWidth(600);
		hl.maxWidth(600);
		MultilineTextWidget mltw = new MultilineTextWidget(null, to!dstring(text));
		mltw.fontSize(size);
		mltw.textColor(0xffffff);
		hl.addChild(mltw);
		hl.padding(30);
		hl.minHeight(300);
		VerticalLayout vl = new VerticalLayout();
		vl.addChild(new VSpacer());
		vl.addChild(hl);
		vl.addChild(new VSpacer());
		HorizontalLayout hl2 = new HorizontalLayout();
		hl2.layoutWidth(FILL_PARENT);
		Button btn1 = new Button(null, "Exit Tutorial"d);
		btn1.click = delegate(Widget source) {
			_window.removePopup(_currentPopup);
			_currentPopup.destroy();
			switchPopup(null);
			_vh.setMainMenu();
			return true;
		};
		Button btn2 = new Button(null, "Continue"d);
		btn2.click = delegate(Widget source) {
			updateTutorial();
			return true;
		};
		hl2.addChild(btn1);
		hl2.addChild(new HSpacer());
		hl2.addChild(btn2);
		vl.addChild(hl2);
		vl.backgroundColor(0x404040);
		return vl;
	}
	override bool handleMouseEvent(Widget source, MouseEvent event) {
		if(_end)
			return false;
		if(_movementEnabled) {
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
			}
		}
		if(_selectionEnabled) {
			if(event.action == MouseAction.ButtonDown) {
				if(event.button == MouseButton.Left) {
					auto relativeMousePosition = Point2D(
						_cameraPosition.x + event.x,
						_cameraPosition.y + event.y);
					debug writefln("Mouse Pos X: %s Y: %s", relativeMousePosition.x, relativeMousePosition.y);
					Planet clickedOn;
					if(!_currentPopup || !_currentPopup.isPointInside(event.x, event.y)){
						clickedOn = _gameState.map.collides(relativeMousePosition, 1, 0);
						if(_deselectionEnabled) {
							switchPopup(null);
						}
						_selectedPlanet = clickedOn;
						_animatedBackground.setSelectedPlanet(_selectedPlanet);
						updatePlanetInfo(_selectedPlanet);
					}
				}
			}
		}
		//super.handleMouseEvent(source,event);
		return true;
	}

	private void updateTutorial() {
		_stage++;
		string[] infos = [
			//0
			"Welcome to the tutorial! It will guide you through the rules and controls of the game.",
			//1
			"The game is about spreading and developing your civilisation in order to defeat other civilisation.",
			//2
			"To move around the world, hold right mouse button and move your mouse.\n\nTry it!",
			//3
			"To select a planet, drag your cursor over the planet and click left mouse button.\n\nClick on some planet",
			//4
			"When you start you will have one planet. If you cannot find it, click on any nearest planet and follow the green line. It will lead you to your planet.",
			//5
			"The red line will lead you to the enemy planet.",
			//6
			"Blue lines lead to uninhabited planets.",
			//7
			"Now click on your planet.",
			//8
			"On your right hand side you can see planet properties."~
			"\nHere you can order production of ships."~
			"\n-Military to attack"~
			"\n-Inhabitation to inhabit a free planet.",
			//9
			"But remember, adding ship to production will slow down your population growth on this planet!",
			//10
			"Before you can add order to produce military ship, you first need to convert some civil units to military.\nThis may lead to drop of the productivity on your planet, so do it carefully.",
			//11
			"Now select a free planet and inhabit it.",
			//12
			"\nIn the left bottom corner you will find knowledge tree button." ~
			"\nHere you can develop the knowledge of your population." ~
			"\nIt will bring up knowledge tree window." ~
			"\nTo hide it click anywhere outside of it.",
			//13
			"You can see there is already one item in the development queue."~
			"\n\nDeveloping one field affects others, so not all development paths are best for all cases!",
			//14
			"Developing food branch will increase your population growth"~
			"\nMilitary will increase force of your military units."~
			"\nScience and Energy will increase productivity on the planets and increase capacity of your ships.",
			//15
			"If you posses military ships, you can attack enemy planet."~
			"\nIt will destory population on those planets."~
			"\nAmount destroyed depends on the strength of your ship, which depends on the units onboard and military branch level effectiveness.",
			//16
			"Click attack button and tick the ships you want to use."~
			"\nYou can use all ships if you like, system will only use necessary mounts to destroy population.",
			//17
			"In the top left corner you will find END TURN button."~
			"\nWhen ready you can end your turn."~
			"\nDevelopment of some branches and ships might take more than one step.\n\nWhen you finish your turn, the AI will make it's moves and then return controls to you.",
			//18
			"Once either of the players have no planets left and has no inhabitation ships or has some but there are not free planets left, the player is defeated.",
			//19
			"To enter pause menu, press ESCAPE button on your keyboard.",
			//20
			"That is all you need to know. Enjoy the game!"
		];
		if(_currentPopup) {
			_window.removePopup(_currentPopup);
			_currentPopup.destroy();
		}
		int fontSize = 18;
		if(_stage == 0 || _stage == infos.length - 1) {
			fontSize = 30;
		}
		if(_stage == 2) {
			_movementEnabled = true;
		}
		if(_stage == 3) {
			_selectionEnabled = true;
		}
		if(_stage == 8) {
			_orderMilShipBtn.enabled(true);
			_orderInhShipBtn.enabled(true);
		}
		if(_stage == 10) {
			_convertUnitsButton.enabled(true);
		}
		if(_stage == 11) {
			_inhabitButton.enabled(true);
		}
		if(_stage == 12) {
			_knowledgeTreeButton.enabled(true);
			_deselectionEnabled = true;
		}
		if(_stage == 16) {
			_attackButton.enabled(true);
		}
		if(_stage == 17) {
			_endTurnButton.enabled(true);
		}
		writeln(_stage);
		if(_stage >= infos.length) {
			_window.removePopup(_currentPopup);
			if(_currentPopup) {
				_currentPopup.destroy();
			}
			_vh.setMainMenu();
		} else {
			_currentPopup = _window.showPopup(tutWid(infos[_stage], fontSize));
		}

	}
}