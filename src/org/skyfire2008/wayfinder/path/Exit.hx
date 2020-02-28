package org.skyfire2008.wayfinder.path;

class Exit {
	public var a(default, null): IntPoint;
	public var b(default, null): IntPoint;

	public function new(a: IntPoint, b: IntPoint) {
		this.a = a;
		this.b = b;
	}
}

class IntPoint {
	public var x: Int;
	public var y: Int;

	public function new(x: Int = 0, y: Int = 0) {
		this.x = x;
		this.y = y;
	}
}
