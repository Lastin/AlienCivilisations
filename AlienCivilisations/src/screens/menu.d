module src.states.menu;

import dlangui;
import std.stdio;

class Menu : VerticalLayout
{
	this()
	{
		layoutWeight(FILL_PARENT).layoutHeight(FILL_PARENT);

		//layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
		//alignment(Align.Right | Align.Center);
		//backgroundImageId = "background";
		backgroundDrawable = DrawableRef(new OpenGLDrawable(
	}
}