module handlers.vector2d;

class Vector2D {
	private float x;
	private float y;

	this(float x, float y){
		this.x = x;
		this.y = y;
	}

	public float getX(){
		return x;
	}
	public float getY(){
		return y;
	}

	public float getEuclidDist(Vector2D vec){
		import std.math;
		return sqrt((x-vec.getX())^^2 + (y+vec.getY())^^2);
	}

	public static getEucliDist(Vector2D vecA, Vector2D vecB){
		import std.math;
		return sqrt((vecA.getX() - vecB.getX())^^2 + (vecA.getY() - vecB.getY())^^2);
	}
}