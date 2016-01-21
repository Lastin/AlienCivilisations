module src.screens.play;

import dlangui;
import src.handlers.containers;
import std.stdio;
import src.handlers.gameManager;
import src.entities.planet;

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
	}


	this(){
		mouseEvent = &handleMouseEvent;
		initialise();
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
						id: verticalRestrictor
						HorizontalLayout {
							id: horizontalRestrictor
							backgroundColor: 0x80000000
							padding: 5
							Button {
								id: newGameButton
								text: "END TURN"
								padding: 15
								margins: Rect { 10 10 30 10}
							}
							TextWidget {
								fontWeight: 800
								text: "Total population:"
							}
							TextWidget {
								id: totalPopulation
								text: ""
								padding: Rect {5 10 30 10}
							}
							TextWidget {
								fontWeight: 800
								text: "Total military units:"
							}
							TextWidget {
								id: totalMilitaryUnits
								text: ""
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
							id: horizontalRestrictor
							VerticalLayout {
								id: verticalRestrictor
								backgroundColor: 0x80000000
								TextWidget {
									padding: 10
									id: planetName
									text : ""
									fontWeight: 800
									fontSize: 20
								}
								TableLayout {
									id: planetInfoTable
									padding: 10
									colCount: 2
									TextWidget {
										fontWeight: 800
										text: "Population: "
									}
									TextWidget {
										id: planetPopulation
										text : ""
									}
									TextWidget {
										fontWeight: 800
										text: "Military units: "
										
									}
									TextWidget {
										id: militaryUnits
										text : ""
									}
								}
								Button {
									id: newGameButton
									text: "Inhabit"
									padding: 10
									margins: 10
								}
								Button {
									id: newGameButton
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
						backgroundColor: 0x80000000
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
		addChild(parseML(layout));
		_planetInfoContainer = childById("verticalContainer").childById("horizontalContainer").
			childById("rightVerticalPanel").childById("horizontalRestrictor").childById("verticalRestrictor");
		_planetInfoContainer.visibility = Visibility.Invisible;
	}

	void initialise() {
		layoutWidth = FILL_PARENT;
		layoutHeight = FILL_PARENT;
		_gm = new GameManager();
		_cameraPosition = Vector2d(_gm.state.map.size/2, _gm.state.map.size/2);
		_endPosition = Vector2d(_gm.state.map.size/2, _gm.state.map.size/2);
		_animation = new AnimatedDrawable(&_cameraPosition, _gm.state);
		_drawableRef = _animation;
	}


	bool handleMouseEvent(Widget source, MouseEvent event) {
		if(event.action == MouseAction.ButtonDown) {
			if(event.button == MouseButton.Left) {
				auto relativeMousePosition = Vector2d(
					_cameraPosition.x + event.x,
					_cameraPosition.y + event.y);
				writefln("Mouse Pos X: %s Y: %s", relativeMousePosition.x, relativeMousePosition.y);
				Planet selected = _gm.state.map.collides(relativeMousePosition, 1, 0);
				_animation.setSelectedPlanet(selected);
				if(selected){
					updatePlanetInfo(selected);
				}
				else {
					_planetInfoContainer.visibility = Visibility.Invisible;
				}
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
	
	void updatePlanetInfo(Planet planet){
		_planetInfoContainer.visibility = Visibility.Visible;
		_planetInfoContainer.childById("planetPopulation").text = to!dstring(planet.populationSum);
		_planetInfoContainer.childById("militaryUnits").text = to!dstring(planet.militaryUnits);
		_planetInfoContainer.childById("planetName").text = to!dstring(planet.name);
		_planetInfoContainer.childById("planetName").textFlags = TextFlag.Underline;
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
	DrawableRef background;
	private Vector2d* _cameraPosition;
	private Planet[] _planets;
	private Planet _selected;
	private GameState _state;
	this(Vector2d* cameraPosition, GameState state) {
		_cameraPosition = cameraPosition;
		_state = state;
		_planets = _state.map.planets;
		//background = drawableCache.get("tx_fabric.tiled");
	}

	void setSelectedPlanet(Planet selected){
		_selected = selected;
	}

	override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
		//background.drawTo(buf, rc, state, cast(int)(animationProgress / 695430), cast(int)(animationProgress / 1500000));
		//drawAnimatedIcon(buf, cast(uint)(animationProgress / 212400) + 200, rc, -2, 1, "earth");
		DrawBufRef image = drawableCache.getImage("earth");
		foreach(Planet planet; _planets) {
			if(_selected && _selected != planet) {
				int relX = to!int(_selected.position.x - _cameraPosition.x);
				int relY = to!int(_selected.position.y - _cameraPosition.y);
				int x = to!int(planet.position.x - _cameraPosition.x);
				int y = to!int(planet.position.y - _cameraPosition.y);
				uint colour = 0x408000;
				if(planet.owner && planet.owner == _state.currentPlayer) {
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