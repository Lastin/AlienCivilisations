module src.containers.vector2d;

import std.math;

struct Vector2d {
	immutable float x;
	immutable float y;
	this(float x_param, float y_param){
		x = x_param;
		y = y_param;
	}

	float getEuclideanDistance(Vector2d vecA){
		auto xdiff = vecA.x - x;
		auto ydiff = vecA.y - y;
		return sqrt(xdiff^^2 + ydiff^^2);
	}
	Vector2d dup() const {
		return Vector2d(x, y);
	}
}