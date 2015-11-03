module entities.planet;
import handlers.vector2d;

class Planet {
	private Vector2D vec2d;
	private float radius;
	private int capacity;
	private bool breathable_atmosphere;

	this(){
		import std.random;
		radius = uniform(0.05, 2.0);
		capacity = cast(int)(uniform(1, 10) * radius) * 10000;
		breathable_atmosphere = uniform(0,2) == 1;
	}

	this(Vector2D vec2d, float radius, int capacity, bool breathable_atmosphere){
		this.vec2d = vec2d;
		this.radius = radius;
		this.capacity = capacity;
		this.breathable_atmosphere = breathable_atmosphere;
	}

	public Vector2D getVec2d(){
		return vec2d;
	}
	public bool getBreathable(){
		return breathable_atmosphere;
	}
	public int getCapacity(){
		return capacity;
	}
	public float getRadius(){
		return radius;
	}
}




