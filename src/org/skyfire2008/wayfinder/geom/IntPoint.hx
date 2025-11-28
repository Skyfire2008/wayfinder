package org.skyfire2008.wayfinder.geom;

class IntPoint {
	public var x: Int;
	public var y: Int;

	public static inline function distance(a: IntPoint, b: IntPoint): Float {
		var dx = a.x - b.x;
		var dy = a.y - b.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public function new(x: Int = 0, y: Int = 0) {
		this.x = x;
		this.y = y;
	}
}
