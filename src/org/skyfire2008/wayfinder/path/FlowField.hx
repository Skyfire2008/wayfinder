package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.util.Util;
import org.skyfire2008.wayfinder.geom.IntPoint;

class FlowField {
	private var directions: Array<Array<IntPoint>>;
	private var end: IntPoint;

	public function new(walls: Array<Array<Bool>>, end: IntPoint) {
		this.directions = [];
		this.end = end;

		for (row in walls) {
			var dirRow: Array<IntPoint> = [];
			var distRow: Array<Float> = [];
			for (wall in row) {
				dirRow.push(null);
			}
			directions.push(dirRow);
		}

		var queue: Array<() -> Void> = [];

		// calculates movement direction from this cell to next, add calls for next cells to queue
		var calcDirection: (x: Int, y: Int, nextX: Int, nextY: Int) -> Void;
		calcDirection = (x: Int, y: Int, nextX: Int, nextY: Int) -> {
			// skip if cell out of bounds
			if (x < 0 || x >= directions[0].length || y < 0 || y >= directions.length) {
				return;
			}

			// skip if cells is a wall or was already processed
			if (walls[y][x] || directions[y][x] != null) {
				return;
			}

			var direction = new IntPoint(nextX - x, nextY - y);
			directions[y][x] = direction;

			queue.push(calcDirection.bind(x + 1, y, x, y));
			queue.push(calcDirection.bind(x - 1, y, x, y));
			queue.push(calcDirection.bind(x, y + 1, x, y));
			queue.push(calcDirection.bind(x, y - 1, x, y));
		};

		calcDirection(end.x, end.y, end.x, end.y);
		while (queue.length > 0) {
			queue.shift()();
		}

		/*var text = "\n";
			for (row in directions) {
				for (dir in row) {
					if (dir == null) {
						text += "(  ,   ) ";
					} else {
						text += '(${dir.x >= 0 ? "+" + dir.x : "" + dir.x}, ${dir.y >= 0 ? "+" + dir.y : "" + dir.y}) ';
					}
				}
				text += "\n";
			}
			trace(text); */
	}

	public function getPath(start: IntPoint): Path {
		var path: Array<IntPoint> = [];

		if (directions[start.y][start.x] == null) {
			throw "End unreachable";
		}

		var current = start.copy();
		while (current.x != end.x || current.y != end.y) {
			path.push(current.copy());
			var cell = directions[current.y][current.x];
			current.add(cell);
		}
		path.push(end);

		return new Path(path);
	}
}
