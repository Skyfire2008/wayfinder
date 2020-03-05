package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.Point;

class Exit {
	public var a(default, null): Point;
	public var b(default, null): Point;

	public function new(a: Point, b: Point) {
		this.a = a;
		this.b = b;
	}
}
