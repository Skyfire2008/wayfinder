package org.skyfire2008.wayfinder.path;

import haxe.ds.IntMap;

import org.skyfire2008.wayfinder.geom.IntPoint;

class Map {
	public var walls(default, null): Array<Array<Bool>>;
	public var tileWidth(default, null): Float;
	public var tileHeight(default, null): Float;

	public var width(get, null): Int;
	public var height(get, null): Int;

	public function new(walls: Array<Array<Bool>>, tileWidth: Float, tileHeight: Float) {
		this.walls = walls;
		this.tileWidth = tileWidth;
		this.tileHeight = tileHeight;
	}

	/**
	 * Makes sure that all the non-wall components are connected
	 */
	public function ensureConnectivity() {
		var componentId = 1;

		var compGrid: Array<Array<Int>> = [];
		var compStartMap = new IntMap<IntPoint>();

		var growComponent: (x: Int, y: Int) -> Void;
		growComponent = (x: Int, y: Int) -> {
			if (x < 0 || x >= width || y < 0 || y >= height || compGrid[y][x] != 0) {
				return;
			}

			compGrid[y][x] = componentId;
			growComponent(x - 1, y);
			growComponent(x + 1, y);
			growComponent(x, y - 1);
			growComponent(x, y + 1);
		};

		// init the component grid
		for (y in 0...height) {
			var current: Array<Int> = [];
			for (x in 0...width) {
				current.push(walls[y][x] ? -1 : 0);
			}
			compGrid.push(current);
		}

		// grow the components
		for (x in 0...width) {
			for (y in 0...height) {
				var cell = compGrid[y][x];

				if (cell == 0) {
					compStartMap.set(componentId, new IntPoint(x, y));
					growComponent(x, y);
					componentId++;
				}
			}
		}

		if (componentId > 2) {
			// just carve paths between the component starting points using the good old fast voxel traversal algorithm
			for (i in 1...componentId - 1) {
				var p0 = compStartMap.get(i);
				var p1 = compStartMap.get(i + 1);

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
					walls[y][x] = false;

					if (tMaxX < tMaxY) {
						tMaxX += tDeltaX;
						x += stepX;
					} else {
						tMaxY += tDeltaY;
						y += stepY;
					}
				}
			}
		}

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
