package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;

class Map {
	public var walls(default, null): Array<Array<Bool>>;
	public var tileWidth(default, null): Float;
	public var tileHeight(default, null): Float;

	public var width(get, null): Int;
	public var height(get, null): Int;

	public var navMesh: NavMesh;

	public function new(walls: Array<Array<Bool>>, tileWidth: Float, tileHeight: Float) {
		this.walls = walls;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		this.navMesh = NavMesh.makeNavMesh(walls, tileWidth, tileHeight);
	}

	public inline function isWall(x: Int, y: Int): Bool {
		return walls[y][x];
	}

	public inline function isPointWall(p: IntPoint): Bool {
		return walls[p.y][p.x];
	}

	private inline function get_width(): Int {
		return walls[0].length;
	}

	private inline function get_height(): Int {
		return walls.length;
	}
}
