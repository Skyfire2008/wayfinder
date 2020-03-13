package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.Point;

class Map {
	public var walls(default, null): Array<Array<Bool>>;
	public var tileWidth(default, null): Float;
	public var tileHeight(default, null): Float;

	public var navMesh: NavMesh;

	public function new(walls: Array<Array<Bool>>, tileWidth: Float, tileHeight: Float) {
		this.walls = walls;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		this.navMesh = NavMesh.makeNavMesh(walls, tileWidth, tileHeight);
	}

	public function makePath(a: Point, b: Point): Path {
		return null;
	}
}
