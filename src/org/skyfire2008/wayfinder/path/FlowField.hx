package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.util.Util;
import org.skyfire2008.wayfinder.geom.IntPoint;

class FlowField {
	private var directions: Array<Array<IntPoint>>;
	private var end: IntPoint;

	public function new(walls: Array<Array<Bool>>, end: IntPoint) {
		this.directions = [];
		this.end = end;

		if (walls[end.y][end.x]) {
			throw "End node is a wall";
		}

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
	}

	public function getPath(start: IntPoint): Array<IntPoint> {
		var path: Array<IntPoint> = [];

		if (directions[start.y][start.x] == null) {
			throw "End unreachable";
		}

		if (start.x == end.x && start.y == end.y) {
			return [start, end];
		}

		var current = start.copy();
		while (current.x != end.x || current.y != end.y) {
			path.push(current.copy());
			var cell = directions[current.y][current.x];
			current.add(cell);
		}
		path.push(end);

		return path;
	}
}
