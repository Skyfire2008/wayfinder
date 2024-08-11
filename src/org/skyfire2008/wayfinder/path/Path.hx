package org.skyfire2008.wayfinder.path;

import org.skyfire2008.wayfinder.geom.Point;
import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Map;
import org.skyfire2008.wayfinder.util.Util;

import polygonal.ds.PriorityQueue;
import polygonal.ds.Prioritizable;

class Candidate implements Prioritizable {
	public var pos(default, null): IntPoint;
	public var prev: IntPoint;
	public var pathLength: Float;

	public var priority(default, null): Float;

	/**
	 * Position in priority queue
	 */
	public var position(default, null): Int;

	public var closed: Bool = false;

	public var x(get, null): Int;
	public var y(get, null): Int;

	public function new(pos: IntPoint, prev: IntPoint, pathLength: Float, priority: Float) {
		this.pos = pos;
		this.prev = prev;
		this.pathLength = pathLength;
		this.priority = priority;
	}

	/**
	 * ONLY USE IF NOT ENQUEUED YET
	 * Sets priority
	 * @param priority 
	 */
	public function setPriority(priority: Float) {
		this.priority = priority;
	}

	public inline function isEnqueued(): Bool {
		return this.prev != null;
	}

	private inline function get_x(): Int {
		return pos.x;
	}

	private inline function get_y(): Int {
		return pos.y;
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
	private static function getDist(start: IntPoint, end: IntPoint): Float {
		// return Util.abs(start.x - end.x) + Util.abs(start.y - end.y);
		var dx = end.x - start.x;
		var dy = end.y - start.y;
		return Math.sqrt(dx * dx + dy * dy);
	}

	public static function findThetaStar(map: Map, start: IntPoint, end: IntPoint): Path {
		if (map.isPointWall(start)) {
			throw "Start point is a wall";
		}

		if (map.isPointWall(end)) {
			throw "End point is a wall";
		}

		// initialize queue and stuff
		var queue = new PriorityQueue<Candidate>(17, true);

		var candidates: Array<Array<Candidate>> = [];
		for (y in 0...map.height) {
			var current: Array<Candidate> = [];
			for (x in 0...map.width) {
				var candidate = new Candidate({x: x, y: y}, null, 0, Math.POSITIVE_INFINITY);
				current.push(candidate);
				if (map.isPointWall(candidate.pos)) {
					candidate.closed = true;
				}

			}
			candidates.push(current);
		}

		var startCandidate = new Candidate(start, start, 0, getDist(start, end));
		candidates[start.y][start.x] = startCandidate;
		queue.enqueue(startCandidate);

		while (!queue.isEmpty()) {
			var current = queue.dequeue();
			current.closed = true;

			var candidatePositions: Array<IntPoint> = [
				{x: current.x + 1, y: current.y},
				{x: current.x, y: current.y + 1},
				{x: current.x - 1, y: current.y},
				{x: current.x, y: current.y - 1},
			];
			for (pos in candidatePositions) {
				// found
				if (current.x == end.x && current.y == end.y) {
					break;
				}

				// skip positions out of bounds
				if (pos.x < 0 || pos.y < 0 || pos.x >= map.width || pos.y >= map.height) {
					continue;
				}

				var candidate = candidates[pos.y][pos.x];

				// skip if already closed or had better previous node
				if (candidate.closed) {
					continue;
				}

				var calcLength: Float;
				var prev: IntPoint;
				if (map.checkVisibility(current.prev, pos)) {
					var dx = pos.x - current.prev.x;
					var dy = pos.y - current.prev.y;
					calcLength = Math.sqrt(dx * dx + dy * dy) + candidates[current.prev.y][current.prev.x].pathLength;
					prev = current.prev;
				} else {
					calcLength = 1 + current.pathLength;
					prev = current.pos;
				}

				var calcPriority = getDist(pos, end) + calcLength;
				if (candidate.priority <= calcPriority) {
					continue;
				}

				if (!candidate.isEnqueued()) {
					candidate.pathLength = calcLength;
					candidate.prev = prev;
					candidate.setPriority(calcPriority);
					queue.enqueue(candidate);
				} else {
					candidate.pathLength = calcLength;
					candidate.prev = prev;
					queue.reprioritize(candidate, calcPriority);
				}
			}
		}

		// check tha path is found
		if (!candidates[end.y][end.x].closed) {
			throw "End unreachable";
		}

		// otherwise reconstruct the path
		var points: Array<IntPoint> = [];
		var current = candidates[end.y][end.x];
		while (current.pos != start) {
			points.unshift(current.pos);
			current = candidates[current.prev.y][current.prev.x];
		}
		points.unshift(start);

		return new Path(points);
	}

	public static function findAStar(map: Map, start: IntPoint, end: IntPoint): Path {
		if (map.isPointWall(start)) {
			throw "Start point is a wall";
		}

		if (map.isPointWall(end)) {
			throw "End point is a wall";
		}

		// initialize queue and stuff
		var queue = new PriorityQueue<Candidate>(17, true);

		var candidates: Array<Array<Candidate>> = [];
		for (y in 0...map.height) {
			var current: Array<Candidate> = [];
			for (x in 0...map.width) {
				var candidate = new Candidate({x: x, y: y}, null, 0, Math.POSITIVE_INFINITY);
				current.push(candidate);
				if (map.isPointWall(candidate.pos)) {
					candidate.closed = true;
				}

			}
			candidates.push(current);
		}

		var startCandidate = new Candidate(start, null, 0, getDist(start, end));
		candidates[start.y][start.x] = startCandidate;
		queue.enqueue(startCandidate);

		while (!queue.isEmpty()) {
			var current = queue.dequeue();
			current.closed = true;

			var candidatePositions: Array<IntPoint> = [
				{x: current.x + 1, y: current.y},
				{x: current.x, y: current.y + 1},
				{x: current.x - 1, y: current.y},
				{x: current.x, y: current.y - 1},
			];
			for (pos in candidatePositions) {
				// skip positions out of bounds
				if (pos.x < 0 || pos.y < 0 || pos.x >= map.width || pos.y >= map.height) {
					continue;
				}

				var candidate = candidates[pos.y][pos.x];
				var calcLength = 1 + current.pathLength;
				var calcPriority = getDist(pos, end) + calcLength;

				// found
				if (current.x == end.x && current.y == end.y) {
					break;
				}

				// skip if already closed or had better previous node
				if (candidate.closed || candidate.priority <= calcPriority) {
					continue;
				}

				if (!candidate.isEnqueued()) {
					candidate.pathLength = calcLength;
					candidate.prev = current.pos;
					candidate.setPriority(calcPriority);
					queue.enqueue(candidate);
				} else {
					candidate.pathLength = calcLength;
					candidate.prev = current.pos;
					queue.reprioritize(candidate, calcPriority);
				}
			}
		}

		// check tha path is found
		if (!candidates[end.y][end.x].closed) {
			throw "End unreachable";
		}

		// otherwise reconstruct the path
		var points: Array<IntPoint> = [];
		var current = candidates[end.y][end.x];
		while (current.pos != start) {
			points.unshift(current.pos);
			current = candidates[current.prev.y][current.prev.x];
		}
		points.unshift(start);

		return new Path(points);
	}

	public function new(points: Array<IntPoint>) {
		this.points = points;
	}
}
