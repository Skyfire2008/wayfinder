package org.skyfire2008.wayfinder.path;

/**
 * Represents a part of navmesh, rectangular region on map in tile coordinates
 */
class Region {
	private static var incId = 0;

	public var id(default, null): Int;
	public var x(default, null): Int;
	public var y(default, null): Int;
	public var width(default, null): Int;
	public var height(default, null): Int;
	public var area(default, null): Int;

	public var right(get, null): Int;
	public var bottom(get, null): Int;

	public function new(x: Int = 0, y: Int = 0, width: Int = 0, height: Int = 0) {
		this.id = incId++;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.area = width * height;
	}

	public function equals(other: Region): Bool {
		return id == other.id;
	}

	// GETTERS AND SETTERS
	private inline function get_right(): Int {
		return x + width;
	}

	private inline function get_bottom(): Int {
		return y + height;
	}
}
