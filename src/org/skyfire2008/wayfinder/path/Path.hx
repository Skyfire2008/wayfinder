package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.util.Util;

import polygonal.ds.PriorityQueue;
import polygonal.ds.Prioritizable;

class PathPart implements Prioritizable {
	public var x: Int;
	public var y: Int;

	public var priority(default, null): Float;
	public var position(default, null): Int;

	public function new(x: Int, y: Int, priority: Int) {
		this.x = x;
		this.y = y;
		this.priority = priority;
	}
}

class Path {
	public var points: Array<IntPoint>;

	/**
	 * Distance heuristic for A*(Manhattan distance)
	 * @param start 
	 * @param end 
	 * @return Int
	 */
	private static function getDist(start: IntPoint, end: IntPoint): Int {
		return Util.abs(start.x - end.x) + Util.abs(start.y - end.y);
	}

	public static function findAStar(map: Map, start: IntPoint, end: IntPoint): Path {
		if (map.isPointWall(start)) {
			throw "Start point is a wall";
		}

		if (map.isPointWall(end)) {
			throw "End point is a wall";
		}

		// initialize queue and stuff
		var queue = new PriorityQueue<PathPart>(17, true);
		queue.enqueue(new PathPart(start.x, start.y, getDist(start, end)));
		var taken: Array<Array<Bool>> = [];
		for (y in 0...map.height) {
			var current: Array<Bool> = [];
			for (x in 0...map.width) {
				current.push(false);
			}
			taken.push(current);
		}
		var path: Array<PathPart> = [];

		while (!queue.isEmpty()) {
			var part = queue.dequeue();
			taken[part.y][part.x] = true;
			path.push(part);

			// found
			if (part.x == end.x && part.y == end.y) {
				break;
			}

			var candidatePositions: Array<IntPoint> = [
				{x: part.x + 1, y: part.y},
				{x: part.x, y: part.y + 1},
				{x: part.x - 1, y: part.y},
				{x: part.x, y: part.y - 1},
			];
			for (pos in candidatePositions) {
				trace(pos);
				// skip positions out of bounds, in walls
				if (pos.x < 0 || pos.y < 0 || pos.x >= map.width || pos.y >= map.height) {
					trace("pos out of bounds");
					continue;
				}
				if (!map.isPointWall(pos)) {
					trace("pos is wall");
					continue;
				}
				if (taken[pos.y][pos.x]) {
					trace("pos taken");
					continue;
				}

				queue.enqueue(new PathPart(pos.x, pos.y, path.length + getDist(pos, end)));
			}
		}

		// check that path is valid
		var last = path[path.length - 1];
		if (last.x != end.x || last.y != end.y) {
			throw "End unreachable";
		}

		return new Path(path.map(p -> {x: p.x, y: p.y}));
	}

	public function new(points: Array<IntPoint>) {
		this.points = points;
	}
}
