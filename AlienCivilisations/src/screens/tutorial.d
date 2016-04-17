module src.screens.tutorial;

import src.screens.play;
import src.handlers.viewHanlder;
import src.handlers.gameManager;
import src.containers.point2d;
import dlangui;

class Tutorial : Play {
	private int _stage = 0;
	private PopupWidget _currentPopup;
	private Window _window;
	private ViewHandler _vh;

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
			_vh.setMainMenu();
			return true;
		};
		Button btn2 = new Button(null, "Continue"d);
		hl2.addChild(btn1);
		hl2.addChild(new HSpacer());
		hl2.addChild(btn2);
		vl.addChild(hl2);
		vl.backgroundColor(0x4B4B4B);
		return vl;
	}
	override bool handleMouseEvent(Widget source, MouseEvent event) {
		super.handleMouseEvent(source,event);
		if(_stage == 3) {

		}
		return true;
	}

	private void updateTutorial() {
		_stage++;
		if(_currentPopup) {
			_window.removePopup(_currentPopup);
			_currentPopup.destroy();
		}
		if(_stage == 1) {
			_currentPopup = _window.showPopup(tutWid("Welcome to tutorial! It will guide you through the rules and controls of the game.", 30));
		}
	}
}