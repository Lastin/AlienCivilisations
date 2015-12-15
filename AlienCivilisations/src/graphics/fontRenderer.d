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
		if(error){}
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

	public void render_text(uint[] codepoints, float x, float y){
		string s = cast(string)codepoints;
		render_text(s, x, y);
	}

	public void render_text(string str, float x, float y){
		//writeln(str);
		FT_GlyphSlot glyph = face.glyph;
		ulong p;
		for(int i=0; i<str.length; i++){
			if(FT_Load_Char(face, p, FT_LOAD_RENDER))
				continue;
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RED, glyph.bitmap.width, glyph.bitmap.rows, 0, GL_RED, GL_UNSIGNED_BYTE, glyph.bitmap.buffer);
			float x2 = x + glyph.bitmap_left * sx;
			float y2 = -y - face.glyph.bitmap_top * sy;
			float w = glyph.bitmap.width * sx;
			float h = glyph.bitmap.rows * sy;
			GLfloat[4][4] box = [
				[x2,   -y2,   0, 0],
				[x2+w, -y2,   1, 0],
				[x2,   -y2-h, 0, 1],
				[x2+w, -y2,   1, 1],
			];
			glBufferData(GL_ARRAY_BUFFER, box.sizeof, &box, GL_DYNAMIC_DRAW);
			//glBufferSubData(GL_ARRAY_BUFFER, 0, box.sizeof, &box);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			x += (glyph.advance.x >> 6) * sx;
			y += (glyph.advance.y >> 6) * sy;
		}
	}
}