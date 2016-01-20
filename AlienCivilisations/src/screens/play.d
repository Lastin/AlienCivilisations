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
		GameManager _gm;
		AnimatedDrawable _animation;
		DrawableRef drawableRef;
	}


	this(){
		mouseEvent = &handleMouseEvent;
		initialise();
	}

	void initialise() {
		layoutWidth = FILL_PARENT;
		layoutHeight = FILL_PARENT;
		_gm = new GameManager();
		_cameraPosition = Vector2d(_gm.state.map.size/2, _gm.state.map.size/2);
		_endPosition = Vector2d(_gm.state.map.size/2, _gm.state.map.size/2);
		_animation = new AnimatedDrawable(&_cameraPosition, _gm.state.map.planets);
		drawableRef = _animation;
	}

	bool handleMouseEvent(Widget source, MouseEvent event) {
		if(event.action == MouseAction.ButtonDown) {
			if(event.button == MouseButton.Left) {
				auto relativeMousePosition = Vector2d(
					_cameraPosition.x + event.x,
					_cameraPosition.y + event.y);
				writefln("Mouse Pos X: %s Y: %s", relativeMousePosition.x, relativeMousePosition.y);
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
		return true;
	}

	override void animate(long interval) {
		//_animation.animate(interval);
		invalidate();
	}
	@property override bool animating() { return true; }
	@property override DrawableRef backgroundDrawable() const {
		return (cast(Play)this).drawableRef;
	}
}

class AnimatedDrawable : Drawable {
	DrawableRef background;
	private Vector2d* _cameraPosition;
	private Planet[] _planets;
	this(Vector2d* cameraPosition, Planet[] planets) {
		_cameraPosition = cameraPosition;
		_planets = planets;
		//background = drawableCache.get("tx_fabric.tiled");
	}
	void drawAnimatedIcon(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, string resourceId) {
		int x = (p * speedx % rc.width);
		int y = (p * speedy % rc.height);
		if (x < 0)
			x += rc.width;
		if (y < 0)
			y += rc.height;
		DrawBufRef image = drawableCache.getImage(resourceId);
		buf.drawImage(x, y, image.get);
	}
	override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
		//background.drawTo(buf, rc, state, cast(int)(animationProgress / 695430), cast(int)(animationProgress / 1500000));
		//drawAnimatedIcon(buf, cast(uint)(animationProgress / 212400) + 200, rc, -2, 1, "earth");
		DrawBufRef image = drawableCache.getImage("earth");
		foreach(Planet planet; _planets){
			int radius = to!int(planet.radius);
			int x = to!int(planet.position.x - _cameraPosition.x);
			int y = to!int(planet.position.y - _cameraPosition.y);
			buf.drawRescaled(Rect(x-radius,y-radius, x+radius, y+radius), image, Rect(0,0,image.width,image.height));
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