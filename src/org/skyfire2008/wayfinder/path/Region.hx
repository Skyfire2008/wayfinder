package org.skyfire2008.wayfinder.path;

import polygonal.ds.Prioritizable;

import org.skyfire2008.wayfinder.geom.Rectangle;

/**
 * Represents a part of navmesh, rectangular region on map in tile coordinates
 */
class Region implements Prioritizable {
	public var id(default, null): Int;
	public var x(default, null): Int;
	public var y(default, null): Int;
	public var width(default, null): Int;
	public var height(default, null): Int;
	public var area(default, null): Int;

	public var right(default, null): Int;
	public var bottom(default, null): Int;

	public var priority(default, null): Float;
	public var position(default, null): Int;

	public function new(x: Int = 0, y: Int = 0, width: Int = 0, height: Int = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;

		this.right = x + width;
		this.bottom = y + height;

		this.area = width * height;
		this.priority = area;
	}

	public function setId(id: Int) {
		this.id = id;
	}

	public inline function contains(x: Int, y: Int): Bool {
		return this.x <= x && this.right > x && this.y <= y && this.bottom > y;
	}

	public inline function intersects(other: Region): Bool {
		return other.x < this.right && this.x < other.right && other.y < this.bottom && this.y < other.bottom;
	}

	public function toRect(tileWidth: Float, tileHeight: Float): Rectangle {
		return new Rectangle(x * tileWidth, y * tileHeight, width * tileWidth, height * tileHeight);
	}

	/*public function equals(other: Region): Bool {
		return id == other.id;
	}*/
	public function setWidth(width: Int) {
		this.width = width;
		right = x + width;
		area = width * height;
		priority = area;
	}

	public function setHeight(height: Int) {
		this.height = height;
		bottom = y + height;
		area = width * height;
		priority = area;
	}
}
