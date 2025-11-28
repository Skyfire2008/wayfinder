package org.skyfire2008.wayfinder.path;

import polygonal.ds.HashSet;
import polygonal.ds.Hashable;
import polygonal.ds.Prioritizable;
import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Path;

abstract class PathNode<T:PathNode<T>> implements Prioritizable implements Hashable {
	// prioritizable properties
	public var priority(default, null): Float;
	public var position(default, null): Int;

	// hashable properties
	public var key(default, null): Int;

	/**
	 * Previous node in path
	 */
	public var prevInPath(default, null): T = null;

	/**
	 * Distance from start node, init to infinity, since it's not known at the beginning
	 */
	public var g(default, null): Float = Math.POSITIVE_INFINITY;

	/**
	 * Heuristic value(estimated distance from end)
	 */
	public var h(default, null): Float = 0;

	/**
	 * Node position on the map
	 */
	public var pos(default, null): IntPoint;

	public function new() {
		// initialize priority
		this.priority = h + g;
	}

	public function setH(h: Float) {
		this.h = h;
		this.priority = h + g;
	}

	public function setG(g: Float) {
		this.g = g;
		this.priority = h + g;
	}

	public function setPrev(prev: T, distToPrev: Float) {
		this.prevInPath = prev;
		this.g = prev.g + distToPrev;
		this.priority = this.g + this.h;
	}

	public function resetPathfinding() {
		this.prevInPath = null;
		this.g = Math.POSITIVE_INFINITY;
		this.h = 0;
	}
}

interface PathGraph<T:PathNode<T>> {

	/**
	 * Gets pathfinding node at given coordinates
	 * @param pos 			coordinates
	 * @return 				Node
	 */
	public function getNode(pos: IntPoint): T;

	/**
	 * Gets neighbours of given node
	 * @param node 			node
	 * @return 				array of neighbours
	 */
	public function getNeighbours(node: T): Array<T>;

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

		// initialize closed set and priority queue
		var closed = new HashSet<T>(1023);
		var queue = new PriorityQueue<T>(1, true);

		startNode.setG(0);
		queue.enqueue(startNode);

		// while queue is not empty
		while (!queue.isEmpty()) {

			// get best node and add it to closed set
			var current = queue.dequeue();
			closed.set(current);

			// if end reached, stop
			if (current == endNode) {
				break;
			}

			// iterate over its neighbours
			var neighbours = graph.getNeighbours(current);
			for (neighbour in neighbours) {

				// skip if neighbour is already closed
				if (closed.has(neighbour)) {
					continue;
				}

				// TODO: do I need to set it every time?
				// set neighbour's h value
				neighbour.setH(IntPoint.distance(end, neighbour.pos));

				// calculate best priority for this neighbour
				// current node's distance from start + distance from current to neighbour + neighbour heuristic
				var distance = IntPoint.distance(current.pos, neighbour.pos);
				var bestPriority = current.g + distance + neighbour.h;

				// skip if already closed or had better previous node
				if (neighbour.priority <= bestPriority) {
					continue;
				}

				// otherwise, connect to current node
				neighbour.setPrev(current, distance);
				if (queue.contains(neighbour)) {
					queue.reprioritize(neighbour, neighbour.priority);
				} else {
					queue.enqueue(neighbour);
				}
			}
		}

		// check that path is finished
		if (!closed.has(endNode)) {
			throw "End unreachable";
		}

		// build path
		var points: Array<IntPoint> = [];
		var current = endNode;
		while (current.prevInPath != null) {
			points.unshift(current.pos);
			current = current.prevInPath;
		}
		points.unshift(start);

		// reset pathfinding
		for (node in closed) {
			node.resetPathfinding();
		}
		for (node in queue) {
			node.resetPathfinding();
		}

		return new Path(points);
	}
}
