package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;

class Map {
	public var walls(default, null): Array<Array<Bool>>;
	public var tileWidth(default, null): Float;
	public var tileHeight(default, null): Float;

	public var width(get, null): Int;
	public var height(get, null): Int;

	// TODO: what is this for?
	// public var navMesh: NavMesh;

	public function new(walls: Array<Array<Bool>>, tileWidth: Float, tileHeight: Float) {
		this.walls = walls;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;

		// this.navMesh = NavMesh.makeNavMesh(walls, tileWidth, tileHeight);
	}

	/**
	 * Checks if one coordinate is visible from another using the fast voxel traversal algorithm
	 * @param p0 starting point
	 * @param p1 end point
	 * @returns true if no walls between p0 and p1, false otherwise
	 */
	public function checkVisibility(p0: IntPoint, p1: IntPoint): Bool {
		// this is a special case since points are integer, so no taking care of different positions inside a cell is necessary
		var stepX = p1.x > p0.x ? 1 : -1;
		var stepY = p1.y > p0.y ? 1 : -1;
		var v: IntPoint = new IntPoint(p1.x - p0.x, p1.y - p0.y);

		var tDeltaX = stepX / v.x;
		var tDeltaY = stepY / v.y;

		// distance to next horizontal border in t
		// always 0.5/abs(v.x) cause point is in the center of cell
		var tMaxX: Float;
		if (!Math.isFinite(tDeltaX)) {
			tMaxX = Math.POSITIVE_INFINITY;
		} else {
			tMaxX = 0.5 * tDeltaX;
		}

		// distance to next vertical border in t
		var tMaxY: Float;
		if (!Math.isFinite(tDeltaY)) {
			tMaxY = Math.POSITIVE_INFINITY;
		} else {
			tMaxY = 0.5 * tDeltaY;
		}

		var x = p0.x;
		var y = p0.y;

		while (x != p1.x || y != p1.y) {
			if (isWall(x, y)) {
				return false;
			}

			if (tMaxX < tMaxY) {
				tMaxX += tDeltaX;
				x += stepX;
			} else {
				tMaxY += tDeltaY;
				y += stepY;
			}
		}

		return true;
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
