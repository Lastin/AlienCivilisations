module src.containers.vector2d;

import std.math;

class Vector2d {
	private immutable float _x;
	private immutable float _y;

	this(float x, float y){
		_x = x;
		_y = y;
	}

	@property float x() const {
		return _x;
	}
	@property float y() const {
		return _y;
	}

	float getEuclideanDistance(Vector2d vecA){
		auto xdiff = vecA.x - _x;
		auto ydiff = vecA.y - _y;
		return sqrt(xdiff^^2 + ydiff^^2);
	}
}