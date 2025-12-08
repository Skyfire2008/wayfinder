package org.skyfire2008.wayfinder.path;

import polygonal.ds.Prioritizable;

import org.skyfire2008.wayfinder.geom.IntPoint;

class PathNode implements Prioritizable {
	// prioritizable properties
	public var priority(default, null): Float;
	public var position(default, null): Int;

	/**
	 * Previous node in path
	 */
	public var prevInPath(default, null): PathNode = null;

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

	/**
	 * Neighbouring nodes
	 */
	public var neighbours(default, null): Array<PathNode>;

	public function new() {
		// initialize priority
		this.neighbours = [];
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

	public function setPrev(prev: PathNode, distToPrev: Float) {
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

interface PathGraph {

	/**
	 * Gets pathfinding node at given coordinates
	 * @param pos 			coordinates
	 * @return 				Node
	 */
	public function getNode(pos: IntPoint): PathNode;

	/**
	 * Checks whether p0 is directly reachable from p1 without collisions with walls
	 * @param p0	first point
	 * @param p1	seconds point
	 * @return 		true if reachable
	 */
	public function checkVisibility(p0: IntPoint, p1: IntPoint): Bool;

}

// TODO: rethink the type parameters for Pathfinder
interface Pathfinder {

	/**
	 * Finds the shortest path. Assume that start and end are valid and not the same
	 * @param start 		starting position
	 * @param end 			end position
	 * @param pathGraph 	graph to pathfind in
	 * @return 				array of points
	 */
	public function findPath(start: IntPoint, end: IntPoint, pathGraph: PathGraph): Array<IntPoint>;

}
