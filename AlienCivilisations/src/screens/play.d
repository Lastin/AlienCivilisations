module src.screens.play;

import dlangui;
import src.entities.planet;
import src.entities.player;
import src.handlers.containers;
import src.handlers.gameManager;
import src.screens.menu;
import std.stdio;

class Play : AppFrame {
	private {
		bool _middleDown = false;
		Vector2d _startPosition;
		Vector2d _endPosition;
		Vector2d _cameraPosition;
		short zoom = 1;
		GameManager _gm;
		AnimatedDrawable _animation;
		DrawableRef _drawableRef;
		Widget _planetInfoContainer;
		Widget _playerStatsContainer;
	}

	this(){
		mouseEvent = &handleMouseEvent;
		keyEvent = &handleKeyEvent;
		initialise();
		addChild(makeLayout());
		_planetInfoContainer = childById("verticalContainer").childById("horizontalContainer").
			childById("rightVerticalPanel").childById("hr2").childById("vr2");
		_planetInfoContainer.visibility = Visibility.Invisible;
		_playerStatsContainer = childById("verticalContainer").childById("horizontalContainer").
			childById("vr1").childById("hr1");
		updatePlayerStats();
		Widget endTurnButton = _playerStatsContainer.childById("endTurnButton");
		endTurnButton.click = &endTurn;
	}

	bool endTurn(Widget source) {
		return true;
	}

	bool handleKeyEvent(Widget source, KeyEvent event){
		if(event.action == KeyAction.KeyDown &&
			event.keyCode == KeyCode.ESCAPE) {
				window.mainWidget = new Menu(this);
				return true;
		}
		return false;
	}

	Widget makeLayout(){
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
						}
					}
					HSpacer {}
					VerticalLayout {
						id: rightVerticalPanel
						layoutHeight: fill
						VSpacer {}
						HorizontalLayout {
							id: hr2
							VerticalLayout {
								id: vr2
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
								}
								Button {
									id: inhabitButton
									text: "Inhabit"
									padding: 10
									margins: 10
								}
								Button {
									id: convertUnitsButton
									text: "Convert units"
									padding: 10
									margins: 10
								}
							}
						}
						VSpacer {}
					}
				}
				VSpacer{}
				HorizontalLayout {
					VerticalLayout {
						backgroundColor: 0x80969696
						Button {
							id: knowledgeTreeButton
							text: "KNOWLEDGE TREE"
							padding: 20
							margins: 10
						}
					}
				}
			}
		};
		return parseML(layout);
	}

	void initialise() {
		layoutWidth = FILL_PARENT;
		layoutHeight = FILL_PARENT;
		_gm = new GameManager();
		float tempX = _gm.state.players[0].planets(_gm.state.map.planets)[0].position.x;
		float tempY = _gm.state.players[0].planets(_gm.state.map.planets)[0].position.y;
		_cameraPosition = Vector2d(tempX - width / 2, tempY - height / 2);
		debug writefln("camera initial position: %s %s", tempX, tempY);
		_endPosition = Vector2d(tempX - width / 2, tempY - height / 2);
		_animation = new AnimatedDrawable(&_cameraPosition, _gm.state);
		_drawableRef = _animation;
	}

	void updatePlanetInfo(Planet planet) {
		if(planet) {
			_planetInfoContainer.visibility = Visibility.Visible;
			_planetInfoContainer.childById("planetPopulation").text = to!dstring(planet.populationSum);
			_planetInfoContainer.childById("militaryUnits").text = to!dstring(planet.militaryUnits);
			_planetInfoContainer.childById("planetName").text = to!dstring(planet.name);
			_planetInfoContainer.childById("planetName").textFlags = TextFlag.Underline;
			if(planet.owner == _gm.state.players[0]) {
				_planetInfoContainer.childById("convertUnitsButton").visibility = Visibility.Visible;
				_planetInfoContainer.childById("inhabitButton").visibility = Visibility.Gone;
			} else {
				_planetInfoContainer.childById("convertUnitsButton").visibility = Visibility.Gone;
				_planetInfoContainer.childById("inhabitButton").visibility = Visibility.Visible;
			}
		}
		else {
			_planetInfoContainer.visibility = Visibility.Invisible;
		}

	}
	
	void updatePlayerStats() {
		Player human = _gm.state.players[0];
		uint populationTotal = 0;
		uint militaryUnitTotal = 0;
		foreach(Planet p; human.planets(_gm.state.map.planets)) {
			populationTotal += p.populationSum;
			militaryUnitTotal += p.militaryUnits;
		}
		_playerStatsContainer.childById("totalPopulation").text = to!dstring(populationTotal);
		_playerStatsContainer.childById("totalMilitaryUnits").text = to!dstring(militaryUnitTotal);
	}

	bool handleMouseEvent(Widget source, MouseEvent event) {
		if(event.action == MouseAction.ButtonDown) {
			if(event.button == MouseButton.Left) {
				auto relativeMousePosition = Vector2d(
					_cameraPosition.x + event.x,
					_cameraPosition.y + event.y);
				debug writefln("Mouse Pos X: %s Y: %s", relativeMousePosition.x, relativeMousePosition.y);
				Planet selected = _gm.state.map.collides(relativeMousePosition, 1, 0);
				_animation.setSelectedPlanet(selected);
				updatePlanetInfo(selected);
			}
		}
		if(event.button == MouseButton.Middle){
			if(event.action == MouseAction.ButtonUp) {
				_middleDown = false;
				_endPosition.x = _cameraPosition.x;
				_endPosition.y = _cameraPosition.y;
			}
			else if(event.action == MouseAction.ButtonDown) {
				_middleDown = true;
				_startPosition.x = event.x;
				_startPosition.y = event.y;
			}
		}
		else if(_middleDown && event.action == MouseAction.Move) {
			_cameraPosition.x = to!int(_endPosition.x + (_startPosition.x - event.x));
			_cameraPosition.y = to!int(_endPosition.y + (_startPosition.y - event.y));
			//check x boundaries
			if(_cameraPosition.x < 0 - (width / 2)) {
				_cameraPosition.x = 0 - (width / 2);
			}
			else if(_cameraPosition.x > _gm.state.map.size + (width / 2)) {
				_cameraPosition.x = to!int(_gm.state.map.size) + (width / 2);
			}
			//check y boundaries
			if(_cameraPosition.y < 0 - (height / 2)) {
				_cameraPosition.y = 0 - (height / 2);
			}
			else if(_cameraPosition.y > _gm.state.map.size + (height / 2)) {
				_cameraPosition.y = to!int(_gm.state.map.size) + (height / 2);
			}
			//writefln("X: %s Y: %s", _cameraPosition.x, _cameraPosition.y);
		}
		else if(event.action == MouseAction.Wheel){
		}
		return true;
	}

	override void animate(long interval) {
		//_animation.animate(interval);
		invalidate();
	}
	@property override bool animating() { return true; }
	@property override DrawableRef backgroundDrawable() const {
		return (cast(Play)this)._drawableRef;
	}
}

class AnimatedDrawable : Drawable {
	private DrawableRef _background;
	private Vector2d* _cameraPosition;
	private Planet[] _planets;
	private Planet _selected;
	private GameState _state;
	this(Vector2d* cameraPosition, GameState state) {
		_cameraPosition = cameraPosition;
		_state = state;
		_planets = _state.map.planets;
		_background = drawableCache.get("noise.tiled");
	}

	void setSelectedPlanet(Planet selected){
		_selected = selected;
	}

	override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
		Rect noisePos;
		int startX, startY;
		for(int i=7; i>2; i -= 2) {
			startX = to!int(0-_cameraPosition.x/i);
			startY = to!int(0-_cameraPosition.y/i);
			noisePos = Rect(startX, startY, rc.right, rc.bottom);
			_background.drawTo(buf, noisePos, state, tilex0, tiley0);
		}
		DrawBufRef image = drawableCache.getImage("earth");
		//Image circle = new Image(Geometry(10, 10), new Color("white"));
		foreach(Planet planet; _planets) {
			if(_selected && _selected != planet) {
				int relX = to!int(_selected.position.x - _cameraPosition.x);
				int relY = to!int(_selected.position.y - _cameraPosition.y);
				int x = to!int(planet.position.x - _cameraPosition.x);
				int y = to!int(planet.position.y - _cameraPosition.y);
				uint colour = 0x408000;
				if(planet.owner && planet.owner == _state.players[0]) {
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
		//buf.drawImage(500, 500, image.get);
	}
	@property override int width() {
		return 1;
	}
	@property override int height() {
		return 1;
	}
}