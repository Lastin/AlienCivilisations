module handlers.vector2d;

class Vector2D{
	private float x;
	private float y;

	this(float x, float y){
		this.x = x;
		this.y = y;
	}

	public float getX(){
		return x;
	}
	private float getY(){
		return y;
	}
}