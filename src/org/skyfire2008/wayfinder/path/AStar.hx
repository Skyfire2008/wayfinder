package org.skyfire2008.wayfinder.path;

import js.lib.Set;

import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.path.Pathfinder.PathGraph;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;

class AStar implements Pathfinder {
	public function new() {}

	public function findPath<T: PathNode<T>>(start: IntPoint, end: IntPoint, graph: PathGraph<T>): Array<IntPoint> {
		var startNode = graph.getNode(start);
		if (startNode == null) {
			throw "Start node is undefined or a wall";
		}

		var endNode = graph.getNode(end);
		if (endNode == null) {
			throw "End node is undefined or a wall";
		}

		if (start.x == end.x && start.y == end.y) {
			throw "Start position is the same as end position";
		}

		// initialize closed set and priority queue
		var closed = new Set<T>();
		var queue = new PriorityQueue<T>(65536, true);

		startNode.setG(0);
		queue.enqueue(startNode);

		// while queue is not empty
		while (!queue.isEmpty()) {

			// get best node and add it to closed set
			var current = queue.dequeue();
			closed.add(current);

			// if end reached, stop
			if (current == endNode) {
				break;
			}

			// iterate over its neighbours
			for (neighbour in current.neighbours) {

				// skip if neighbour is already closed
				if (closed.has(neighbour)) {
					continue;
				}

				// set neighbour's h value
				if (neighbour.h == 0) {
					neighbour.setH(IntPoint.distance(end, neighbour.pos));
				}

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

		return points;
	}
}
