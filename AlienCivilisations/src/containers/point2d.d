module src.containers.point2d;
import std.math;

struct Point2D {
	float x;
	float y;
	this(float x_param, float y_param) {
		x = x_param;
		y = y_param;
	}
	
	float getEuclideanDistance(Point2D vecA) {
		auto xdiff = vecA.x - x;
		auto ydiff = vecA.y - y;
		return sqrt(xdiff^^2 + ydiff^^2);
	}
	
	Point2D dup() const {
		return Point2D(x, y);
	}
}