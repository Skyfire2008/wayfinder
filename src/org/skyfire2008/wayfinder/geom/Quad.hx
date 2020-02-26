package org.skyfire2008.wayfinder.geom;

class Quad {
	public var x(default, null): Int;
	public var y(default, null): Int;
	public var width(default, null): Int;
	public var height(default, null): Int;
	public var area(default, null): Int;

	public function new(x: Int = 0, y: Int = 0, width: Int = 0, height: Int = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.area = width * height;
	}
}
