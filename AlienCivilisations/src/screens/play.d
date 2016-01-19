module src.screens.play;

import dlangui;
import std.stdio;
//import src.handlers.containers;

class Play : AppFrame {
	private {
		bool _middleDown = false;
		CanvasWidget _canvas;
		//Vector2d cameraPosition;
	}

	this(){
		mouseEvent = &handleMouseEvent;
	}

	void initialise() {
		_canvas.layoutWidth = FILL_PARENT;
		_canvas.layoutHeight = FILL_PARENT;
	}

	bool handleMouseEvent(Widget source, MouseEvent event) {
		if(event.action == MouseAction.ButtonDown) {
			if(event.button == MouseButton.Left)
				writefln("X: %s Y: %s", event.x, event.y);
		}
		if(event.button == MouseButton.Middle){
			if(event.action == MouseAction.ButtonUp)
				_middleDown = false;
			else if(event.action == MouseAction.ButtonDown)
				_middleDown = true;
		}
		else if(_middleDown && event.action == MouseAction.Move){
			writefln("X: %s Y: %s", event.x, event.y);
		}

		return true;
	}
}