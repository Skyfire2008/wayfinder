package org.skyfire2008.wayfinder.path;

import haxe.ds.IntMap;

import org.skyfire2008.wayfinder.geom.IntPoint;

/**
 * Map definition for exporting/importing as JSON
 */
typedef MapDef = {
	var walls: String;
	var width: Int;
	var height: Int;
};

class Map {
	public var walls(default, null): Array<Array<Bool>>;

	public var width(get, null): Int;
	public var height(get, null): Int;

	public function new(walls: Array<Array<Bool>>) {
		this.walls = walls;
	}

	public static function importDef(def: MapDef): Map {
		var walls: Array<Array<Bool>> = [];

		var i = 0;
		for (y in 0...def.height) {
			var row: Array<Bool> = [];
			for (x in 0...def.width) {
				switch (def.walls.charAt(i)) {
					case "0":
						row.push(false);
					case "1":
						row.push(true);
					default:
						throw 'Illegal wall character ${def.walls.charAt(i)} at ${x}, ${y} in map definition';
				}

				i++;
			}
			walls.push(row);
		}

		return new Map(walls);
	}

	public static function exportDef(map: Map): MapDef {
		var wallString = "";

		for (y in 0...map.height) {
			for (x in 0...map.width) {
				wallString = wallString + (map.walls[y][x] ? "1" : "0");
			}
		}

		return {
			walls: wallString,
			width: map.width,
			height: map.height
		}
	}

	/**
	 * Makes sure that all the non-wall components are connected
	 */
	public function ensureConnectivity() {

		// TODO: use a queue instead of recursion when growing components
		var componentId = 1;

		var compGrid: Array<Array<Int>> = [];
		var compStartMap = new IntMap<IntPoint>();

		var queue: Array<() -> Void> = [];

		var growComponent: (x: Int, y: Int) -> Void;
		growComponent = (x: Int, y: Int) -> {
			if (x < 0 || x >= width || y < 0 || y >= height || compGrid[y][x] != 0) {
				return;
			}

			compGrid[y][x] = componentId;
			queue.push(growComponent.bind(x - 1, y));
			queue.push(growComponent.bind(x + 1, y));
			queue.push(growComponent.bind(x, y - 1));
			queue.push(growComponent.bind(x, y + 1));
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
					while (queue.length > 0) {
						queue.shift()();
					}
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
