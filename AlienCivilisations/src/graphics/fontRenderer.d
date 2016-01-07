module src.graphics.fontRenderer;

import derelict.freetype.ft;
import derelict.opengl3.gl3;
import derelict.opengl3.gl;
import std.stdio;
import std.conv;

class FontRenderer {
	private FT_Library library;
	private FT_Face face;
	private float sx;
	private float sy;
	private int horizontal_dpi;
	private int vertical_dpi;

	this(int font_size, int width, int height, int widthMM, int heightMM){
		horizontal_dpi = to!int(width / (widthMM / 25.4));
		vertical_dpi = to!int(height / (heightMM / 25.4));
		sx = 2.0 / width;
		sy = 2.0 / height;
		//
		auto error = FT_Init_FreeType(&library);
		if(error){
			writeln("Library not initialised");
		}
		error = FT_New_Face(library, "/etc/alternatives/fonts-japanese-gothic.ttf", 0, &face);
		if(error == FT_Err_Unknown_File_Format){
			writeln("Unknown font file format");
		}
		else if(error){
			writeln("Font file not found");
		}
		error = FT_Set_Char_Size(
					face,			//handle to face obj
					0,				//char width in 1/64th of points
					font_size*64, 	//char_height in 1/64th of points
					horizontal_dpi, //horizontal device resolution
					vertical_dpi  	//vertical device resolution
				);
		//error = FT_Select_Charmap(face,FT_ENCODING_BIG5);
	}

	public void render_text(uint[] codepoints, int x, int y){
		string s = cast(string)codepoints;
		render_text(s, x, y);
	}

	public void render_text(string str, int pen_x, int pen_y){
		writeln("rendering :" ~ str);
		FT_GlyphSlot slot = face.glyph;
		FT_UInt glyph_index;
		foreach(char c; str){
			glyph_index = FT_Get_Char_Index(face, c);
			auto error = FT_Load_Glyph(face, glyph_index, FT_LOAD_DEFAULT);
			if(error){ continue; }
			drawBitmap(
				&slot.bitmap,
				pen_x + slot.bitmap_left,
				pen_y + slot.bitmap_top);
			pen_x += slot.advance.x >> 6;
		}
	}

	public void drawBitmap(FT_Bitmap* slot, int x, int y){
		writeln(slot);
		glClear(GL_COLOR_BUFFER_BIT);
		glColor3f(1.0, 1.0, 1.0);
		glRasterPos2d(x, y);
	}
}