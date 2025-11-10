package org.skyfire2008.wayfinder.path;

import polygonal.ds.Prioritizable;
import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Path;

abstract class PathNode<T:PathNode<T>> implements Prioritizable {
	// prioritizable properties
	public var priority(default, null): Float;
	public var position(default, null): Int;

	public var closed(default, null): Bool = false;
	public var prevInPath(default, null): T = null;

	/**
	 * Distance from start node
	 */
	public var g: Float = 0;

	/**
	 * Heuristic value
	 */
	public var h(default, null): Float;

	public function new(h: Float) {
		this.h = h;
		this.priority = h;
	}

	public abstract function close(): Void;

	public function setPrev(prev: T, distToPrev: Float) {
		this.prevInPath = prev;
		this.g = prev.g + distToPrev;
		this.priority = this.g + this.h;
	}
}

interface PathGraph<T:PathNode<T>> {
	public function clearPathfinding(): Void;

	public function getNode(pos: IntPoint): T;

	public function getNeighbours(node: T): Array<T>;

	public function getDistance(node0: T, node1: T): Float;
}

interface Pathfinder {
	public function findPath<T: PathNode<T>>(start: IntPoint, end: IntPoint, pathGraph: PathGraph<T>): Path;
}

class AStar implements Pathfinder {
	public function new() {}

	public function findPath<T: PathNode<T>>(start: IntPoint, end: IntPoint, graph: PathGraph<T>): Path {
		// TODO: add exceptions
		var startNode = graph.getNode(start);
		if (startNode == null) {
			return null;
		}

		var endNode = graph.getNode(end);
		if (endNode == null) {
			return null;
		}

		if (start.x == end.x && start.y == end.y) {
			return null;
		}

		var queue = new PriorityQueue<T>(1, true);
		queue.enqueue(startNode);

		// while queue is not empty
		while (!queue.isEmpty()) {

			// get best node and add it to closed set
			var current = queue.dequeue();
			current.close();

			// iterate over its neighbours
			var neighbours = graph.getNeighbours(current);
			for (neighbour in neighbours) {

				// if found, stop
				if (neighbour == endNode) {
					break;
				}

				// calculate best priority for this neighbour
				// current node's distance from start + neighbour heuristic + 1(distance from current to neighbour)
				var bestPriority = current.g + neighbour.h + 1;

				// skip if already closed or had better previous node
				if (neighbour.closed || neighbour.priority <= bestPriority) {
					continue;
				}

				// otherwise, connect to current node
				var isEnqueued = neighbour.prevInPath != null;
				neighbour.setPrev(current, 1);
				if (isEnqueued) {
					queue.reprioritize(neighbour, neighbour.priority);
				} else {
					queue.enqueue(neighbour);
				}
			}
		}

		// build path

		graph.clearPathfinding();
		return null;
	}
}
