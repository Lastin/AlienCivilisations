/**
This module implements container for 2 dimensional points

Author: Maksym Makuch
 **/

module src.containers.point2d;

import std.math;

struct Point2D {
	float x;
	float y;
	this(float x_param, float y_param) {
		x = x_param;
		y = y_param;
	}
	/** Returns Euclidean distance between this point and the argument **/
	float getEuclideanDistance(Point2D vecA) {
		auto xdiff = vecA.x - x;
		auto ydiff = vecA.y - y;
		return sqrt(xdiff^^2 + ydiff^^2);
	}
	/** Returns duplicate of this point **/
	Point2D dup() const {
		return Point2D(x, y);
	}
}