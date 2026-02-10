package org.skyfire2008.wayfinder.path;

import js.lib.Set;

import polygonal.ds.PriorityQueue;

import org.skyfire2008.wayfinder.geom.IntPoint;
import org.skyfire2008.wayfinder.path.Pathfinder;
import org.skyfire2008.wayfinder.path.Pathfinder.PathGraph;
import org.skyfire2008.wayfinder.path.Pathfinder.PathNode;
import org.skyfire2008.wayfinder.path.Pathfinder.Temp;

class ThetaStar implements Pathfinder {
	public function new() {}

	public function findPath(start: IntPoint, end: IntPoint, graph: PathGraph): Temp {
		var startNode = graph.getNode(start);
		if (startNode == null) {
			throw "Start node is undefined or a wall";
		}

		var endNode = graph.getNode(end);
		if (endNode == null) {
			throw "End node is undefined or a wall";
		}

		if (start.x == end.x && start.y == end.y) {
			return {path: [start, end], closed: []};
		}

		// initialize closed set and priority queue
		var closed = new Set<PathNode>();
		var queue = new PriorityQueue<PathNode>(1000, true);

		startNode.setG(0);
		// set startNode's previous node to itself so that there's no need to check if node has a previous for visibility check later
		startNode.setPrev(startNode, 0);
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

				var prev: PathNode = null;
				// if neighbour visible from current's previous node...
				if (graph.checkVisibility(current.prevInPath.pos, neighbour.pos)) {
					// connect neigbour to previous node instead
					prev = current.prevInPath;
				} else {
					// otherwise, use current, jsut like in A*
					prev = current;
				}

				// calculate best priority for this neighbour
				// prev node's distance from start + distance from prev to neighbour + neighbour heuristic
				var distance = IntPoint.distance(prev.pos, neighbour.pos);
				var bestPriority = prev.g + distance + neighbour.h;

				// skip if already closed or had better previous node
				if (neighbour.priority <= bestPriority) {
					continue;
				}

				// otherwise, connect to previous node
				neighbour.setPrev(prev, distance);
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
		while (current != startNode) { // since startNode is looped onto itself
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

		var closedArray: Array<IntPoint> = [];
		for (node in closed) {
			closedArray.push(node.pos);
		}

		return {
			path: points,
			closed: closedArray
		};
	}
}
