package org.skyfire2008.wayfinder.geom;

class Point {
	private static var curId: Int = 0;
	private var id: Int;

	public var x: Float;
	public var y: Float;

	public var length(get, set): Float;

	public function new(x: Float, y: Float) {
		this.x = x;
		this.y = y;
		this.id = Point.curId++;
	}

	public static inline function distance(a: Point, b: Point): Float {
		return difference(a, b).length;
	}

	public static inline function fromPolar(rot: Float, length: Float): Point {
		return new Point(Math.sin(rot) * length, -Math.cos(rot) * length);
	}

	public static inline function translate(a: Point, b: Point): Point {
		return new Point(a.x + b.x, a.y + b.y);
	}

	public static function difference(a: Point, b: Point): Point {
		return new Point(a.x - b.x, a.y - b.y);
	}

	public static inline function scale(a: Point, m: Float): Point {
		return new Point(a.x * m, a.y * m);
	}

	public static inline function rotate(a: Point, angle: Float): Point {
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);

		return new Point(a.x * cos - a.y * sin, a.x * sin + a.y * cos);
	}

	public static function dot(a: Point, b: Point): Float {
		return a.x * b.x + a.y * b.y;
	}

	public function equals(other: Point): Bool {
		return this.id == other.id;
	}

	public inline function rotate90(): Void {
		var temp = x;
		x = -y;
		y = temp;
	}

	private inline function get_length(): Float {
		return Math.sqrt(x * x + y * y);
	}

	private inline function set_length(length: Float): Float {
		if (x == 0 && y == 0) {
			x = length;
		} else {
			var oldLength = this.length;
			x *= length / oldLength;
			y *= length / oldLength;
		}

		return length;
	}
}
